import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Bouton retour unique de l'app (leading d'AppBar des écrans poussés).
/// Revient en arrière, ou retombe sur /home si la pile est vide
/// (deep link). Variante [close] pour les flux type formulaire.
class AppBackButton extends StatelessWidget {
  final bool close;

  const AppBackButton({super.key, this.close = false});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: close ? 'Fermer' : 'Retour',
      child: GestureDetector(
        onTap: () => context.canPop() ? context.pop() : context.go('/home'),
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppSpacing.md),
          ),
          child: Icon(
            close ? Icons.close_rounded : Icons.arrow_back_rounded,
            size: 20,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
