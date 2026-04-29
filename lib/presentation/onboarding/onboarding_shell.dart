// lib/presentation/onboarding/onboarding_shell.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/common/animated_progress.dart';
import 'steps/step1_personal.dart';
import 'steps/step2_skills.dart';
import 'steps/step3_experience.dart';
import 'steps/step4_education.dart';
import 'steps/step5_goals.dart';

class OnboardingShell extends ConsumerWidget {
  const OnboardingShell({super.key});

  static const _stepLabels = [
    'Personal',
    'Skills',
    'Experience',
    'Education',
    'Goals',
  ];

  static const _steps = [
    Step1Personal(),
    Step2Skills(),
    Step3Experience(),
    Step4Education(),
    Step5Goals(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUserProvider)?.uid ?? '';
    final state = ref.watch(onboardingProvider(uid));
    final notifier = ref.read(onboardingProvider(uid).notifier);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradientDark),
        child: Stack(
          children: [
            // Glow orb
            Positioned(
              top: -100,
              right: -80,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.25),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Column(
                      children: [
                        // Top bar: back + skip
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (state.currentStep > 0)
                              GestureDetector(
                                onTap: notifier.previousStep,
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.bgDarkCard,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: AppColors.glassBorderDark),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_rounded,
                                    color: AppColors.textPrimary,
                                    size: 20,
                                  ),
                                ),
                              )
                            else
                              const SizedBox(width: 44),

                            // Step counter badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                    color: AppColors.primary.withOpacity(0.3)),
                              ),
                              child: Text(
                                '${state.currentStep + 1} / 5',
                                style: AppTypography.labelMD.copyWith(
                                  color: AppColors.primaryLight,
                                ),
                              ),
                            ),

                            if (state.currentStep < 4)
                              TextButton(
                                onPressed: () async {
                                  final ok = await notifier.saveAll();
                                  if (ok && context.mounted) {
                                    context.go(AppRoutes.profile);
                                  }
                                },
                                child: Text(
                                  'Skip',
                                  style: AppTypography.labelMD.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              )
                            else
                              const SizedBox(width: 44),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Progress
                        OnboardingProgress(
                          currentStep: state.currentStep,
                          totalSteps: 5,
                          stepLabels: _stepLabels,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Step content with page-slide animation
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          ),
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.05, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            )),
                            child: child,
                          ),
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey(state.currentStep),
                        child: _steps[state.currentStep],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Loading overlay
            if (state.isLoading)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
