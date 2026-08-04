import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

/// A row of single-digit boxes for OTP entry — auto-advances on input,
/// supports paste-to-fill, and moves focus back on backspace.
class OtpInput extends StatefulWidget {
  const OtpInput({
    super.key,
    this.length = 6,
    required this.onCompleted,
    this.onChanged,
    this.autofocus = true,
    this.enabled = true,
  });

  final int length;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final bool enabled;

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _notify() {
    final code = _code;
    widget.onChanged?.call(code);
    if (code.length == widget.length) {
      widget.onCompleted(code);
    }
  }

  void _handleChanged(int index, String value) {
    if (value.length > 1) {
      // Pasted content — distribute digits across remaining boxes.
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (var i = 0; i < digits.length && index + i < widget.length; i++) {
        _controllers[index + i].text = digits[i];
      }
      final nextIndex = (index + digits.length).clamp(0, widget.length - 1);
      _focusNodes[nextIndex].requestFocus();
      _notify();
      return;
    }

    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    _notify();
  }

  void _handleKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
      _notify();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        return SizedBox(
          width: 48,
          height: 56,
          child: KeyboardListener(
            focusNode: FocusNode(skipTraversal: true),
            onKeyEvent: (event) => _handleKeyEvent(index, event),
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              enabled: widget.enabled,
              autofocus: widget.autofocus && index == 0,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: widget.length,
              style: AppTextStyles.heading2,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: _controllers[index].text.isNotEmpty
                    ? AppColors.primaryLight
                    : AppColors.surface,
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide(
                    color: _controllers[index].text.isNotEmpty
                        ? AppColors.primary
                        : AppColors.border,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
              onChanged: (value) {
                _handleChanged(index, value);
                setState(() {});
              },
            ),
          ),
        );
      }),
    );
  }
}
