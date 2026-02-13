import 'package:flutter/material.dart';

class PreferencesInput extends StatefulWidget {
  final Function(List<String> preferences) onChanged;
  final List<String>? initialValue;

  const PreferencesInput({
    super.key,
    required this.onChanged,
    this.initialValue,
  });

  @override
  State<PreferencesInput> createState() => _PreferencesInputState();
}

class _PreferencesInputState extends State<PreferencesInput> {
  final List<String> _defaultPreferences = [
    'Adventure',
    'Beach & Water',
    'Cultural',
    'Food & Dining',
    'History',
    'Hiking',
    'Shopping',
    'Nature',
    'Nightlife',
    'Relaxation',
    'Sports',
    'Photography',
  ];

  late List<String> _selectedPreferences;
  final TextEditingController _customController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedPreferences = widget.initialValue?.toList() ?? [];
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _togglePreference(String preference) {
    setState(() {
      if (_selectedPreferences.contains(preference)) {
        _selectedPreferences.remove(preference);
      } else {
        _selectedPreferences.add(preference);
      }
    });
    widget.onChanged(_selectedPreferences);
  }

  void _addCustomPreference() {
    if (_customController.text.isNotEmpty) {
      final custom = _customController.text;
      if (!_selectedPreferences.contains(custom)) {
        setState(() {
          _selectedPreferences.add(custom);
        });
        widget.onChanged(_selectedPreferences);
      }
      _customController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Your Interests & Activities',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: const Color(0xFF7B5BA1),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _defaultPreferences.map((preference) {
            final isSelected = _selectedPreferences.contains(preference);
            return FilterChip(
              label: Text(preference),
              selected: isSelected,
              onSelected: (_) => _togglePreference(preference),
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFFE75480),
              side: BorderSide(
                color: isSelected ? const Color(0xFFE75480) : const Color(0x000ffddd),
                width: 2,
              ),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF3D3D3D),
                fontWeight: FontWeight.w600,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Text(
          'Add Custom Interest',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: const Color(0xFF7B5BA1),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _customController,
                decoration: InputDecoration(
                  hintText: 'e.g., Wine tasting, Yoga...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFFE75480),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => _addCustomPreference(),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _addCustomPreference,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE75480),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_selectedPreferences.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Selected (${_selectedPreferences.length})',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF7B5BA1),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedPreferences.map((preference) {
              return Chip(
                label: Text(preference),
                onDeleted: () => _togglePreference(preference),
                backgroundColor: const Color(0xFFF5E6F0),
                labelStyle: const TextStyle(
                  color: Color(0xFFE75480),
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
