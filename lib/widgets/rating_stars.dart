import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final double starSize;

  const RatingStars({
    super.key,
    required this.rating,
    this.reviewCount = 0,
    this.starSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star_rounded,
          color: const Color(0xFFFFC107),
          size: starSize,
        ),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: starSize * 0.9,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (reviewCount > 0) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: TextStyle(
              fontSize: starSize * 0.8,
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
          ),
        ],
      ],
    );
  }
}
