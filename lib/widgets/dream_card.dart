import 'package:flutter/material.dart';
import '../models/dream.dart';
import '../theme/app_theme.dart';

class DreamCard extends StatelessWidget {
  final Dream dream;
  final VoidCallback onTap;

  const DreamCard({
    super.key,
    required this.dream,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      dream.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (dream.isCompleted)
                    const Icon(Icons.check_circle, color: AppTheme.successGreen),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: dream.progress,
                  backgroundColor: AppTheme.softPink.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    dream.isCompleted ? AppTheme.successGreen : AppTheme.primaryPink,
                  ),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(dream.completedActionsCount + dream.completedItemsCount)}/${dream.totalItemsCount} completed',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.deepPlum.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
