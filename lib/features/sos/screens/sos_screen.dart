import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen>
    with SingleTickerProviderStateMixin {
  bool _isSent = false;
  double _progress = 0;
  Timer? _timer;
  final int _durationMs = 3000;

  void _startTimer() {
    setState(() => _progress = 0);
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _progress += 50 / _durationMs;
        if (_progress >= 1.0) {
          _progress = 1.0;
          _onComplete();
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    if (!_isSent) {
      setState(() => _progress = 0);
    }
  }

  void _onComplete() {
    _timer?.cancel();
    HapticFeedback.vibrate();
    setState(() => _isSent = true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE63946),
      body: SafeArea(
        child: Stack(
          children: [
            _buildCloseButton(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPulseIcon(),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    "URGENCE SOS",
                    style: AppTypography.h1.copyWith(
                      color: Colors.white,
                      fontSize: 32,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _isSent
                        ? "Alerte envoyée !"
                        : "Appuyez longuement pour envoyer une alerte",
                    style: AppTypography.bodyLarge.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl * 2),
                  _buildSosButton(),
                  if (_isSent) ...[
                    const SizedBox(height: AppSpacing.xl * 2),
                    _buildEmergencyActions(),
                  ],
                  const Spacer(),
                  _buildFooterInfo(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return Positioned(
      top: AppSpacing.md,
      left: AppSpacing.md,
      child: IconButton(
        icon: const Icon(Icons.close, color: Colors.white, size: 28),
        onPressed: () => context.pop(),
      ),
    );
  }

  Widget _buildPulseIcon() {
    return const Icon(Icons.security, color: Colors.white, size: 80)
        .animate(onPlay: (controller) => controller.repeat())
        .scale(
          duration: 1.2.seconds,
          begin: const Offset(1, 1),
          end: const Offset(1.2, 1.2),
          curve: Curves.easeInOut,
        )
        .fadeOut(duration: 1.2.seconds, curve: Curves.easeInOut);
  }

  Widget _buildSosButton() {
    return GestureDetector(
      onLongPressStart: (_) => !_isSent ? _startTimer() : null,
      onLongPressEnd: (_) => _stopTimer(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 8,
              ),
            ),
          ),
          // Progress indicator
          SizedBox(
            width: 160,
            height: 160,
            child: CircularProgressIndicator(
              value: _progress,
              strokeWidth: 8,
              color: Colors.white,
              backgroundColor: Colors.transparent,
            ),
          ),
          // Main Button
          Container(
            width: 140,
            height: 140,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              _isSent ? Icons.check : Icons.warning_rounded,
              color: const Color(0xFFE63946),
              size: 60,
            ),
          ),
          if (_isSent) const Positioned.fill(child: OndeAnimation()),
        ],
      ),
    );
  }

  Widget _buildEmergencyActions() {
    return Column(
      children: [
        Text(
          "Les parents et les secours ont été prévenus",
          style: AppTypography.caption.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        ElevatedButton.icon(
          onPressed: () {}, // Mock call
          icon: const Icon(Icons.phone),
          label: const Text("Appeler les secours (17)"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFFE63946),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.2);
  }

  Widget _buildFooterInfo() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Text(
        "Cette fonctionnalité est réservée aux situations d'urgence",
        style: AppTypography.small.copyWith(
          color: Colors.white.withValues(alpha: 0.7),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class OndeAnimation extends StatelessWidget {
  const OndeAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .scale(
          duration: 2.seconds,
          begin: const Offset(1, 1),
          end: const Offset(2.5, 2.5),
          curve: Curves.easeOut,
        )
        .fadeOut(duration: 2.seconds);
  }
}
