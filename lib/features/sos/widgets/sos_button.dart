import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class SosButton extends StatelessWidget {
  const SosButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => context.push('/sos'),
      backgroundColor: AppColors.danger,
      child: const Icon(Icons.security, color: Colors.white),
    )
    .animate(onPlay: (controller) => controller.repeat())
    .scale(
      duration: 1.5.seconds,
      begin: const Offset(1.0, 1.0),
      end: const Offset(1.15, 1.15),
      curve: Curves.easeInOut,
    )
    .then()
    .scale(
      duration: 1.5.seconds,
      begin: const Offset(1.15, 1.15),
      end: const Offset(1.0, 1.0),
      curve: Curves.easeInOut,
    );
  }
}
