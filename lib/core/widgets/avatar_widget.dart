import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final bool showStatus;
  final bool isOnline;
  final bool showRing;

  const AppAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 48,
    this.showStatus = false,
    this.isOnline = false,
    this.showRing = false,
  });

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  // Maps name hash to one of several gradient pairs for visual variety
  LinearGradient get _avatarGradient {
    final gradients = [
      AppColors.primaryGradientH,
      const LinearGradient(colors: [Color(0xFF00A896), Color(0xFF00CDB8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      const LinearGradient(colors: [Color(0xFF1B2B3A), Color(0xFF2D4A6B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ];
    final index = name.codeUnits.fold(0, (a, b) => a + b) % gradients.length;
    return gradients[index];
  }

  @override
  Widget build(BuildContext context) {
    final avatar = _avatar();

    return Stack(
      children: [
        // Ring decoration
        if (showRing)
          Container(
            width: size + 6,
            height: size + 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradientH,
            ),
            padding: const EdgeInsets.all(2),
            child: avatar,
          )
        else
          avatar,

        // Online status dot
        if (showStatus)
          Positioned(
            bottom: showRing ? 3 : 0,
            right: showRing ? 3 : 0,
            child: Container(
              width: size * 0.27,
              height: size * 0.27,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOnline ? AppColors.success : AppColors.textTertiary,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _avatar() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: size / 2,
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => _initialsAvatar(),
        errorWidget: (context, url, error) => _initialsAvatar(),
      );
    }
    return _initialsAvatar();
  }

  Widget _initialsAvatar() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: _avatarGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.20),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          _initials,
          style: AppTypography.buttonLabel.copyWith(
            fontSize: size * 0.35,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
