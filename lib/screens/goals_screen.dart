import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/storage_service.dart';
import '../models/dream.dart';
import 'actions_screen.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  List<Dream> _dreams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDreams();
  }

  Future<void> _loadDreams() async {
    setState(() => _isLoading = true);
    final dreams = await StorageService.loadDreams();
    if (mounted) {
      setState(() {
        _dreams = dreams;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            height: 191,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg_image.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Color.fromRGBO(96, 49, 58, 0.40),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Left: Title
                          Text(
                            'My Goals',
                            style: GoogleFonts.bricolageGrotesque(
                              fontSize: 42,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          // Right: Count
                          Text(
                            '${_dreams.length}',
                            style: GoogleFonts.bricolageGrotesque(
                              fontSize: 42,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _dreams.isEmpty
                    ? Center(
                        child: Text(
                          'No goals yet.\nStart dreaming!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.archivo(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _dreams.length,
                        itemBuilder: (context, index) {
                          final dream = _dreams[index];
                          return Card(
                              elevation: 0,
                              color: const Color(0xFFF6F6F6),
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ActionsScreen(dream: dream),
                                    ),
                                  );
                                  _loadDreams();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      // Emoji
                                      Container(
                                        width: 50,
                                        height: 50,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          dream.emoji ?? '✨',
                                          style: const TextStyle(fontSize: 24),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              dream.shortDescription ?? dream.title,
                                              style: GoogleFonts.archivo(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            // Progress Bar
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(4),
                                                  child: LinearProgressIndicator(
                                                    value: dream.progress,
                                                    backgroundColor: Colors.grey.shade300,
                                                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3A8D8F)),
                                                    minHeight: 6,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${dream.completedActionsCount}/${dream.microActions.length} actions',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                                    ],
                                  ),
                                ),
                              ),
                            );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
