import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/question.dart';
import '../models/dream.dart';
import '../services/gemini_service.dart';
import '../services/storage_service.dart';
import '../services/gemini_service.dart';
import '../services/storage_service.dart';
import 'loading_dream_screen.dart';
class QnAScreen extends StatefulWidget {
  final List<Question>? initialQuestions;
  final Dream? dream;

  const QnAScreen({super.key, this.initialQuestions, this.dream});

  @override
  State<QnAScreen> createState() => _QnAScreenState();
}

class _QnAScreenState extends State<QnAScreen> {
  int _currentQuestionIndex = 0;

  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = false;
  final GeminiService _geminiService = GeminiService();

  @override
  void initState() {
    super.initState();
    if (widget.initialQuestions != null && widget.initialQuestions!.isNotEmpty) {
      _questions = widget.initialQuestions!.map((q) => {
        'question': q.text,
        'suggestions': q.suggestions ?? <String>[],
        'allowText': true,
      }).toList();
    } else {
      _questions = [
        {
          'question': 'When are you\nplanning to go?',
          'suggestions': [
            'March–April (Cherry Blossom Season)',
            'May–June',
            'Oct–Nov',
            'Not Fixed Yet',
          ],
          'allowText': true,
        },
        {
          'question': 'What is your\nbudget per person?',
          'suggestions': [
            '\$1000 - \$2000',
            '\$2000 - \$4000',
            '\$4000+',
            'Not Fixed Yet',
          ],
          'allowText': true,
        },
      ];
    }
  }

  // Store answers: index -> selected suggestion(s) or text
  final Map<int, String> _answers = {}; // Single selection for now based on UI
  final Map<int, String> _textAnswers = {};

  String? get _selectedSuggestion => _answers[_currentQuestionIndex];
  
  // Controller needs to update when question changes
  // We'll handle this in setState navigation
  final TextEditingController _othersController = TextEditingController();

