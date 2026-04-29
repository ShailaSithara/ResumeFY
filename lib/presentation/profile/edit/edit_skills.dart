// lib/presentation/profile/edit/edit_skills.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../providers/profile_provider.dart';
import '../../../widgets/cards/skill_chip.dart';
import '../../../widgets/common/gradient_button.dart';

class EditSkillsScreen extends ConsumerStatefulWidget {
  const EditSkillsScreen({super.key});

  @override
  ConsumerState<EditSkillsScreen> createState() => _EditSkillsScreenState();
}

class _EditSkillsScreenState extends ConsumerState<EditSkillsScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  List<String> _skills = [];
  bool _initialized = false;

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

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _init(List<String> skills) {
    if (_initialized) return;
    _initialized = true;
    _skills = List.from(skills);
  }

  void _addSkill(String skill) {
    final trimmed = skill.trim();
    if (trimmed.isEmpty || _skills.contains(trimmed)) return;
    setState(() => _skills.add(trimmed));
    _ctrl.clear();
    _focus.requestFocus();
  }

  void _removeSkill(String skill) => setState(() => _skills.remove(skill));

  Future<void> _save() async {
    await ref.read(profileNotifierProvider.notifier).updateSkills(_skills);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileStreamProvider);
    final saveState = ref.watch(profileNotifierProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradientDark),
        child: SafeArea(
          child: profileAsync.when(
            loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary)),
            error: (e, _) => Center(child: Text(e.toString())),
            data: (profile) {
              if (profile != null) _init(profile.skills);
              return Column(
                children: [
                  _EditAppBar(title: 'Skills', onBack: () => context.pop()),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Input field
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
                              style: AppTypography.bodyMD
                                  .copyWith(color: AppColors.textPrimary),
                              decoration: InputDecoration(
                                hintText: 'Type a skill and press Enter...',
                                hintStyle: AppTypography.bodyMD
                                    .copyWith(color: AppColors.textMuted),
                                suffixIcon: IconButton(
                                  icon: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.add,
                                        color: Colors.white, size: 18),
                                  ),
                                  onPressed: () => _addSkill(_ctrl.text),
                                ),
                              ),
                              onSubmitted: _addSkill,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Suggestions
                          Text('Quick add ⚡',
                              style: AppTypography.labelMD
                                  .copyWith(color: AppColors.textMuted)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _suggestions
                                .where((s) => !_skills.contains(s))
                                .take(8)
                                .map((s) => GestureDetector(
                                      onTap: () => _addSkill(s),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: AppColors.bgDarkCard,
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          border: Border.all(
                                              color: AppColors.glassBorderDark),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.add,
                                                size: 14,
                                                color: AppColors.textMuted),
                                            const SizedBox(width: 4),
                                            Text(s,
                                                style: AppTypography.labelMD),
                                          ],
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 28),

                          // Current skills
                          if (_skills.isNotEmpty) ...[
                            Row(
                              children: [
                                Text('Your skills',
                                    style: AppTypography.labelLG),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text(
                                    '${_skills.length}',
                                    style: AppTypography.labelSM
                                        .copyWith(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _skills.asMap().entries.map((e) {
                                return SkillChip(
                                  label: e.value,
                                  colorIndex: e.key,
                                  onDelete: () => _removeSkill(e.value),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 40),
                          ],

                          GradientButton(
                            label: 'Save Changes',
                            onPressed: _save,
                            isLoading: saveState.isLoading,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// Re-export shared AppBar widget (or import from edit_personal.dart)
class _EditAppBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  const _EditAppBar({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.bgDarkCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.glassBorderDark),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.textPrimary, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Text(title, style: AppTypography.h2),
        ],
      ),
    );
  }
}
