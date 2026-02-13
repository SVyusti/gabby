import 'package:flutter/material.dart';

class BudgetInput extends StatefulWidget {
  final Function(String budget) onChanged;
  final String? initialValue;

  const BudgetInput({
    super.key,
    required this.onChanged,
    this.initialValue,
  });

  @override
  State<BudgetInput> createState() => _BudgetInputState();
}

class _BudgetInputState extends State<BudgetInput> {
  final TextEditingController _budgetController = TextEditingController();
  String? _selectedRange;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _budgetController.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  void _updateBudget() {
    if (_budgetController.text.isNotEmpty) {
      widget.onChanged(_budgetController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Budget Range',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: const Color(0xFF7B5BA1),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _budgetChip('Under \$1,000', 'Under \$1,000'),
            _budgetChip('\$1,000 - \$3,000', '\$1,000 - \$3,000'),
            _budgetChip('\$3,000 - \$5,000', '\$3,000 - \$5,000'),
            _budgetChip('\$5,000 - \$10,000', '\$5,000 - \$10,000'),
            _budgetChip('\$10,000+', '\$10,000+'),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _budgetController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'Enter total budget amount (optional)',
            prefixText: '\$ ',
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
          ),
          onChanged: (_) => _updateBudget(),
        ),
      ],
    );
  }

  Widget _budgetChip(String label, String value) {
    final isSelected = _selectedRange == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedRange = selected ? value : null;
          _budgetController.text = selected ? value : '';
        });
        _updateBudget();
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFFE75480),
      side: BorderSide(
        color: isSelected ? const Color(0xFFE75480) : const Color(0xFFDDD),
        width: 2,
      ),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF3D3D3D),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
