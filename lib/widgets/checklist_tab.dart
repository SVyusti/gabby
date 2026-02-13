import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/micro_action.dart';
import '../models/dream_phase.dart';
import '../widgets/action_tile.dart';

class ChecklistTab extends StatefulWidget {
  final List<MicroAction> microActions;
  final List<DreamPhase> phases;
  final Function(int) onToggle;
  final Function(int) onDelete;
  final Function(int) onEdit;
  final VoidCallback onAddAction;

  const ChecklistTab({
    super.key,
    required this.microActions,
    this.phases = const [],
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
    required this.onAddAction,
  });

  @override
  State<ChecklistTab> createState() => _ChecklistTabState();
}

class _ChecklistTabState extends State<ChecklistTab> {
  @override
  Widget build(BuildContext context) {
    if (widget.microActions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.checklist, size: 64, color: Color(0xFFE75480)),
            const SizedBox(height: 16),
            const Text(
              'No action items yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text('Generate a plan to get started'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: widget.onAddAction,
              icon: const Icon(Icons.add),
              label: const Text('Add Action'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE75480),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    // Group actions by phase
    final Map<int, List<int>> groupedIndices = {};
    for (int i = 0; i < widget.microActions.length; i++) {
        final action = widget.microActions[i];
        final phase = action.phase ?? 1;
        groupedIndices.putIfAbsent(phase, () => []).add(i);
    }
    
    // Convert to sorted entries (Phase 1, 2, 3...)
    final sortedPhases = groupedIndices.keys.toList()..sort();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final phaseNum in sortedPhases) ...[
             _buildPhaseHeader(phaseNum),
             const SizedBox(height: 12),
             ...groupedIndices[phaseNum]!.map((index) {
                final action = widget.microActions[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ActionTile(
                    action: action,
                    onToggle: () => widget.onToggle(index),
                    onDelete: () => widget.onDelete(index),
                    onEdit: () => widget.onEdit(index),
                  ).animate().fadeIn().slideX(begin: 0.1, end: 0),
                );
             }),
             const SizedBox(height: 24),
          ],
          
          // Add Action Button at global bottom for now, or per phase?
          // User request didn't specify, but global 'add' button exists in parent FAB.
        ],
      ),
    );
  }

  Widget _buildPhaseHeader(int phaseNum) {
    DreamPhase? phaseInfo;
    try {
      phaseInfo = widget.phases.firstWhere((p) => p.phaseNumber == phaseNum);
    } catch (_) {}

    final title = phaseInfo?.title ?? 'Phase $phaseNum';
    final icon = phaseInfo?.icon ?? '${phaseNum}️⃣';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F4), // Light tealish/grey
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.archivo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF3A8D8F),
            ),
          ),
        ],
      ),
    );
  }

}
