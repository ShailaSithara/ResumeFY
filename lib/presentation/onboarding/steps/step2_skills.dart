// lib/presentation/onboarding/steps/step2_skills.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../widgets/cards/skill_chip.dart';
import '../../../widgets/common/gradient_button.dart';

class Step2Skills extends ConsumerStatefulWidget {
  const Step2Skills({super.key});

  @override
  ConsumerState<Step2Skills> createState() => _Step2SkillsState();
}

class _Step2SkillsState extends ConsumerState<Step2Skills> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  static const _suggestions = [
    'Flutter',
    'Dart',
    'Firebase',
    'React',
    'Node.js',
    'Python',
    'UI/UX',
    'Figma',
    'Swift',
    'Kotlin',
    'GraphQL',
    'TypeScript',
    'AWS',
    'Docker',
    'Git',
  ];

  void _addSkill(String skill) {
    if (skill.trim().isEmpty) return;
    final uid = ref.read(currentUserProvider)?.uid ?? '';
    ref.read(onboardingProvider(uid).notifier).addSkill(skill.trim());
    _ctrl.clear();
    _focus.requestFocus();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(currentUserProvider)?.uid ?? '';
    final state = ref.watch(onboardingProvider(uid));
    final notifier = ref.read(onboardingProvider(uid).notifier);
    final skills = state.skills;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("What are\nyour skills? 🛠️", style: AppTypography.displayMD),
          const SizedBox(height: 8),
          Text(
            'Add the skills that make you shine. Type and press Enter.',
            style: AppTypography.bodyMD,
          ),
          const SizedBox(height: 32),

          // Input
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: TextField(
              controller: _ctrl,
              focusNode: _focus,
              style: AppTypography.bodyMD.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Type a skill and press Enter...',
                hintStyle: AppTypography.bodyMD.copyWith(
                  color: AppColors.textMuted,
                ),
                suffixIcon: IconButton(
                  icon: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 18),
                  ),
                  onPressed: () => _addSkill(_ctrl.text),
                ),
              ),
              onSubmitted: _addSkill,
            ),
          ),
          const SizedBox(height: 24),

          // Quick suggestions
          if (skills.length < 10) ...[
            Text(
              'Quick add ⚡',
              style: AppTypography.labelMD.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _suggestions
                  .where((s) => !skills.contains(s))
                  .take(8)
                  .map((s) => GestureDetector(
                        onTap: () => _addSkill(s),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.bgDarkCard,
                            borderRadius: BorderRadius.circular(100),
                            border:
                                Border.all(color: AppColors.glassBorderDark),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add,
                                  size: 14, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(s, style: AppTypography.labelMD),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Added skills
          if (skills.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  'Your skills',
                  style: AppTypography.labelLG,
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '${skills.length}',
                    style: AppTypography.labelSM.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills.asMap().entries.map((entry) {
                return SkillChip(
                  label: entry.value,
                  colorIndex: entry.key,
                  onDelete: () => notifier.removeSkill(entry.value),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.bgDarkCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorderDark),
              ),
              child: Center(
                child: Column(
                  children: [
                    const Text('🎯', style: TextStyle(fontSize: 32)),
                    const SizedBox(height: 8),
                    Text(
                      'Add at least 3 skills',
                      style: AppTypography.labelMD,
                    ),
                    Text(
                      'to make your profile stand out',
                      style: AppTypography.bodySM,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],

          GradientButton(
            label: 'Continue →',
            onPressed: skills.isNotEmpty
                ? () => ref.read(onboardingProvider(uid).notifier).nextStep()
                : null,
          ),
        ],
      ),
    );
  }
}
