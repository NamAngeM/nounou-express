import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../auth/providers/auth_provider.dart';

class DeleteAccountDialog extends ConsumerStatefulWidget {
  const DeleteAccountDialog({super.key});

  @override
  ConsumerState<DeleteAccountDialog> createState() =>
      _DeleteAccountDialogState();

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const DeleteAccountDialog(),
    );
  }
}

class _DeleteAccountDialogState extends ConsumerState<DeleteAccountDialog> {
  bool _isLoading = false;
  String? _error;

  Future<void> _deleteAccount() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(authRepositoryProvider).deleteAccount();
      if (mounted) {
        context.pop(); // Close dialog
        context.go(
          '/onboarding',
        ); // Redirect manually (though router should handle it)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Votre compte a été supprimé.')),
        );
      }
    } catch (e) {
      setState(() {
        _error =
            "Une erreur est survenue lors de la suppression de votre compte. Veuillez réessayer plus tard.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.danger),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              "Supprimer le compte",
              style: AppTypography.h4.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Êtes-vous sûr de vouloir supprimer définitivement votre compte Nounou Express ?\n\nCette action est irréversible. Toutes vos données personnelles, historiques de réservation et profils seront immédiatement et définitivement effacés.",
            style: AppTypography.bodyMedium,
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              _error!,
              style: AppTypography.bodySmall.copyWith(color: AppColors.danger),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => context.pop(),
          child: Text("Annuler", style: AppTypography.buttonLabelSm),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _deleteAccount,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text("Supprimer définitivement"),
        ),
      ],
    );
  }
}
