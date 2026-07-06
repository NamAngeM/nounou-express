import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Indicateur de chargement aux couleurs de la charte.
/// À utiliser partout à la place d'un [CircularProgressIndicator] nu.
class AppLoader extends StatelessWidget {
  final double size;

  const AppLoader({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 3,
        ),
      ),
    );
  }
}
