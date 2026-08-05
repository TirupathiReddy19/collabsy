import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Optional-reason prompt shown before suspending a Creator or Brand
/// account — pops the typed reason (possibly empty) on confirm, or `null`
/// if cancelled. Shared between the Creator and Brand detail screens.
class SuspendAccountDialog extends StatefulWidget {
  const SuspendAccountDialog({super.key});

  @override
  State<SuspendAccountDialog> createState() => _SuspendAccountDialogState();
}

class _SuspendAccountDialogState extends State<SuspendAccountDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Suspend this account?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "They won't be able to sign in until you reinstate them. This "
            'is reversible.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Reason (optional, visible to them)',
            ),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: const Text('Suspend'),
        ),
      ],
    );
  }
}
