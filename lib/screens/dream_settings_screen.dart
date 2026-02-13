import 'package:flutter/material.dart';
import '../models/dream.dart';
import '../models/question.dart';
import '../services/gemini_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';
import '../widgets/trip_date_range_input.dart';
import '../widgets/budget_input.dart';
import '../widgets/preferences_input.dart';

class DreamSettingsScreen extends StatefulWidget {
  final Dream dream;

  const DreamSettingsScreen({super.key, required this.dream});

  @override
  State<DreamSettingsScreen> createState() => _DreamSettingsScreenState();
}

class _DreamSettingsScreenState extends State<DreamSettingsScreen> {
  late Dream _dream;
  late List<Question> _questions;
  bool _isRegenating = false;
  final GeminiService _geminiService = GeminiService();

  @override
  void initState() {
    super.initState();
    _dream = Dream(
      id: widget.dream.id,
      title: widget.dream.title,
      description: widget.dream.description,
      clarifyingQuestions: widget.dream.clarifyingQuestions,
      clarifyingAnswers: widget.dream.clarifyingAnswers,
      microActions: widget.dream.microActions,
      createdAt: widget.dream.createdAt,
    );
    _initializeQuestions();
  }

  void _initializeQuestions() {
    _questions = [
      Question(
        text: 'When do you want to do your trip?',
        type: QuestionType.dateRange,
        answer: _dream.clarifyingAnswers.isNotEmpty ? _dream.clarifyingAnswers[0] : null,
      ),
      Question(
        text: 'What would be your approximate budget?',
        type: QuestionType.budget,
        answer: _dream.clarifyingAnswers.length > 1 ? _dream.clarifyingAnswers[1] : null,
      ),
      Question(
        text: 'What are your preferences? (Include activities, hobbies, etc.)',
        type: QuestionType.preferences,
        answer: _dream.clarifyingAnswers.length > 2 ? _dream.clarifyingAnswers[2] : null,
      ),
    ];
  }

  Future<void> _regeneratePlan() async {
    if (_questions.any((q) => q.answer == null || q.answer!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer all questions before regenerating')),
      );
      return;
    }

    setState(() {
      _isRegenating = true;
    });

    try {
      // Update dream with new answers
      _dream.clarifyingAnswers = _questions.map((q) => q.answer ?? '').toList();

      // Regenerate both itinerary and micro-actions
      final result = await _geminiService.generateItineraryAndActions(_dream);
      _dream.itineraryItems = result['itineraryItems'] ?? [];
      _dream.microActions = result['microActions'] ?? [];

      // Save updated dream
      await StorageService.updateDream(_dream);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plan regenerated successfully!')),
      );
      Navigator.pop(context, _dream);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRegenating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.softGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.deepPlum),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    Text(
                      'Trip Details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Review and Update Your Answers',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 24),
                        ..._buildQuestionCards(),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    GradientButton(
                      text: 'Regenerate Plan',
                      isLoading: _isRegenating,
                      onPressed: _regeneratePlan,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.deepPlum,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildQuestionCards() {
    return _questions.asMap().entries.map((entry) {
      final index = entry.key;
      final question = entry.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE75480), width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.text,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF3D3D3D),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildQuestionInput(index),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    }).toList();
  }

  Widget _buildQuestionInput(int index) {
    final question = _questions[index];

    switch (question.type) {
      case QuestionType.dateRange:
        return TripDateRangeInput(
          initialValue: question.answer,
          onChanged: (startDate, endDate, duration) {
            question.answer = 'From $startDate to $endDate ($duration days)';
          },
        );
      case QuestionType.budget:
        return BudgetInput(
          initialValue: question.answer,
          onChanged: (budget) {
            question.answer = budget;
          },
        );
      case QuestionType.preferences:
        final preferencesList = question.answer?.split(', ') ?? [];
        return PreferencesInput(
          initialValue: preferencesList,
          onChanged: (preferences) {
            question.answer = preferences.join(', ');
          },
        );
      case QuestionType.text:
      default:
        return TextField(
          decoration: InputDecoration(
            hintText: 'Enter your answer...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFE75480),
                width: 2,
              ),
            ),
          ),
          onChanged: (value) {
            question.answer = value;
          },
        );
    }
  }
}
