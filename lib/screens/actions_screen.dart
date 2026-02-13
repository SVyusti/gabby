import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/dream.dart';
import '../models/micro_action.dart';
import '../models/itinerary_item.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/action_tile.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/itinerary_tab.dart';
import '../widgets/checklist_tab.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/dream_phase.dart';
import 'dashboard_screen.dart';
import 'dream_settings_screen.dart';

class ActionsScreen extends StatefulWidget {
  final Dream dream;
  final bool isNew;

  const ActionsScreen({
    super.key,
    required this.dream,
    this.isNew = false,
  });

  @override
  State<ActionsScreen> createState() => _ActionsScreenState();
}

class _ActionsScreenState extends State<ActionsScreen> with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late Dream _dream;
  late PageController _pageController;
  late TabController _tabController;
  int _selectedPhase = 1;


  @override
  void initState() {
    super.initState();
    _dream = widget.dream;
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _tabController = TabController(length: 2, vsync: this);
    _pageController = PageController(initialPage: 0);
    if (widget.isNew) {
      _saveDream();
    }
  }
  


  Future<void> _saveDream() async {
    if (widget.isNew) {
      await StorageService.addDream(_dream);
    } else {
      await StorageService.updateDream(_dream);
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _toggleAction(int index) {
    setState(() {
      _dream.microActions[index].isCompleted = !_dream.microActions[index].isCompleted;
      if (_dream.microActions[index].isCompleted) {
        _confettiController.play();
      }
    });
    _saveDream();
  }

  void _deleteAction(int index) {
    setState(() {
      _dream.microActions.removeAt(index);
    });
    _saveDream();
  }

  void _editAction(int index) {
    final controller = TextEditingController(text: _dream.microActions[index].title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Action'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Action title'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _dream.microActions[index].title = controller.text;
              });
              _saveDream();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }



  void _addItineraryItemForDay(int day) {
    final placeController = TextEditingController();
    final descriptionController = TextEditingController();
    final openingTimeController = TextEditingController();
    final closingTimeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add place for Day $day'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: placeController,
                decoration: const InputDecoration(
                  hintText: 'Place/Location',
                  labelText: 'Place',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Description (optional)',
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: openingTimeController,
                decoration: const InputDecoration(
                  hintText: 'e.g., 09:00 AM',
                  labelText: 'Opening Time (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: closingTimeController,
                decoration: const InputDecoration(
                  hintText: 'e.g., 05:30 PM',
                  labelText: 'Closing Time (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (placeController.text.isNotEmpty) {
                setState(() {
                  _dream.itineraryItems.add(
                    ItineraryItem(
                      dreamId: _dream.id,
                      day: day,
                      place: placeController.text,
                      description: descriptionController.text.isEmpty ? null : descriptionController.text,
                      openingTime: openingTimeController.text.isEmpty ? null : openingTimeController.text,
                      closingTime: closingTimeController.text.isEmpty ? null : closingTimeController.text,
                    ),
                  );
                });
                _saveDream();
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a place')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _openSettings() async {
    final updatedDream = await Navigator.of(context).push<Dream>(
      MaterialPageRoute(
        builder: (_) => DreamSettingsScreen(dream: _dream),
      ),
    );

    if (updatedDream != null) {
      setState(() {
        _dream = updatedDream;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildPhasedChecklist(),
              ),
            ],
          ),
          IgnorePointer(
            child: ConfettiOverlay(controller: _confettiController),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCustomAction,
        backgroundColor: const Color(0xFFFC4566),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(120),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 33),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 240, 
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/dream_screen_header_bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 20),
        decoration: const BoxDecoration(
          color: Color.fromRGBO(96, 49, 58, 0.40), // Overlay color
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCircleButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildCircleButton(
                    icon: Icons.more_vert,
                    onTap: _openSettings,
                  ),
                ],
              ),
              const Spacer(),
              // Title and Itinerary Card
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      _dream.title,
                      style: GoogleFonts.bricolageGrotesque(
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2), // Semi-transparent
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  Widget _buildPhasedChecklist() {
    // Phase Selector
    return Column(
      children: [
        const SizedBox(height: 16),
        // Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              for (int i = 0; i < 4; i++) ...[
                Builder(
                  builder: (context) {
                    final phaseNum = i + 1;
                    final isSelected = _selectedPhase == phaseNum;
                    return GestureDetector(
                      onTap: () {
                         setState(() => _selectedPhase = phaseNum);
                         _pageController.animateToPage(
                           i, 
                           duration: const Duration(milliseconds: 300), 
                           curve: Curves.easeInOut
                         );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFC4566) : const Color(0xFFF6F6F6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Phase - $phaseNum',
                          style: GoogleFonts.archivo(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    );
                  }
                ),
                // Add separator line if not the last item
                if (i < 3)
                  Container(
                    width: 16,
                    height: 1.65,
                    color: const Color(0xFFD9D9D9),
                  ),
              ],
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Phase Content PageView
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: 4,
            onPageChanged: (index) {
              setState(() {
                _selectedPhase = index + 1;
              });
            },
            itemBuilder: (context, index) {
              return _buildPhaseTasks(index + 1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPhaseTasks(int phaseNum) {
    // Get phase info
    final phases = _dream.phases;
    final phaseInfo = phases.firstWhere(
      (p) => p.phaseNumber == phaseNum,
      orElse: () => DreamPhase(phaseNumber: phaseNum, title: 'Tasks', icon: '📝'),
    );

    // Filter actions
    final actions = _dream.microActions.where((a) => (a.phase ?? 1) == phaseNum).toList();
    final completedCount = actions.where((a) => a.isCompleted).length;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      children: [
        // Header: Title and Count
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // Icon (Emoji or Image?)
                // Screenshot shows a document icon? Or just emoji.
                // We have phaseInfo.icon (emoji).
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(phaseInfo.icon, style: const TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 8),
                Text(
                  phaseInfo.title,
                  style: GoogleFonts.archivo(
                    fontSize: 18, // Slightly bigger for section title
                    fontWeight: FontWeight.w600,
                    color: Colors.black, // #000
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.blue, // Dashed blue? Simple underline for now.
                    decorationStyle: TextDecorationStyle.dashed,
                  ),
                ),
              ],
            ),
            Text(
              '$completedCount/${actions.length}',
              style: GoogleFonts.archivo(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        if (actions.isEmpty)
          Center(
              child: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Text(
              'No tasks for this phase yet.',
              style: GoogleFonts.inter(color: Colors.grey),
            ),
          )),

        // List of Actions
        ...actions.asMap().entries.map((entry) {
          final index = _dream.microActions.indexOf(entry.value); // Action index in real list
          final action = entry.value;
          return _buildActionCard(action, index);
        }),
        
        const SizedBox(height: 100), // Action button space
      ],
    );
  }

  Widget _buildActionCard(MicroAction action, int realIndex) {
    return ActionCard(
      action: action, 
      onToggle: () => _toggleAction(realIndex),
    );
  }


  void _addCustomAction() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Action'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'What\'s the next step?'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                 // Determine current phase or append to last?
                 // Default to current selected phase
                 int currentPhase = _selectedPhase;
                 
                 setState(() {
                  _dream.microActions.add(
                    MicroAction(
                      dreamId: _dream.id,
                      title: controller.text,
                      order: _dream.microActions.length,
                      phase: currentPhase,
                    ),
                  );
                });
                _saveDream();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class ActionCard extends StatefulWidget {
  final MicroAction action;
  final VoidCallback onToggle;

  const ActionCard({
    super.key,
    required this.action,
    required this.onToggle,
  });

  @override
  State<ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<ActionCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(58, 141, 143, 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: widget.onToggle,
                child: Container(
                  margin: const EdgeInsets.only(top: 2), // Align with text
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: widget.action.isCompleted ? const Color(0xFFFC4566) : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: widget.action.isCompleted ? const Color(0xFFFC4566) : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: widget.action.isCompleted 
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Expanded(
                           child: Text(
                            widget.action.title,
                            style: GoogleFonts.archivo(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              decoration: widget.action.isCompleted ? TextDecoration.lineThrough : null,
                            ),
                                                   ),
                         ),
                         if (widget.action.deadline != null) ...[
                           const SizedBox(width: 8),
                           Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                               decoration: BoxDecoration(
                                 color: const Color(0xFFE0E0E0).withOpacity(0.5), 
                                 borderRadius: BorderRadius.circular(12),
                               ),
                               child: Row(
                                 mainAxisSize: MainAxisSize.min,
                                 children: [
                                   Image.asset(
                                     'assets/calendar-filled.png',
                                     width: 12,
                                     height: 12,
                                     color: const Color(0xFF2F7D7A),
                                   ),
                                   const SizedBox(width: 4),
                                   Text(
                                     DateFormat('d MMM').format(widget.action.deadline!),
                                     style: GoogleFonts.archivo(
                                       color: const Color(0xFF2F7D7A),
                                       fontSize: 10,
                                       fontWeight: FontWeight.w500,
                                     ),
                                   ),
                                 ],
                               ),
                            ),
                         ],
                       ],
                     ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          // Learn More Expander
           GestureDetector(
             onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
             },
             child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(47, 125, 122, 0.10),
                  borderRadius: BorderRadius.circular(102),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                       _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, 
                       size: 16, 
                       color: const Color(0xFF2F7D7A),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isExpanded ? 'Hide' : 'Learn more', 
                      style: GoogleFonts.archivo(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF2F7D7A),
                        height: 21.23 / 12, // line-height / font-size
                      ),
                    ),
                  ],
                ),
             ),
           ),
          
          if (_isExpanded) ...[
             const SizedBox(height: 12),
             Text(
               widget.action.description,
               style: GoogleFonts.inter(
                 fontSize: 13,
                 color: Colors.grey.shade700,
                 height: 1.4,
               ),
             ).animate().fadeIn(),
          ],
        ],
      ),
    );
  }
}
