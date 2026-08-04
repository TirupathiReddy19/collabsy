import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Full-page multi-select picker (as opposed to showing every option inline
/// on the calling screen) — pushed via `Navigator.push`, returns the
/// selected set on "Done", or null if backed out without confirming.
class MultiSelectPickerScreen extends StatefulWidget {
  const MultiSelectPickerScreen({
    super.key,
    required this.title,
    required this.options,
    required this.initialSelected,
  });

  final String title;
  final List<String> options;
  final Set<String> initialSelected;

  @override
  State<MultiSelectPickerScreen> createState() =>
      _MultiSelectPickerScreenState();
}

class _MultiSelectPickerScreenState extends State<MultiSelectPickerScreen> {
  late final Set<String> _selected = {...widget.initialSelected};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(_selected),
            child: const Text('Done'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.options.map((option) {
                final selected = _selected.contains(option);
                return FilterChip(
                  label: Text(option),
                  selected: selected,
                  onSelected: (value) => setState(() {
                    if (value) {
                      _selected.add(option);
                    } else {
                      _selected.remove(option);
                    }
                  }),
                  selectedColor: AppColors.primaryLight,
                  checkmarkColor: AppColors.primary,
                  labelStyle: AppTextStyles.bodySmall.copyWith(
                    color: selected
                        ? AppColors.primaryDark
                        : AppColors.textSecondary,
                  ),
                  backgroundColor: AppColors.surface,
                  side: BorderSide(
                    color: selected ? AppColors.primary : AppColors.border,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
