import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/itinerary_item.dart';
import '../theme/app_theme.dart';
import '../services/gemini_service.dart';

class ItineraryTab extends StatefulWidget {
  final List<ItineraryItem> itineraryItems;
  final Function(int) onToggleComplete;
  final Function(int) onDelete;
  final Function(int)? onAddItemForDay; // Add parameter for adding to specific day
  final VoidCallback onAddItem;

  const ItineraryTab({
    super.key,
    required this.itineraryItems,
    required this.onToggleComplete,
    required this.onDelete,
    this.onAddItemForDay,
    required this.onAddItem,
  });

  @override
  State<ItineraryTab> createState() => _ItineraryTabState();
}

class _ItineraryTabState extends State<ItineraryTab> {
  @override
  Widget build(BuildContext context) {
    if (widget.itineraryItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on, size: 64, color: Color(0xFFE75480)),
            const SizedBox(height: 16),
            const Text(
              'No itinerary yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text('Create your day-wise travel plan'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: widget.onAddItem,
              icon: const Icon(Icons.add),
              label: const Text('Add First Stop'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE75480),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    // Group itinerary items by day
    final groupedByDay = <int, List<ItineraryItem>>{};
    for (var item in widget.itineraryItems) {
      groupedByDay.putIfAbsent(item.day, () => []).add(item);
    }

    final sortedDays = groupedByDay.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDays.length,
      itemBuilder: (context, dayIndex) {
        final day = sortedDays[dayIndex];
        final itemsForDay = groupedByDay[day]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Day $day',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.deepPlum,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Color(0xFFE75480)),
                    onPressed: widget.onAddItemForDay != null
                        ? () => widget.onAddItemForDay!(day)
                        : null,
                    tooltip: 'Add place for this day',
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                ],
              ),
            ),
            ...itemsForDay.asMap().entries.map((entry) {
              final itemIndex = entry.key;
              final item = entry.value;
              final actualIndex = widget.itineraryItems.indexOf(item);

              return _buildItineraryItem(
                context,
                item,
                actualIndex,
                dayIndex + itemIndex,
              );
            }),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  Widget _buildItineraryItem(
    BuildContext context,
    ItineraryItem item,
    int actualIndex,
    int animationIndex,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: item.isCompleted ? const Color(0xFFF0F0F0) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.isCompleted ? const Color(0x000ffccc) : const Color(0xFFE75480),
          width: 2,
        ),
      ),
      child: ListTile(
        leading: Checkbox(
          value: item.isCompleted,
          onChanged: (_) => widget.onToggleComplete(actualIndex),
          activeColor: const Color(0xFFE75480),
        ),
        title: Text(
          item.place,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: item.isCompleted ? const Color(0xFF4A4A4A) : const Color(0xFF3D3D3D),
            decoration: item.isCompleted ? TextDecoration.lineThrough : null,
            decorationColor: const Color(0xFF4A4A4A),
            decorationThickness: 2,
          ),
        ),
        subtitle: item.description != null && item.description!.isNotEmpty
            ? Text(
          item.description!,
          style: TextStyle(
            color: item.isCompleted ? const Color(0x000ff666) : const Color(0x000ff666),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        )
            : null,
        trailing: SizedBox(
          width: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.info_outline, color: Color(0xFFE75480)),
                onPressed: () => _showDetailsDialog(context, item),
                tooltip: 'View details',
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Color(0xFFE75480)),
                onPressed: () => _showDeleteConfirmation(context, actualIndex),
                tooltip: 'Delete',
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (100 * animationIndex).ms).slideX(begin: 0.2, end: 0);
  }

  void _showDetailsDialog(BuildContext context, ItineraryItem item) {
    final geminiService = GeminiService();
    bool isLoading = true;
    String? description;
    String? openingTime;
    String? closingTime;

    // Fetch details from Gemini
    geminiService.getPlaceDetails(item.place).then((details) {
      description = details['description']?.isNotEmpty == true 
          ? details['description'] 
          : (item.description?.isNotEmpty == true ? item.description : null);
      openingTime = details['openingTime']?.isNotEmpty == true 
          ? details['openingTime'] 
          : (item.openingTime?.isNotEmpty == true ? item.openingTime : null);
      closingTime = details['closingTime']?.isNotEmpty == true 
          ? details['closingTime'] 
          : (item.closingTime?.isNotEmpty == true ? item.closingTime : null);
      isLoading = false;
    }).catchError((e) {
      print('Error fetching details: $e');
      isLoading = false;
    });

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          // Fetch details and update state
          if (isLoading) {
            geminiService.getPlaceDetails(item.place).then((details) {
              description = details['description']?.isNotEmpty == true 
                  ? details['description'] 
                  : (item.description?.isNotEmpty == true ? item.description : null);
              openingTime = details['openingTime']?.isNotEmpty == true 
                  ? details['openingTime'] 
                  : (item.openingTime?.isNotEmpty == true ? item.openingTime : null);
              closingTime = details['closingTime']?.isNotEmpty == true 
                  ? details['closingTime'] 
                  : (item.closingTime?.isNotEmpty == true ? item.closingTime : null);
              
              if (context.mounted) {
                setState(() {
                  isLoading = false;
                });
              }
            }).catchError((e) {
              print('Error fetching details: $e');
              if (context.mounted) {
                setState(() {
                  isLoading = false;
                  // Fall back to stored data
                  description = item.description;
                  openingTime = item.openingTime;
                  closingTime = item.closingTime;
                });
              }
            });
          }

          return AlertDialog(
            title: Text(item.place),
            content: SingleChildScrollView(
              child: isLoading
                  ? const SizedBox(
                      height: 80,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFE75480),
                        ),
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (description != null && description!.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Description',
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: AppTheme.deepPlum,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                description!,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        if (openingTime != null && openingTime!.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 18, color: Color(0xFFE75480)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Opens: ',
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      color: AppTheme.deepPlum,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                openingTime!,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        if (openingTime != null && openingTime!.isNotEmpty)
                          const SizedBox(height: 12),
                        if (closingTime != null && closingTime!.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 18, color: Color(0xFFE75480)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Closes: ',
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      color: AppTheme.deepPlum,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                closingTime!,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        if ((description == null || description!.isEmpty) &&
                            (openingTime == null || openingTime!.isEmpty) &&
                            (closingTime == null || closingTime!.isEmpty))
                          Text(
                            'No additional details available',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from Itinerary?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onDelete(index);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE75480),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