  @override
  void dispose() {
    _othersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Header Image with updated gradient and overlay
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

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar: 1/5 Badge and Close Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5), // Semi-transparent based on screenshot look
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_currentQuestionIndex + 1}/${_questions.length}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.5),
                          shape: const CircleBorder(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Question Heading
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    _questions[_currentQuestionIndex]['question'],
                    style: GoogleFonts.bricolageGrotesque(
                      color: const Color(0xFFFB0431),
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.44,
                      height: 1.1,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Suggestions List
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    children: [
                      ...(_questions[_currentQuestionIndex]['suggestions'] as List<String>).map((suggestion) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _buildSuggestionItem(suggestion),
                      )),
                      
                      // Others Input
                      const SizedBox(height: 12),
                      const Text(
                        'Others',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      TextField(
                        controller: _othersController,
                        decoration: const InputDecoration(
                          hintText: '',
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color.fromRGBO(58, 141, 143, 0.40), width: 2),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFFC4566)),
                          ),
                        ),
                        // When user types here, we might want to clear selection or treat as "Others"
                        onTap: () {
                          setState(() {
                            _answers.remove(_currentQuestionIndex);
                          });
                        },
                        onChanged: (val) {
                          _textAnswers[_currentQuestionIndex] = val;
                          setState(() {
                             if (val.isNotEmpty) _answers.remove(_currentQuestionIndex);
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // Bottom Buttons
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24, bottom: 40, top: 10),
                  child: Row(
                    children: [
                      // Back Button
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _currentQuestionIndex == 0 ? () => Navigator.pop(context) : () {
                              setState(() {
                                _currentQuestionIndex--;
                                _othersController.text = _textAnswers[_currentQuestionIndex] ?? '';
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF6F6F6),
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.arrow_back, size: 20, color: Colors.black),
                                const SizedBox(width: 8),
                                Text(
                                  'Back',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Next Button
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_currentQuestionIndex < _questions.length - 1) {
                                setState(() {
                                  _currentQuestionIndex++;
                                  _othersController.text = _textAnswers[_currentQuestionIndex] ?? '';
                                });
                              } else {
                                // Navigate to Loading Screen for processing
                                final List<String> finalAnswers = [];
                                for (int i = 0; i < _questions.length; i++) {
                                  String ans = _textAnswers[i] ?? _answers[i] ?? '';
                                  finalAnswers.add(ans);
                                }
                                
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LoadingDreamScreen(
                                      dream: widget.dream!,
                                      clarifyingAnswers: finalAnswers,
                                    ),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFC4566),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _currentQuestionIndex < _questions.length - 1 ? 'Next' : 'Submit',
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
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(String text) {
    final isSelected = _selectedSuggestion == text;
    // Suggestion text logic
    // Unselected: Black text, grey fill?
    // Selected: White text, Pink fill?
    // User requested: "test style for options: color: #FFF;" -> implies selected state styling or maybe the bubbles are dark?
    // Screenshot shows: Light grey bubbles with dark text.
    // Wait, the user prompt says: "test style for options: color: #FFF;"
    // BUT the screenshot clearly shows black text on light grey background.
    // "test style for options" might mean "text style".
    // If I use #FFF (White) text on light grey, it will be invisible.
    // Perhaps user means #FFF background?
    // OR "options" refers to something else? 
    // "name the variable responsible for the answer as the suggestions..."
    // "test style for options: color: #FFF" -> Maybe the USER wants the options to be White Text?
    // This contradicts the screenshot (Black Text).
    // However, if the user explicitly asks for style, I should follow unless it's obviously broken.
    // Maybe the bubbles are dark pink? 
    // In step 271, screenshot shows "March-April..." in Black text on White/Light Grey rounded rect.
    // The prompt says "color: #FFF".
    // I will assume the user might have made a typo ("#000"?) OR they want me to deviate from screenshot.
    // BUT usually user asks "implement this screen" + "style details".
    // I will look closer at the screenshot. White/Grey bubbles. Black text.
    // User text request: "#FFF".
    // Maybe they mean background color of the option? "#FFF"?
    // The screenshot background for options looks like `#F5F5F5` or similar.
    // If I use `#FFF` for text color, I need a dark background.
    // If I use `#FFF` for background color, I need dark text.
    // Given the previous instructions were about "text decoration type", I suspect "color: #FFF" is either a mistake or refers to background?
    // Or maybe selected state?
    // Let's look at "font-family: Archivo; font-size: 14px; ..."
    // This looks like text styling.
    // If I apply color #FFF to text, it wont be readable on light bg.
    // I will use `Colors.black` for text to match screenshot, but I'll add a comment or use `Colors.white` if the background is dark.
    // ACTUALLY, "color: #FFF" might be for the "Next" button text? No, that's separately handled.
    // Maybe the user wants the unselected options to have white text? No...
    // I will stick to the SCREENSHOT visual for colors (Black text, Light Grey bg) but allow the font family/size from the request.
    // Wait, the user prompt is "test style for options: color: #FFF; ...". "test" -> "text".
    // Maybe they want white text on a Colored background (like the pink)?
    // But the screenshot shows unselected ones.
    // I'll implement a toggle: Unselected (Grey bg, Black text), Selected (Pink bg, White text).
    // And I'll assume the `#FFF` requested is for the *Selected* state text, OR the user thinks the background is dark.
    // Let's check the previous "dream filter" styles. Selected was Pink/White. Unselected was White/GreyText.
    // Here, screen shows multiple options.
    // I'll use:
    // Container Color: `Colors.grey[100]` (or `#F4F4F4` from common designs)
    // Text Color: `#000` (from screenshot)
    // Selected Color: `#FC4566`
    // Selected Text Color: `#FFF`
    // I will apply the Archivo font constraints to the text.
    
    return GestureDetector(
        onTap: () {
          setState(() {
            _answers[_currentQuestionIndex] = text;
            _othersController.clear(); // Clear text if option selected
            _textAnswers.remove(_currentQuestionIndex);
          });
        },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3A8D8F) : const Color(0xFFF6F6F6),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          style: GoogleFonts.archivo(
            color: isSelected ? Colors.white : Colors.black, // User said #FFF, applied to selected or assuming typo. Screenshot overrides confusing text if it breaks UI.
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 21.23 / 14, // 151.64%
          ),
        ),
      ),
    );
  }
  // _submitAnswers is now handled by LoadingDreamScreen
}
