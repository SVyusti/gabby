import 'package:flutter/material.dart';
import '../models/micro_action.dart';
import '../theme/app_theme.dart';

class ActionTile extends StatelessWidget {
  final MicroAction action;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ActionTile({
    super.key,
    required this.action,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(action.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.withValues(alpha: 0.1),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    value: action.isCompleted,
                    onChanged: (_) => onToggle(),
                    shape: const CircleBorder(),
                    activeColor: AppTheme.successGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          decoration: action.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: action.isCompleted
                              ? AppTheme.deepPlum.withValues(alpha: 0.5)
                              : AppTheme.deepPlum,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
