// lib/presentation/onboarding/steps/step5_goals.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../widgets/common/gradient_button.dart';
import '../../../widgets/inputs/glow_text_field.dart';

class Step5Goals extends ConsumerStatefulWidget {
  const Step5Goals({super.key});

  @override
  ConsumerState<Step5Goals> createState() => _Step5GoalsState();
}

class _Step5GoalsState extends ConsumerState<Step5Goals> {
  final _bioCtrl = TextEditingController();
  final _goalCtrl = TextEditingController();
  final List<String> _selectedInterests = [];

  static const _interests = [
    '🚀 Startups',
    '🎨 Design',
    '🤖 AI/ML',
    '📱 Mobile Dev',
    '🌐 Web Dev',
    '☁️ Cloud',
    '🔒 Security',
    '📊 Data',
    '🎮 Gaming',
    '🏢 Enterprise',
    '💡 Innovation',
    '🌍 Open Source',
    '📚 Teaching',
    '🤝 Consulting',
    '🌱 Sustainability',
    '🎵 Creative',
  ];

  @override
  void dispose() {
    _bioCtrl.dispose();
    _goalCtrl.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final uid = ref.read(currentUserProvider)?.uid ?? '';
    ref.read(onboardingProvider(uid).notifier).updateGoals(
          GoalsData(
            interests: _selectedInterests,
            careerGoal: _goalCtrl.text.trim(),
            bio: _bioCtrl.text.trim(),
          ),
        );
    final ok = await ref.read(onboardingProvider(uid).notifier).saveAll();
    if (ok && mounted) {
      context.go(AppRoutes.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(currentUserProvider)?.uid ?? '';
    final state = ref.watch(onboardingProvider(uid));

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Almost\nthere! 🌟", style: AppTypography.displayMD),
          const SizedBox(height: 8),
          Text(
            "Tell us about your interests and where you're headed.",
            style: AppTypography.bodyMD,
          ),
          const SizedBox(height: 32),

          GlowTextField(
            label: 'Bio',
            hint: 'A short intro about yourself...',
            controller: _bioCtrl,
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          GlowTextField(
            label: 'Career Goal',
            hint: 'e.g. Become a senior Flutter engineer at a top startup',
            controller: _goalCtrl,
            maxLines: 2,
          ),
          const SizedBox(height: 24),

          Text("Your interests", style: AppTypography.labelLG),
          const SizedBox(height: 4),
          Text(
            'Select all that apply',
            style: AppTypography.bodySM,
          ),
          const SizedBox(height: 14),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _interests.map((interest) {
              final selected = _selectedInterests.contains(interest);
              return GestureDetector(
                onTap: () => setState(() {
                  if (selected) {
                    _selectedInterests.remove(interest);
                  } else {
                    _selectedInterests.add(interest);
                  }
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: selected ? AppColors.primaryGradient : null,
                    color: selected ? null : AppColors.bgDarkCard,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: selected
                          ? Colors.transparent
                          : AppColors.glassBorderDark,
                    ),
                    boxShadow: selected ? AppColors.primaryGlow : [],
                  ),
                  child: Text(
                    interest,
                    style: AppTypography.labelMD.copyWith(
                      color: selected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 40),

          // Completion card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0x1A7C3AED), Color(0x1AEC4899)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Text('🎉', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "You're all set!",
                        style: AppTypography.h3,
                      ),
                      Text(
                        'Your profile is ready to launch. You can always edit it later.',
                        style: AppTypography.bodySM,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          GradientButton(
            label: 'Launch My Profile 🚀',
            onPressed: _finish,
            isLoading: state.isLoading,
          ),
        ],
      ),
    );
  }
}
