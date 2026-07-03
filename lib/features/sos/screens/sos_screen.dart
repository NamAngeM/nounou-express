import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
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

  // ── Pulse animation controller (background circles) ────────────────────────
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

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

  Future<void> _callNumber(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (!await launchUrl(uri)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Impossible de composer le $number")),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.danger,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Background pulse circles ───────────────────────────────────
            Positioned.fill(
              child: _BackgroundPulse(controller: _pulseController),
            ),

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
                    style: AppTypography.h2.copyWith(color: Colors.white),
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
                  const SizedBox(height: AppSpacing.xl),

                  // ── Status badge ───────────────────────────────────────
                  _StatusBadge(progress: _progress, isSent: _isSent),

                  const SizedBox(height: AppSpacing.xl),
                  _buildSosButton(),

                  if (_isSent) ...[
                    const SizedBox(height: AppSpacing.xl * 2),
                    _buildEmergencyActions(),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Emergency contact row ──────────────────────────
                    _buildEmergencyContactCard(),
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
    // Countdown: 3 → 2 → 1 → 0
    final int secondsLeft = _progress == 0
        ? 3
        : math.max(0, (3 - (_progress * 3)).ceil());

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
            child: _isSent
                ? const Icon(Icons.check, color: AppColors.danger, size: 60)
                : _progress > 0
                ? Center(
                    child: Text(
                      "$secondsLeft",
                      style: AppTypography.h1.copyWith(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.warning_rounded,
                    color: AppColors.danger,
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
          onPressed: () => _callNumber('17'),
          icon: const Icon(Icons.phone),
          label: const Text("Appeler les secours (17)"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.danger,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.2);
  }

  Widget _buildEmergencyContactCard() {
    return GestureDetector(
      onTap: () => _callNumber('15'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.phone_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "SAMU — 15",
                    style: AppTypography.h4.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    "Appel d'urgence médical",
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.15, end: 0);
  }

  Widget _buildFooterInfo() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.20),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                "Utilisez uniquement en cas de réelle urgence. Toute fausse alerte est signalée.",
                style: AppTypography.small.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final double progress;
  final bool isSent;

  const _StatusBadge({required this.progress, required this.isSent});

  @override
  Widget build(BuildContext context) {
    final String label;
    final Color bg;
    final Color fg;

    if (isSent) {
      label = "ENVOYÉ";
      bg = AppColors.accent;
      fg = Colors.white;
    } else if (progress > 0) {
      label = "ENVOI...";
      bg = AppColors.gold;
      fg = Colors.white;
    } else {
      label = "PRÊT";
      bg = Colors.white.withValues(alpha: 0.20);
      fg = Colors.white;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: Text(
          label,
          key: ValueKey(label),
          style: AppTypography.overline.copyWith(
            color: fg,
            letterSpacing: 2.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ── Background pulse (concentric expanding circles) ──────────────────────────

class _BackgroundPulse extends StatelessWidget {
  final AnimationController controller;

  const _BackgroundPulse({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value;
        return CustomPaint(painter: _PulsePainter(progress: t));
      },
    );
  }
}

class _PulsePainter extends CustomPainter {
  final double progress;
  _PulsePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.longestSide * 0.7;
    final paint = Paint()..style = PaintingStyle.stroke;

    // Draw 3 staggered concentric circles
    for (int i = 0; i < 3; i++) {
      final phase = (progress + i / 3) % 1.0;
      final radius = maxRadius * phase;
      final opacity = (1.0 - phase) * 0.15;
      paint
        ..color = Colors.white.withValues(alpha: opacity)
        ..strokeWidth = 2.0 + (1.0 - phase) * 2;
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_PulsePainter old) => old.progress != progress;
}

// ── Wave / onde animation ─────────────────────────────────────────────────────

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
