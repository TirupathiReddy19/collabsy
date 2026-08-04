import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_text_field.dart';

/// A tap-to-open, search-to-filter, multi-select picker for long lists (e.g.
/// India's states) — same shell as [SearchableDropdownField] but returns a
/// set of choices instead of one.
///
/// [exclusiveOption], if given, behaves like "All India": selecting it clears
/// every other selection, and selecting anything else clears it.
class SearchableMultiSelectField extends StatelessWidget {
  const SearchableMultiSelectField({
    super.key,
    required this.label,
    required this.items,
    required this.selected,
    required this.onChanged,
    this.exclusiveOption,
    this.enabled = true,
  });

  final String label;
  final List<String> items;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;
  final String? exclusiveOption;
  final bool enabled;

  Future<void> _openPicker(BuildContext context) async {
    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      builder: (context) => _MultiSelectList(
        label: label,
        items: items,
        initialSelected: selected,
        exclusiveOption: exclusiveOption,
      ),
    );
    if (result != null) onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    final displayText = selected.isEmpty
        ? 'Select $label'
        : selected.join(', ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        InkWell(
          onTap: enabled ? () => _openPicker(context) : null,
          borderRadius: AppBorderRadius.lg,
          child: InputDecorator(
            decoration: const InputDecoration(
              suffixIcon: Icon(Icons.keyboard_arrow_down),
            ),
            child: Text(
              displayText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyLarge.copyWith(
                color: selected.isEmpty
                    ? AppColors.textHint
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MultiSelectList extends StatefulWidget {
  const _MultiSelectList({
    required this.label,
    required this.items,
    required this.initialSelected,
    required this.exclusiveOption,
  });

  final String label;
  final List<String> items;
  final Set<String> initialSelected;
  final String? exclusiveOption;

  @override
  State<_MultiSelectList> createState() => _MultiSelectListState();
}

class _MultiSelectListState extends State<_MultiSelectList> {
  final _searchController = TextEditingController();
  late Set<String> _selected = {...widget.initialSelected};
  late List<String> _filtered = widget.items;

  void _onSearchChanged(String query) {
    setState(() {
      _filtered = widget.items
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _toggle(String item) {
    setState(() {
      if (widget.exclusiveOption != null && item == widget.exclusiveOption) {
        _selected = {item};
        return;
      }
      _selected.remove(widget.exclusiveOption);
      if (_selected.contains(item)) {
        _selected.remove(item);
      } else {
        _selected.add(item);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.screenHorizontal,
          right: AppSpacing.screenHorizontal,
          top: AppSpacing.md,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Select ${widget.label}',
                    style: AppTextStyles.titleLarge,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(_selected),
                  child: const Text('Done'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _searchController,
              hintText: 'Search ${widget.label.toLowerCase()}...',
              prefixIcon: const Icon(Icons.search),
              autofocus: true,
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final item = _filtered[index];
                  final checked = _selected.contains(item);
                  return CheckboxListTile(
                    value: checked,
                    onChanged: (_) => _toggle(item),
                    title: Text(item, style: AppTextStyles.bodyLarge),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primary,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
