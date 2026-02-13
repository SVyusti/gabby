import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/dream.dart';
import '../models/question.dart';
import '../services/gemini_service.dart';
import '../services/storage_service.dart';
import 'actions_screen.dart';

class LoadingDreamScreen extends StatefulWidget {
  final Dream dream;
  final List<String> clarifyingAnswers;

  const LoadingDreamScreen({
    super.key,
    required this.dream,
    required this.clarifyingAnswers,
  });

  @override
  State<LoadingDreamScreen> createState() => _LoadingDreamScreenState();
}

class _LoadingDreamScreenState extends State<LoadingDreamScreen> {
  final GeminiService _geminiService = GeminiService();
  String _loadingText = 'Consulting the stars...';

  @override
  void initState() {
    super.initState();
    _startGeneration();
  }

  Future<void> _startGeneration() async {
    try {
      // 1. Update dream status text
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _loadingText = 'Crafting your dream...');
      
      // 2. Set answers
      widget.dream.clarifyingAnswers = widget.clarifyingAnswers;

      // 3. Generate Plan
      await _geminiService.generateDreamPlan(widget.dream);
      
      if (mounted) setState(() => _loadingText = 'Adding magic dust...');
      
      // 4. Save Dream
      await StorageService.addDream(widget.dream);
      
      // 5. Navigate
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => ActionsScreen(dream: widget.dream, isNew: true),
          ),
          (route) => route.isFirst, // Go back to Home? Or allow back to Dashboard?
          // Actually, ActionsScreen has a back button that pops. If we remove all routes, it pops to nothing (black screen) or root.
          // Usually we want: Dashboard -> ActionsScreen.
          // So let's push Dashboard then ActionsScreen? Or just ActionsScreen as replacement?
          // If we use pushReplacement, popping ActionsScreen goes to... where?
          // If we removed until root, popping exits app or goes to root.
          // Best is to Navigate to Dashboard (GoalsScreen) and then Push ActionsScreen on top?
          // Or Push ActionsScreen and when popped, go to Dashboard/Home.
          // Let's rely on standard flow.
        );
        // Correct flow logic:
        // We want user to land on the Actions Screen.
        // If they click back, they should go to Goals Screen (Dashboard).
        // So we can push Dashboard, then push ActionsScreen.
      }
      
    } catch (e) {
      print('Error in loading screen: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        Navigator.pop(context); // Go back to QnA
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/dream_loading.json',
              width: 250,
              height: 250,
              fit: BoxFit.contain,
              onLoaded: (composition) {
                print('LOTTIE SUCCESS: Loaded composition with duration ${composition.duration}');
              },
            ),
            const SizedBox(height: 32),
            Text(
              _loadingText,
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
