import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/question.dart';
import '../models/dream.dart';
import 'qna_screen.dart';

class StartQnaScreen extends StatelessWidget {
  final List<Question>? questions;
  final Dream? dream;

  const StartQnaScreen({super.key, this.questions, this.dream});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Header Image (Same as WriteDreamScreen)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/bg_image.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                ),
              ),
              child: Container(
                color: const Color.fromRGBO(96, 49, 58, 0.40),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.white,
                        Colors.white.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Close Button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.5),
                        shape: const CircleBorder(),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Perfect! now help\nme answer few\nquestions so that I\ncan make a\ndetailed plan for\nyou.',
                    style: GoogleFonts.bricolageGrotesque(
                      color: const Color(0xFFFB0431),
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.44,
                      height: 1.1,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Flower Image
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Image.asset(
                    'assets/flower.png',
                    height: 120, // Approximate height
                    fit: BoxFit.contain,
                  ),
                ),

                const Spacer(),

                // Bottom Button
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24, bottom: 40),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QnAScreen(
                              initialQuestions: questions,
                              dream: dream,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFC4566),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Start QnA',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
