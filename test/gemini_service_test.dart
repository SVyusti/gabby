import 'package:flutter_test/flutter_test.dart';
import 'package:gabby/services/gemini_service.dart';
import 'package:gabby/models/question.dart';
import 'package:gabby/models/dream.dart';
import 'package:gabby/models/micro_action.dart';
import 'package:gabby/models/itinerary_item.dart';

void main() {
  test('generateClarifyingQuestions returns structured questions', () async {
    final service = GeminiService();
    final questions = await service.generateClarifyingQuestions('I want to visit Japan for 2 weeks with a budget of \$5000');
    
    print('Generated Questions:');
    for (var q in questions) {
      print('- ${q.text} (${q.type})');
    }

    expect(questions, isNotEmpty);
    expect(questions.length, 4);
    // We expect at least some types to be correctly identified
    expect(questions.any((q) => q.type != QuestionType.text), isTrue);
  });

  test('generateMicroActions returns structured actions', () async {
    final service = GeminiService();
    final dream = Dream(
      title: 'Visit Japan',
      description: 'I want to visit Japan for 2 weeks with a budget of \$5000',
      clarifyingQuestions: [
        Question(text: 'When do you want to go?', type: QuestionType.dateRange),
      ],
      clarifyingAnswers: ['Next spring'],
    );
    
    final actions = await service.generateMicroActions(dream);
    
    print('Generated Micro Actions:');
    for (var a in actions) {
      print('- ${a.title} (Order: ${a.order})');
    }

    expect(actions, isNotEmpty);
    expect(actions.length, inInclusiveRange(6, 8));
    // Verify order is sequential or at least present
    expect(actions.every((a) => a.order >= 0), isTrue);
  });

  test('generateItineraryAndActions returns structured itinerary', () async {
    final service = GeminiService();
    final dream = Dream(
      title: 'Visit Japan',
      description: 'I want to visit Japan for 2 weeks with a budget of \$5000',
      clarifyingQuestions: [
        Question(text: 'When do you want to go?', type: QuestionType.dateRange),
      ],
      clarifyingAnswers: ['Next spring, for 14 days'],
    );
    
    final result = await service.generateItineraryAndActions(dream);
    final itinerary = result['itineraryItems'] as List<ItineraryItem>;
    final actions = result['microActions'] as List<MicroAction>;
    
    print('Generated Itinerary Items: ${itinerary.length}');
    print('Generated Prep Actions: ${actions.length}');

    expect(itinerary, isNotEmpty);
    expect(actions, isNotEmpty);
    
    // Check structure of itinerary item
    final firstItem = itinerary.first;
    print('First Item: Day ${firstItem.day} - ${firstItem.place}');
    expect(firstItem.day, isPositive);
    expect(firstItem.place, isNotEmpty);
    expect(firstItem.description, isNotNull);
  });
}
