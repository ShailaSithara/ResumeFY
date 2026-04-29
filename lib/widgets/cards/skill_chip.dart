// lib/widgets/cards/skill_chip.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

class SkillChip extends StatelessWidget {
  final String label;
  final VoidCallback? onDelete;
  final int colorIndex;
  final bool showDelete;

  const SkillChip({
    super.key,
    required this.label,
    this.onDelete,
    this.colorIndex = 0,
    this.showDelete = true,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        AppColors.chipColors[colorIndex % AppColors.chipColors.length];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: color.withOpacity(0.4), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.labelMD.copyWith(color: color),
            ),
            if (showDelete && onDelete != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 11, color: color),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
