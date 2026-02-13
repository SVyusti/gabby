import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TripDateRangeInput extends StatefulWidget {
  final Function(String startDate, String endDate, int duration) onChanged;
  final String? initialValue;

  const TripDateRangeInput({
    super.key,
    required this.onChanged,
    this.initialValue,
  });

  @override
  State<TripDateRangeInput> createState() => _TripDateRangeInputState();
}

class _TripDateRangeInputState extends State<TripDateRangeInput> {
  DateTimeRange? _selectedDateRange;

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE75480),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF3D3D3D),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
      
      final startDate = DateFormat('MMM d, yyyy').format(picked.start);
      final endDate = DateFormat('MMM d, yyyy').format(picked.end);
      final duration = picked.duration.inDays + 1;
      
      widget.onChanged(startDate, endDate, duration);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_selectedDateRange != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5E6F0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE75480), width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trip Duration',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF7B5BA1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${DateFormat('MMM d').format(_selectedDateRange!.start)} - ${DateFormat('MMM d, yyyy').format(_selectedDateRange!.end)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF3D3D3D),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_selectedDateRange!.duration.inDays + 1} days',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF7B5BA1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _pickDateRange,
            icon: const Icon(Icons.calendar_today),
            label: Text(_selectedDateRange == null ? 'Select Trip Dates' : 'Change Dates'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE75480),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
