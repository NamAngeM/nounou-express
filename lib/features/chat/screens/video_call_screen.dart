import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class VideoCallScreen extends StatefulWidget {
  final String peerName;

  const VideoCallScreen({super.key, required this.peerName});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool _isMuted = false;
  bool _isVideoOff = false;

  void _endCall() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Simulated remote video feed (blur effect over a solid color or gradient)
          _isVideoOff
              ? Container(
                  color: AppColors.background,
                  child: Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primarySurface,
                      child: Text(
                        widget.peerName[0].toUpperCase(),
                        style: AppTypography.h1.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                )
              : Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2C3E50), Color(0xFF000000)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person_rounded,
                      size: 120,
                      color: Colors.white24,
                    ),
                  ),
                ),

          // Caller info (Top)
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.md,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => context.pop(),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        widget.peerName,
                        style: AppTypography.h4.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '00:00',
                        style: AppTypography.caption.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 48), // Balance the flex
              ],
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
          ),

          // Local video feed (Bottom Right)
          Positioned(
            bottom: 120,
            right: AppSpacing.lg,
            child:
                Container(
                      width: 100,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Simulated local camera
                            Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF34495E),
                                    Color(0xFF2C3E50),
                                  ],
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.person_outline,
                                  color: Colors.white54,
                                  size: 40,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 300.ms)
                    .scale(begin: const Offset(0.8, 0.8)),
          ),

          // Call Controls (Bottom)
          Positioned(
            bottom: AppSpacing.xxl,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                  color: _isMuted ? Colors.white : Colors.white24,
                  iconColor: _isMuted ? Colors.black : Colors.white,
                  onTap: () => setState(() => _isMuted = !_isMuted),
                ),
                _buildControlButton(
                  icon: Icons.call_end_rounded,
                  color: AppColors.danger,
                  iconColor: Colors.white,
                  size: 64,
                  iconSize: 32,
                  onTap: _endCall,
                ),
                _buildControlButton(
                  icon: _isVideoOff
                      ? Icons.videocam_off_rounded
                      : Icons.videocam_rounded,
                  color: _isVideoOff ? Colors.white : Colors.white24,
                  iconColor: _isVideoOff ? Colors.black : Colors.white,
                  onTap: () => setState(() => _isVideoOff = !_isVideoOff),
                ),
              ],
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
    double size = 56,
    double iconSize = 24,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: iconSize),
      ),
    );
  }
}
