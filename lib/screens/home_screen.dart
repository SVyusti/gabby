import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/dream.dart';
import '../models/dream_phase.dart';
import '../models/micro_action.dart';
import '../models/micro_action.dart';
import '../services/storage_service.dart';
import 'write_dream_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Dream> _dreams = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadDreams();
  }

  Future<void> _loadDreams() async {
    final dreams = await StorageService.loadDreams();
    if (mounted) {
      setState(() {
        _dreams = dreams;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleTaskFull(Dream dream, MicroAction action) async {
    setState(() {
       action.isCompleted = !action.isCompleted;
    });
    await StorageService.updateDream(dream);
  }

  @override
  Widget build(BuildContext context) {
    // 1. Filter Tasks
    List<Map<String, dynamic>> visibleTasks = [];
    int completedTasks = 0;
    int totalTasks = 0;

    // Calculate generic stats and filter
    for (var dream in _dreams) {
       // Filter logic
       final dreamLabel = dream.shortDescription ?? dream.title;
       bool isVisible = (_selectedFilter == 'All' || dreamLabel == _selectedFilter);
       
       for (var action in dream.microActions) {
         if (isVisible) {
            String phaseTitle = 'Phase ${action.phase}';
            final phaseObj = dream.phases.firstWhere(
              (p) => p.phaseNumber == action.phase,
              orElse: () => DreamPhase(phaseNumber: action.phase, title: phaseTitle, icon: '✨'),
            );
            
            visibleTasks.add({
              'action': action,
              'dream': dream,
              'title': action.title,
              'tag': dreamLabel,
              'icon': dream.emoji ?? '✨',
              'phase': phaseObj.title, // Use title from phase object
            });
          }
       }
    }
    
    // Sort logic: Nearest deadline first
    visibleTasks.sort((a, b) {
      final actionA = a['action'] as MicroAction;
      final actionB = b['action'] as MicroAction;
      
      // Put completed last? User didn't ask, but good UX. 
      // User asked: "show me the task which are most nearest to due date"
      // If deadlines exist, closest one (including past) is "nearest". 
      // Usually "due date" implies upcoming.
      
      if (actionA.deadline != null && actionB.deadline != null) {
        return actionA.deadline!.compareTo(actionB.deadline!);
      } else if (actionA.deadline != null) {
        return -1; // A has deadline, comes first
      } else if (actionB.deadline != null) {
        return 1; // B has deadline, comes first
      }
      return 0;
    });
    
    totalTasks = visibleTasks.length;
    completedTasks = visibleTasks.where((t) => (t['action'] as MicroAction).isCompleted).length;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const WriteDreamScreen()),
          );
          _loadDreams(); // Reload after coming back
        },
        elevation: 0,
        backgroundColor: const Color(0xFFFC4566),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(200),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 33,),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Bottom Right
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
                          // Left: Today
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Today',
                                style: GoogleFonts.bricolageGrotesque(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  
                                ),
                              ),
                            ],
                          ),
                          // Right: Number of tasks
                          Text(
                            '$completedTasks/$totalTasks',
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
          
          const SizedBox(height: 10),
          
          // Dreams Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                 // "All" Filter Option
                _buildFilterTab(
                  title: 'All', 
                  emoji: '🦄',
                  isSelected: _selectedFilter == 'All',
                  onTap: () => setState(() => _selectedFilter = 'All'),
                ),
                // Real Dreams
                ..._dreams.map((dream) {
                  final dreamLabel = dream.shortDescription ?? dream.title;
                  return _buildFilterTab(
                    title: dreamLabel,
                    // Use dream emoji or fallback
                    emoji: dream.emoji ?? '✨',
                    isSelected: _selectedFilter == dreamLabel,
                    onTap: () {
                      setState(() {
                        _selectedFilter = dreamLabel;
                      });
                    },
                  );
                }),
              ],
            ),
          ),
          
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : visibleTasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.bedtime_off_outlined, size: 48, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'No dreams active yet.',
                            style: GoogleFonts.inter(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 45, bottom: 80),
                      itemCount: visibleTasks.length,
                      separatorBuilder: (c, i) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                         final item = visibleTasks[index];
                         return _buildTaskCard(
                           title: item['title'],
                           tag: item['tag'],
                           icon: item['icon'],
                           phase: item['phase'],
                           action: item['action'],
                           dream: item['dream'],
                         );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab({
      required String title,
      required String emoji,
      required bool isSelected,
      required VoidCallback onTap,
    }) {
      // Truncate logic: only add 2 words if too big
      String label = title;
      if (label.split(' ').length > 2) {
        label = label.split(' ').take(2).join(' ');
      }
      
      return Padding(
        padding: const EdgeInsets.only(right: 12),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 30,
            padding: isSelected 
                ? const EdgeInsets.only(left: 8, right: 16)
                : const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFC4566) : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
                bottomLeft: Radius.circular(24),
              ),
              border: Border.all(
                color: isSelected ? const Color(0xFFFC4566) : Colors.grey.shade200,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon (Emoji) always visible
                Text(
                  emoji, 
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 6),
                // Text
                Text(
                  label,
                  style: GoogleFonts.archivo( 
                    color: isSelected ? Colors.white : const Color(0xFF87898A),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 21.23 / 12.738,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

  Widget _buildTaskCard({
    required String title,
    required String tag,
    required String icon,
    required String phase,
    required MicroAction action,
    required Dream dream,
  }) {
    return GestureDetector(
      onTap: () => _toggleTaskFull(dream, action),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0x143A8D8F),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: action.isCompleted ? const Color(0xFF3A8D8F) : Colors.transparent,
                border: Border.all(color: action.isCompleted ? const Color(0xFF3A8D8F) : Colors.grey.shade400, width: 2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: action.isCompleted 
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.archivo(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            decoration: action.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0x1A3A8D8F), // Slightly darker/different opacity for tag
                              borderRadius: BorderRadius.circular(800),
                            ),
                            child: Text(
                              phase,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF3A8D8F),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0x1A3A8D8F),
                      borderRadius: BorderRadius.circular(800),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(icon, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          tag,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF3A8D8F),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (action.deadline != null) ...[
                     const SizedBox(height: 8),
                     Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                         decoration: BoxDecoration(
                           color: const Color(0xFFE0E0E0).withOpacity(0.5), 
                           borderRadius: BorderRadius.circular(12),
                         ),
                         child: Row(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             const Icon(Icons.calendar_today, size: 12, color: Color(0xFF2F7D7A)),
                             const SizedBox(width: 4),
                             Text(
                               DateFormat('d MMM').format(action.deadline!),
                               style: GoogleFonts.archivo(
                                 color: const Color(0xFF2F7D7A),
                                 fontSize: 10,
                                 fontWeight: FontWeight.w500,
                               ),
                             ),
                           ],
                         ),
                      ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
