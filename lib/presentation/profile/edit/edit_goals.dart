// lib/presentation/profile/edit/edit_goals.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/profile_provider.dart';
import '../../../widgets/common/gradient_button.dart';
import '../../../widgets/inputs/glow_text_field.dart';

class EditGoalsScreen extends ConsumerStatefulWidget {
  const EditGoalsScreen({super.key});

  @override
  ConsumerState<EditGoalsScreen> createState() => _EditGoalsScreenState();
}

class _EditGoalsScreenState extends ConsumerState<EditGoalsScreen> {
  final _bioCtrl = TextEditingController();
  final _goalCtrl = TextEditingController();
  List<String> _selectedInterests = [];
  bool _initialized = false;

  static const _allInterests = [
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

  void _init(GoalsData goals) {
    if (_initialized) return;
    _initialized = true;
    _bioCtrl.text = goals.bio;
    _goalCtrl.text = goals.careerGoal;
    _selectedInterests = List.from(goals.interests);
  }

  Future<void> _save() async {
    await ref.read(profileNotifierProvider.notifier).updateGoals(
          GoalsData(
            bio: _bioCtrl.text.trim(),
            careerGoal: _goalCtrl.text.trim(),
            interests: _selectedInterests,
          ),
        );
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
              if (profile != null) _init(profile.goals);
              return Column(
                children: [
                  _EditAppBar(
                      title: 'Goals & Interests', onBack: () => context.pop()),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GlowTextField(
                            label: 'Bio',
                            hint: 'A short intro about yourself...',
                            controller: _bioCtrl,
                            maxLines: 4,
                          ),
                          const SizedBox(height: 16),
                          GlowTextField(
                            label: 'Career Goal',
                            hint:
                                'e.g. Become a senior Flutter engineer at a top startup',
                            controller: _goalCtrl,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 28),
                          Row(
                            children: [
                              Text('Interests', style: AppTypography.labelLG),
                              const SizedBox(width: 8),
                              if (_selectedInterests.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text(
                                    '${_selectedInterests.length}',
                                    style: AppTypography.labelSM
                                        .copyWith(color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('Select all that apply',
                              style: AppTypography.bodySM),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _allInterests.map((interest) {
                              final selected =
                                  _selectedInterests.contains(interest);
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: selected
                                        ? AppColors.primaryGradient
                                        : null,
                                    color:
                                        selected ? null : AppColors.bgDarkCard,
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                      color: selected
                                          ? Colors.transparent
                                          : AppColors.glassBorderDark,
                                    ),
                                    boxShadow:
                                        selected ? AppColors.primaryGlow : [],
                                  ),
                                  child: Text(
                                    interest,
                                    style: AppTypography.labelMD.copyWith(
                                      color: selected
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 40),
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
