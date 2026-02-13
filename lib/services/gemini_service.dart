import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/dream.dart';
import '../models/micro_action.dart';
import '../models/question.dart';
import '../models/itinerary_item.dart';
import '../models/dream_phase.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: _apiKey,
    );
  }

  Future<List<Question>> generateClarifyingQuestions(String dreamDescription) async {
    final schema = Schema.array(
      description: 'A list of clarifying questions to ask the user',
      items: Schema.object(
        properties: {
          'text': Schema.string(
            description: 'The text of the question to ask the user.',
          ),
          'type': Schema.enumString(
            enumValues: [
              'dateRange',
              'budget',
              'preferences',
              'miscellaneous',
              'text',
            ],
            description: 'The type of input widget to show for this question.',
          ),
          'suggestions': Schema.array(
            description: 'Optional list of 3-5 suggested answers for the user to choose from.',
            items: Schema.string(description: 'A suggested answer option.'),
          ),
        },
        requiredProperties: ['text', 'type'],
      ),
    );

    final prompt = '''
You are a supportive dream coach helping someone turn their dream into reality.

The user has shared this dream: "$dreamDescription"

Generate exactly 4 thoughtful, clarifying questions to better understand their dream.
The questions should cover timeline, budget, implementation details, or specific preferences.

You must choose the most appropriate input type for each question:
- 'dateRange': Use this IF asking about "when", "dates", "timeline", or urgency.
- 'budget': Use this IF asking about "cost", "money", "budget", or "price".
- 'preferences': Use this IF asking about "preferences", "interests", "hobbies", "activities", or "tags".
- 'miscellaneous': Use this for any other specific questions where you can provide predefined options.
- 'text': Use this for open-ended questions where predefined options are not suitable.

For each question (except pure 'text' type), provide 3-5 short, realistic 'suggestions' that the user can select.
For 'dateRange', provide specific ranges (e.g. "Next month", "In 3 months", "Not sure").
For 'budget', provide ranges (e.g. "\$100-\$500", "\$1000+", "Flexible").

Example Response Structure (JSON):
[
  { "text": "When do you want to start this project?", "type": "dateRange", "suggestions": ["ASAP", "Next Month", "In 6 months"] },
  { "text": "What is your budget for this?", "type": "budget", "suggestions": ["Under \$100", "\$100-\$500", "Unlimited"] },
  { "text": "What specific features do you want?", "type": "preferences", "suggestions": ["Feature A", "Feature B", "Feature C"] },
  { "text": "Any other details?", "type": "miscellaneous", "suggestions": ["Option 1", "Option 2"] }
]
''';

    try {
      final response = await _model.generateContent(
        [Content.text(prompt)],
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseSchema: schema,
        ),
      );

      final text = response.text;
      if (text == null) return _getDefaultQuestions();

      // Parse JSON response
      final json = jsonDecode(text) as List;
      return json.map((j) => Question.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error generating questions: $e');
      return _getDefaultQuestions();
    }
  }

  Future<void> generateDreamPlan(Dream dream) async {
    final questionsAndAnswers = List.generate(
      dream.clarifyingQuestions.length,
      (i) => 'Q: ${dream.clarifyingQuestions[i].text}\nA: ${dream.clarifyingAnswers.length > i ? dream.clarifyingAnswers[i] : "Not answered"}',
    ).join('\n\n');

    final schema = Schema.object(
      properties: {
        'shortDescription': Schema.string(
          description: 'A concise 2-3 word title for the dream.',
        ),
        'emoji': Schema.string(
          description: 'A single emoji depicting the dream.',
        ),
        'actions': Schema.array(
          description: 'A list of micro-actions divided into 4 phases.',
          items: Schema.object(
            properties: {
              'phase': Schema.integer(description: 'Phase number (1-4).'),
              'title': Schema.string(description: 'Title of the action.'),
              'description': Schema.string(description: 'A small paragraph description of the action.'),
              'deadline': Schema.string(description: 'Deadline in YYYY-MM-DD format.'),
            },
            requiredProperties: ['phase', 'title', 'description', 'deadline'],
          ),
        ),
        'phases': Schema.array(
          description: 'Details for each of the 4 phases.',
          items: Schema.object(
            properties: {
              'phaseNumber': Schema.integer(description: 'Phase number (1-4).'),
              'title': Schema.string(description: 'Name/Title of the phase.'),
              'icon': Schema.string(description: 'Single emoji icon for the phase.'),
            },
            requiredProperties: ['phaseNumber', 'title', 'icon'],
          ),
        ),

      },
      requiredProperties: ['shortDescription', 'emoji', 'actions', 'phases'],
    );

    final prompt = '''
You are a supportive action coach creating a step-by-step roadmap for achieving a dream.

Dream: "${dream.description}"

Additional context:
$questionsAndAnswers

Current Date: ${DateTime.now().toIso8601String().split('T')[0]}

Task:
1. Generate a 2-3 word title for the dream.
2. Select a single emoji representing the dream.
3. Define exactly 4 phases for the plan. Each must have a creative short title and an emoji.
4. Create a list of micro-actions divided into these 4 phases.
   - Each phase should have at least 2 actions.
   - Each action needs a title, description, and a realistic deadline calculated from the current date.
   - Deadlines should progress logically.

Format: JSON matching the provided schema.
''';

    try {
      final response = await _model.generateContent(
        [Content.text(prompt)],
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseSchema: schema,
        ),
      );

      final text = response.text;
      if (text == null) {
        dream.microActions = _getDefaultMicroActions(dream.id);
        return;
      }

      final json = jsonDecode(text);
      dream.shortDescription = json['shortDescription'];
      dream.emoji = json['emoji'];
      
      if (json['phases'] != null) {
        dream.phases = (json['phases'] as List).map((p) => DreamPhase.fromJson(p)).toList();
      }
      
      final actionsJson = json['actions'] as List;
      dream.microActions = actionsJson.asMap().entries.map((entry) {
        final idx = entry.key;
        final item = entry.value;
        return MicroAction(
          dreamId: dream.id,
          title: item['title'],
          description: item['description'],
          phase: item['phase'],
          deadline: DateTime.tryParse(item['deadline']),
          order: idx,
        );
      }).toList();

    } catch (e) {
      print('Error generating dream plan: $e');
      dream.microActions = _getDefaultMicroActions(dream.id);
    }
  }

  Future<Map<String, dynamic>> generateItineraryAndActions(Dream dream) async {
    final questionsAndAnswers = List.generate(
      dream.clarifyingQuestions.length,
      (i) => 'Q: ${dream.clarifyingQuestions[i]}\nA: ${dream.clarifyingAnswers.length > i ? dream.clarifyingAnswers[i] : "Not answered"}',
    ).join('\n\n');

    // Extract trip duration from answers if available
    int tripDays = 3; // Default to 3 days
    if (dream.clarifyingAnswers.isNotEmpty) {
      final firstAnswer = dream.clarifyingAnswers[0];
      final daysMatch = RegExp(r'(\d+)\s*days?').firstMatch(firstAnswer);
      if (daysMatch != null) {
        final parsed = int.tryParse(daysMatch.group(1) ?? '3');
        tripDays = parsed ?? 3;
      }
    }
    print('Extracted trip days: $tripDays');

    final itineraryPrompt = '''
You are a travel and trip planner creating a detailed day-by-day itinerary.

Dream/Trip: "${dream.description}"

Context:
$questionsAndAnswers

Trip Duration: Approximately $tripDays days

Create a detailed itinerary with specific places and activities for each day.

IMPORTANT: Format MUST be exactly like this (one item per line):
Day 1: Place Name | What to do there
Day 1: Another Place | Description of activity

Example:
Day 1: Tokyo Station | Arrive and check into hotel
Day 1: Senso-ji Temple | Visit historic Buddhist temple in Asakusa
Day 2: Mount Fuji | Climb or view scenic mountain
Day 2: Kawaguchiko Lake | Relax by the lake

Create 4-6 specific places per day. Use actual location names and clear activity descriptions.
''';

    final actionPrompt = '''
You are a supportive action coach creating a checklist for trip preparation.

Dream/Trip: "${dream.description}"

Context:
$questionsAndAnswers

Create 6-8 specific action items to prepare for and complete this trip.

Rules:
- One clear action per line, numbered 1-8
- Include research, bookings, packing, planning
- Be specific and actionable
- Progress from prep to execution

Format MUST be:
1. Action description
2. Action description
...
''';

    try {
      // Generate itinerary
      final itineraryContent = [Content.text(itineraryPrompt)];
      final itineraryResponse = await _model.generateContent(itineraryContent);
      final itineraryText = itineraryResponse.text ?? '';
      print('Itinerary Response: $itineraryText');

      // Generate actions
      final actionContent = [Content.text(actionPrompt)];
      final actionResponse = await _model.generateContent(actionContent);
      final actionText = actionResponse.text ?? '';
      print('Action Response: $actionText');

      // Parse both
      final itineraryItems = _parseItinerary(itineraryText, dream.id);
      final actionTexts = actionText
          .split('\n')
          .map((a) => a.trim())
          .where((a) => a.isNotEmpty && RegExp(r'^\d').hasMatch(a))
          .map((a) => a.replaceFirst(RegExp(r'^\d+\.\s*'), ''))
          .toList();

      final actions = actionTexts.isEmpty
          ? _getDefaultMicroActions(dream.id)
          : List.generate(
        actionTexts.length,
        (i) => MicroAction(
          dreamId: dream.id,
          title: actionTexts[i],
          order: i,
        ),
      );

      print('Parsed itinerary items: ${itineraryItems.length}');
      print('Parsed actions: ${actions.length}');

      // If no itinerary items were parsed, generate default ones
      final finalItineraryItems = itineraryItems.isEmpty
          ? _generateSmartItinerary(dream.id, tripDays, dream.clarifyingAnswers)
          : itineraryItems;

      print('Final itinerary items: ${finalItineraryItems.length}');

      return {
        'itineraryItems': finalItineraryItems,
        'microActions': actions,
      };
    } catch (e, stackTrace) {
      print('Error generating itinerary and actions: $e');
      print('Stack trace: $stackTrace');
      return {
        'itineraryItems': _generateSmartItinerary(dream.id, tripDays, dream.clarifyingAnswers),
        'microActions': _getDefaultMicroActions(dream.id),
      };
    }
  }

  List<ItineraryItem> _generateSmartItinerary(String dreamId, int tripDays, List<String> answers) {
    final items = <ItineraryItem>[];
    
    // Ensure at least 3 days
    final days = tripDays > 0 ? tripDays : 3;
    print('Generating $days days of smart itinerary');
    
    // Create basic day structure with 3 activities per day
    for (int day = 1; day <= days; day++) {
      // Morning activity
      items.add(
        ItineraryItem(
          dreamId: dreamId,
          day: day,
          place: 'Day $day - Morning Activity',
          description: 'Explore main attractions and key landmarks',
        ),
      );
      
      // Afternoon activity
      items.add(
        ItineraryItem(
          dreamId: dreamId,
          day: day,
          place: 'Day $day - Afternoon Activity',
          description: 'Continue sightseeing and local experiences',
        ),
      );
      
      // Evening activity
      items.add(
        ItineraryItem(
          dreamId: dreamId,
          day: day,
          place: 'Day $day - Evening',
          description: 'Local dining and cultural experiences',
        ),
      );
    }

    // Add arrival/departure context if this is not already covered
    if (items.isNotEmpty) {
      items.insert(
        0,
        ItineraryItem(
          dreamId: dreamId,
          day: 1,
          place: 'Arrival & Accommodation',
          description: 'Arrive at destination and check into your stay',
        ),
      );
    }

    print('Generated ${items.length} smart itinerary items');
    return items.isEmpty ? _getDefaultItineraryItems(dreamId) : items;
  }

  List<ItineraryItem> _parseItinerary(String itineraryText, String dreamId) {
    final items = <ItineraryItem>[];
    final lines = itineraryText.split('\n');

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // Try to parse "Day X: Place | Description" format
      final dayMatch = RegExp(r'Day\s+(\d+):\s*(.+?)\s*\|\s*(.+)').firstMatch(trimmed);
      if (dayMatch != null) {
        final day = int.tryParse(dayMatch.group(1) ?? '1') ?? 1;
        final place = dayMatch.group(2)?.trim() ?? 'Activity';
        final description = dayMatch.group(3)?.trim();

        items.add(
          ItineraryItem(
            dreamId: dreamId,
            day: day,
            place: place,
            description: description,
          ),
        );
      } else {
        // Try to parse "Day X: Place" format (no description)
        final simpleDayMatch = RegExp(r'Day\s+(\d+):\s*(.+)').firstMatch(trimmed);
        if (simpleDayMatch != null) {
          final day = int.tryParse(simpleDayMatch.group(1) ?? '1') ?? 1;
          final place = simpleDayMatch.group(2)?.trim() ?? 'Activity';

          items.add(
            ItineraryItem(
              dreamId: dreamId,
              day: day,
              place: place,
            ),
          );
        }
      }
    }

    return items;
  }

  List<ItineraryItem> _getDefaultItineraryItems(String dreamId) {
    return [
      ItineraryItem(
        dreamId: dreamId,
        day: 1,
        place: 'Arrival & Settle In',
        description: 'Arrive at destination, check-in to accommodation, rest and explore immediate surroundings',
      ),
      ItineraryItem(
        dreamId: dreamId,
        day: 1,
        place: 'Local Dinner',
        description: 'Enjoy authentic local cuisine to experience the local culture',
      ),
      ItineraryItem(
        dreamId: dreamId,
        day: 2,
        place: 'Main Attraction',
        description: 'Visit the primary landmark or attraction on your list',
      ),
      ItineraryItem(
        dreamId: dreamId,
        day: 2,
        place: 'Local Market',
        description: 'Explore local shops and markets, shop for souvenirs',
      ),
    ];
  }

  List<Question> _getDefaultQuestions() {
    return [
      Question(
        text: 'What does achieving this dream look like to you?',
        type: QuestionType.text,
      ),
      Question(
        text: 'What is your current situation related to this dream?',
        type: QuestionType.text,
      ),
      Question(
        text: 'What resources or skills do you already have?',
        type: QuestionType.text,
      ),
      Question(
        text: 'When would you like to achieve this dream?',
        type: QuestionType.dateRange,
      ),
    ];
  }

  List<MicroAction> _getDefaultMicroActions(String dreamId) {
    return [
      MicroAction(dreamId: dreamId, title: 'Write down your vision in detail', order: 0),
      MicroAction(dreamId: dreamId, title: 'Research what others have done to achieve similar dreams', order: 1),
      MicroAction(dreamId: dreamId, title: 'Identify one small step you can take today', order: 2),
      MicroAction(dreamId: dreamId, title: 'Find one person who has achieved something similar', order: 3),
      MicroAction(dreamId: dreamId, title: 'Set a specific deadline for your first milestone', order: 4),
      MicroAction(dreamId: dreamId, title: 'Create a simple tracking system for your progress', order: 5),
    ];
  }

  Future<Map<String, String>> getPlaceDetails(String placeName) async {
    final prompt = '''
You are a travel information assistant. Provide accurate information about the following place.

Place: "$placeName"

Please provide:
1. A brief, informative description (2-3 sentences about what makes this place special, its history, or attractions)
2. Typical opening time (format: HH:MM AM/PM, or "Always open" if applicable)
3. Typical closing time (format: HH:MM AM/PM, or "N/A" if always open)

Format your response EXACTLY like this:
Description: [your description here]
Opening Time: [opening time]
Closing Time: [closing time]

Be accurate and concise.
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final text = response.text ?? '';

      // Parse the response
      final details = <String, String>{};
      
      final descriptionMatch = RegExp(r'Description:\s*(.+?)(?=Opening Time:|$)', dotAll: true).firstMatch(text);
      if (descriptionMatch != null) {
        details['description'] = descriptionMatch.group(1)?.trim() ?? '';
      }

      final openingMatch = RegExp(r'Opening Time:\s*(.+?)(?=Closing Time:|$)').firstMatch(text);
      if (openingMatch != null) {
        details['openingTime'] = openingMatch.group(1)?.trim() ?? '';
      }

      final closingMatch = RegExp(r'Closing Time:\s*(.+?)$').firstMatch(text);
      if (closingMatch != null) {
        details['closingTime'] = closingMatch.group(1)?.trim() ?? '';
      }

      print('Place details fetched for $placeName: $details');
      return details;
    } catch (e) {
      print('Error fetching place details: $e');
      return {
        'description': '',
        'openingTime': '',
        'closingTime': '',
      };
    }
  }
}
