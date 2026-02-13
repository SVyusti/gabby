import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/dream.dart';
import '../services/gemini_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';
import 'questions_screen.dart';

class DreamInputScreen extends StatefulWidget {
  const DreamInputScreen({super.key});

  @override
  State<DreamInputScreen> createState() => _DreamInputScreenState();
}

class _DreamInputScreenState extends State<DreamInputScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  final GeminiService _geminiService = GeminiService();

  Future<void> _submitDream() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create dream object
      final dream = Dream(
        title: _controller.text.trim().split('\n').first, // Use first line as title
        description: _controller.text.trim(),
      );

      // Generate clarifying questions
      final questions = await _geminiService.generateClarifyingQuestions(dream.description);
      dream.clarifyingQuestions = questions;

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => QuestionsScreen(dream: dream),
        ),
      );
    } catch (e) {
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.softGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Text(
                  '✨ Share Your Dream',
                  style: Theme.of(context).textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ).animate().fadeIn().slideY(begin: -0.2, end: 0),
                
                const SizedBox(height: 10),
                Text(
                  'Tell me what you want to achieve, and I\'ll help you make it happen.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms),
                
                const SizedBox(height: 40),
                
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryPink.withValues(alpha: 0.1),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      expands: true,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: const InputDecoration(
                        hintText: 'I dream of...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.95, 0.95)),
                ),
                
                const SizedBox(height: 30),
                
                GradientButton(
                  text: 'Continue',
                  isLoading: _isLoading,
                  onPressed: _submitDream,
                ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
