import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final bool isInteractive;
  final ValueChanged<double>? onRatingChanged;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 16,
    this.isInteractive = false,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final IconData icon;
        if (rating >= starValue) {
          icon = Icons.star_rounded;
        } else if (rating >= starValue - 0.5) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_outline_rounded;
        }
        final color = icon == Icons.star_outline_rounded
            ? AppColors.border
            : AppColors.warning;

        Widget star = Icon(icon, size: size, color: color);

        if (isInteractive) {
          return GestureDetector(
            onTap: () => onRatingChanged?.call(starValue.toDouble()),
            child: star
                .animate(key: ValueKey('star_${index}_$rating'))
                .scale(duration: 200.ms, curve: Curves.easeOutBack),
          );
        }
        return star;
      }),
    );
  }
}
