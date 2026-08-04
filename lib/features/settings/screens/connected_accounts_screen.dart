import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/instagram_icon.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../data/instagram_repository.dart';
import '../models/instagram_account.dart';
import '../providers/instagram_providers.dart';
import '../widgets/instagram_oauth_webview_screen.dart';

class ConnectedAccountsScreen extends ConsumerWidget {
  const ConnectedAccountsScreen({super.key});

  Future<void> _connect(BuildContext context, WidgetRef ref) async {
    await ref.read(instagramControllerProvider.notifier).connect(context);
    if (!context.mounted) return;
    _showResult(context, ref, successMessage: 'Instagram connected.');
  }

  Future<void> _disconnect(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect Instagram?'),
        content: const Text(
          "Brands won't see your Instagram stats until you reconnect.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(instagramControllerProvider.notifier).disconnect();
    if (!context.mounted) return;
    _showResult(context, ref, successMessage: 'Instagram disconnected.');
  }

  Future<void> _refresh(BuildContext context, WidgetRef ref) async {
    await ref.read(instagramControllerProvider.notifier).refresh();
    if (!context.mounted) return;
    _showResult(context, ref, successMessage: 'Instagram data refreshed.');
  }

  void _showResult(
    BuildContext context,
    WidgetRef ref, {
    required String successMessage,
  }) {
    final error = ref.read(instagramControllerProvider).error;
    if (error == null) {
      AppSnackbar.showSuccess(context, successMessage);
      return;
    }
    if (error is InstagramAuthCancelledException) return;
    final message = error is InstagramApiException
        ? error.message
        : "Couldn't complete that. Please try again.";
    AppSnackbar.showError(context, message);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountAsync = ref.watch(ownInstagramAccountProvider);
    final isLoading = ref.watch(instagramControllerProvider).isLoading;
    final account = accountAsync.value;
    final isConnected = account?.status == InstagramConnectionStatus.connected;
    final needsReconnect =
        account?.status == InstagramConnectionStatus.expired ||
        account?.status == InstagramConnectionStatus.revoked;

    return Scaffold(
      appBar: AppBar(title: const Text('Connected accounts')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.card),
                child: Row(
                  children: [
                    const InstagramIcon(size: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Instagram', style: AppTextStyles.titleSmall),
                          const SizedBox(height: 2),
                          Text(
                            isConnected
                                ? '@${account?.username ?? ''}'
                                : needsReconnect
                                ? 'Connection expired — reconnect'
                                : 'Not connected',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: needsReconnect
                                  ? AppColors.warning
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isLoading)
                      const LoadingIndicator(size: 20)
                    else if (isConnected) ...[
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () => _refresh(context, ref),
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        onPressed: () => _disconnect(context, ref),
                        child: const Text('Disconnect'),
                      ),
                    ] else
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        onPressed: () => _connect(context, ref),
                        child: Text(needsReconnect ? 'Reconnect' : 'Connect'),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
