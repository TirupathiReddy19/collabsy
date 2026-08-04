import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_text_field.dart';

/// A tap-to-open, search-to-filter picker for long lists (e.g. India's
/// states) — Flutter has no built-in equivalent of a searchable dropdown.
class SearchableDropdownField extends StatelessWidget {
  const SearchableDropdownField({
    super.key,
    required this.label,
    required this.items,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final List<String> items;
  final String? selected;
  final ValueChanged<String> onChanged;
  final bool enabled;

  Future<void> _openPicker(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      builder: (context) => _SearchableList(label: label, items: items),
    );
    if (result != null) onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
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
              selected ?? 'Select $label',
              style: AppTextStyles.bodyLarge.copyWith(
                color: selected == null
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

class _SearchableList extends StatefulWidget {
  const _SearchableList({required this.label, required this.items});

  final String label;
  final List<String> items;

  @override
  State<_SearchableList> createState() => _SearchableListState();
}

class _SearchableListState extends State<_SearchableList> {
  final _searchController = TextEditingController();
  late List<String> _filtered = widget.items;

  void _onSearchChanged(String query) {
    setState(() {
      _filtered = widget.items
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
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
      initialChildSize: 0.7,
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
            Text('Select ${widget.label}', style: AppTextStyles.titleLarge),
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
                  return ListTile(
                    title: Text(item, style: AppTextStyles.bodyLarge),
                    onTap: () => Navigator.of(context).pop(item),
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
