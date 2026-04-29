// lib/presentation/onboarding/steps/step4_education.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/models/education_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../widgets/common/gradient_button.dart';
import '../../../widgets/common/glass_card.dart';
import '../../../widgets/inputs/glow_text_field.dart';

const _eduUuid = Uuid();

class Step4Education extends ConsumerStatefulWidget {
  const Step4Education({super.key});

  @override
  ConsumerState<Step4Education> createState() => _Step4EducationState();
}

class _Step4EducationState extends ConsumerState<Step4Education> {
  bool _showForm = false;
  final _degreeCtrl = TextEditingController();
  final _institutionCtrl = TextEditingController();
  final _fieldCtrl = TextEditingController();
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  final _gradeCtrl = TextEditingController();

  void _addEducation() {
    if (_degreeCtrl.text.isEmpty || _institutionCtrl.text.isEmpty) return;
    final uid = ref.read(currentUserProvider)?.uid ?? '';
    ref.read(onboardingProvider(uid).notifier).addEducation(
          EducationModel(
            id: _eduUuid.v4(),
            degree: _degreeCtrl.text.trim(),
            institution: _institutionCtrl.text.trim(),
            field: _fieldCtrl.text.trim(),
            startYear: _startCtrl.text.trim(),
            endYear: _endCtrl.text.trim(),
            grade: _gradeCtrl.text.trim(),
          ),
        );
    _degreeCtrl.clear();
    _institutionCtrl.clear();
    _fieldCtrl.clear();
    _startCtrl.clear();
    _endCtrl.clear();
    _gradeCtrl.clear();
    setState(() => _showForm = false);
  }

  @override
  void dispose() {
    _degreeCtrl.dispose();
    _institutionCtrl.dispose();
    _fieldCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    _gradeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(currentUserProvider)?.uid ?? '';
    final state = ref.watch(onboardingProvider(uid));
    final notifier = ref.read(onboardingProvider(uid).notifier);
    final education = state.education;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Your\neducation 🎓", style: AppTypography.displayMD),
          const SizedBox(height: 8),
          Text('Add your academic background.', style: AppTypography.bodyMD),
          const SizedBox(height: 28),
          ...education.map((edu) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: AppColors.mintGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.school_rounded,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(edu.degree, style: AppTypography.labelLG),
                            Text(edu.institution, style: AppTypography.bodyMD),
                            Text(
                              '${edu.field} • ${edu.startYear}–${edu.endYear}',
                              style: AppTypography.bodySM,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => notifier.removeEducation(edu.id),
                        icon: const Icon(Icons.delete_rounded,
                            color: AppColors.error, size: 20),
                      ),
                    ],
                  ),
                ),
              )),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: _showForm
                ? GlassCard(
                    child: Column(
                      children: [
                        GlowTextField(
                            label: 'Degree',
                            hint: 'e.g. B.Tech, BCA, MBA',
                            controller: _degreeCtrl),
                        const SizedBox(height: 12),
                        GlowTextField(
                            label: 'Institution',
                            hint: 'e.g. IIT Bombay',
                            controller: _institutionCtrl),
                        const SizedBox(height: 12),
                        GlowTextField(
                            label: 'Field of Study',
                            hint: 'e.g. Computer Science',
                            controller: _fieldCtrl),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: GlowTextField(
                                  label: 'Start Year',
                                  hint: '2020',
                                  controller: _startCtrl,
                                  keyboardType: TextInputType.number),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GlowTextField(
                                  label: 'End Year',
                                  hint: '2024',
                                  controller: _endCtrl,
                                  keyboardType: TextInputType.number),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        GlowTextField(
                            label: 'Grade / CGPA (optional)',
                            hint: '8.5 / 10',
                            controller: _gradeCtrl),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _showForm = false),
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.bgDarkCard,
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                        color: AppColors.glassBorderDark),
                                  ),
                                  child: Center(
                                    child: Text('Cancel',
                                        style: AppTypography.labelLG),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: _addEducation,
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.mintGradient,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Center(
                                    child: Text('Add',
                                        style: AppTypography.button),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : GestureDetector(
                    onTap: () => setState(() => _showForm = true),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.accent.withOpacity(0.3),
                            width: 1.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              gradient: AppColors.mintGradient,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.add,
                                color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Add Education',
                            style: AppTypography.labelLG.copyWith(
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 32),
          GradientButton(
            label: 'Continue →',
            onPressed: () => notifier.nextStep(),
          ),
        ],
      ),
    );
  }
}
