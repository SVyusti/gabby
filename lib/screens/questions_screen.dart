import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/dream.dart';
import '../models/question.dart';
import '../services/gemini_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';
import '../widgets/trip_date_range_input.dart';
import '../widgets/budget_input.dart';
import '../widgets/preferences_input.dart';
import 'actions_screen.dart';

class QuestionsScreen extends StatefulWidget {
  final Dream dream;

  const QuestionsScreen({super.key, required this.dream});

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  final PageController _pageController = PageController();
  final List<TextEditingController> _answerControllers = [];
  List<Question> _questions = [];
  int _currentIndex = 0;
  bool _isLoading = false;
  final GeminiService _geminiService = GeminiService();

  @override
  void initState() {
    super.initState();
    _initializeQuestions();
  }

  Future<void> _initializeQuestions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final questions = await _geminiService.generateClarifyingQuestions(widget.dream.description);
      
      if (mounted) {
        setState(() {
          _questions = questions;
          // Initialize text controllers for text input types if any
           _answerControllers.clear();
          for (var i = 0; i < _questions.length; i++) {
            _answerControllers.add(TextEditingController());
          }
        });
      }
    } catch (e) {
      print('Error initializing questions: $e');
      // Fallback is handled by service returning defaults, 
      // but if service fails completely (e.g. network), we might want local fallback.
      // The service catches internally, so we should get questions.
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _answerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _nextStep() async {
    if (_currentIndex < _questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _generateMicroActions();
    }
  }

  Widget _buildQuestionInput(int index) {
    final question = _questions[index];
    
    switch (question.type) {
      case QuestionType.dateRange:
        return TripDateRangeInput(
          onChanged: (startDate, endDate, duration) {
            question.answer = 'From $startDate to $endDate ($duration days)';
          },
        );
      case QuestionType.budget:
        return BudgetInput(
          onChanged: (budget) {
            question.answer = budget;
          },
        );
      case QuestionType.preferences:
        return PreferencesInput(
          onChanged: (preferences) {
            question.answer = preferences.join(', ');
          },
        );
      case QuestionType.text:
      default:
        return TextField(
          controller: _answerControllers[index],
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Type your answer here...',
          ),
          onChanged: (value) {
            question.answer = value;
          },
        );
    }
  }

  Future<void> _generateMicroActions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Collect answers from questions
      widget.dream.clarifyingQuestions = _questions.map((q) => q.text).cast<Question>().toList();
      widget.dream.clarifyingAnswers = _questions
          .map((q) => q.answer ?? '')
          .toList();

      print('Generating itinerary and actions...');
      print('Dream title: ${widget.dream.title}');
      print('Clarifying answers: ${widget.dream.clarifyingAnswers}');

      // Generate plan (title, emoji, actions)
      await _geminiService.generateDreamPlan(widget.dream);
      
      print('Generation complete');
      print('Micro actions: ${widget.dream.microActions.length}');

      // Note: We are currently skipping itinerary generation to focus on the plan.
      // If itinerary is needed, we should add a separate call or update generateDreamPlan.
      widget.dream.itineraryItems = []; // Or keep empty for now

      if (!mounted) return;

      print('Navigating to ActionsScreen');
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ActionsScreen(dream: widget.dream, isNew: true),
        ),
      );
    } catch (e, stackTrace) {
      print('Error generating plan: $e');
      print('Stack trace: $stackTrace');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
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
              if (_questions.isEmpty)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else ...[
              const SizedBox(height: 20),
              
              // Progress Indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (_currentIndex + 1) / _questions.length,
                    backgroundColor: Colors.white,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryPink),
                    minHeight: 8,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.deepPlum),
                      onPressed: () {
                        if (_currentIndex > 0) {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    const Spacer(),
                    Text(
                      'Question ${_currentIndex + 1}/${_questions.length}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    const SizedBox(width: 48), // Balance for back button
                  ],
                ),
              ),

              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _questions[index].text,
                            style: Theme.of(context).textTheme.headlineMedium,
                            textAlign: TextAlign.center,
                          ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                          
                          const SizedBox(height: 40),
                          
                          Expanded(
                            child: SingleChildScrollView(
                              child: _buildQuestionInput(index).animate().fadeIn(delay: 300.ms),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: GradientButton(
                  text: _currentIndex == _questions.length - 1
                      ? 'Generate Plan'
                      : 'Next',
                  isLoading: _isLoading,
                  onPressed: _nextStep,
                ),
              ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
