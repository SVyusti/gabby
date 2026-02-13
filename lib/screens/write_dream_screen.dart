import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/gemini_service.dart';
import '../models/dream.dart';
import 'start_qna_screen.dart';

class WriteDreamScreen extends StatefulWidget {
  const WriteDreamScreen({super.key});

  @override
  State<WriteDreamScreen> createState() => _WriteDreamScreenState();
}

class _WriteDreamScreenState extends State<WriteDreamScreen> {
  final TextEditingController _controller = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  bool _isLoading = false;

  Future<void> _submitDream() async {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something about your goal')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final dream = Dream(
        title: _controller.text.trim().split('\n').first,
        description: _controller.text.trim(),
      );

      final questions = await _geminiService.generateClarifyingQuestions(dream.description);
      
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StartQnaScreen(
            questions: questions,
            dream: dream,
          ),
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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Header Image (Bottom aligned)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300, // Approximate height based on screenshot
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/bg_image.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter, // "bottom of the bg_image"
                ),
              ),
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
                    'Write Something\nabout your Goal',
                    style: GoogleFonts.bricolageGrotesque(
                      color: const Color(0xFFFB0431),
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.44,
                      height: 1.1, // Adjust line height for "Write Something..." wrapping
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // Input Field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: TextField(
                    controller: _controller,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: '', // Or "Type here..."
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color.fromRGBO(58, 141, 143, 0.40), width: 2),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFFC4566)),
                      ),
                    ),
                    maxLines: null,
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
                      onPressed: _isLoading ? null : _submitDream,
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
                          if (_isLoading)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          else ...[
                            Text(
                              'Next',
                              style: GoogleFonts.archivo(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                          ],
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
