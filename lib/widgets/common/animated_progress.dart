// lib/widgets/common/animated_progress.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

class OnboardingProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepLabels;

  const OnboardingProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(totalSteps, (index) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index < totalSteps - 1 ? 6 : 0),
                child: _StepBar(
                  isCompleted: index < currentStep,
                  isActive: index == currentStep,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step ${currentStep + 1} of $totalSteps',
              style: AppTypography.caption.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            Text(
              stepLabels[currentStep],
              style: AppTypography.labelSM.copyWith(
                color: AppColors.primaryLight,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StepBar extends StatelessWidget {
  final bool isCompleted;
  final bool isActive;

  const _StepBar({required this.isCompleted, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        gradient: isCompleted || isActive ? AppColors.primaryGradient : null,
        color: isCompleted || isActive ? null : AppColors.glassBorderDark,
      ),
    );
  }
}
