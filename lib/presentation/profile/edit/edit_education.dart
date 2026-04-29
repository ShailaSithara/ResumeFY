// lib/presentation/profile/edit/edit_education.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/models/education_model.dart';
import '../../../providers/profile_provider.dart';
import '../../../widgets/common/glass_card.dart';
import '../../../widgets/common/gradient_button.dart';
import '../../../widgets/inputs/glow_text_field.dart';

const _edUuid = Uuid();

class EditEducationScreen extends ConsumerStatefulWidget {
  const EditEducationScreen({super.key});

  @override
  ConsumerState<EditEducationScreen> createState() =>
      _EditEducationScreenState();
}

class _EditEducationScreenState extends ConsumerState<EditEducationScreen> {
  List<EducationModel> _education = [];
  bool _initialized = false;
  bool _showForm = false;

  final _degreeCtrl = TextEditingController();
  final _institutionCtrl = TextEditingController();
  final _fieldCtrl = TextEditingController();
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  final _gradeCtrl = TextEditingController();

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

  void _init(List<EducationModel> edu) {
    if (_initialized) return;
    _initialized = true;
    _education = List.from(edu);
  }

  void _addEducation() {
    if (_degreeCtrl.text.isEmpty || _institutionCtrl.text.isEmpty) return;
    setState(() {
      _education.add(EducationModel(
        id: _edUuid.v4(),
        degree: _degreeCtrl.text.trim(),
        institution: _institutionCtrl.text.trim(),
        field: _fieldCtrl.text.trim(),
        startYear: _startCtrl.text.trim(),
        endYear: _endCtrl.text.trim(),
        grade: _gradeCtrl.text.trim(),
      ));
      _degreeCtrl.clear();
      _institutionCtrl.clear();
      _fieldCtrl.clear();
      _startCtrl.clear();
      _endCtrl.clear();
      _gradeCtrl.clear();
      _showForm = false;
    });
  }

  Future<void> _save() async {
    await ref
        .read(profileNotifierProvider.notifier)
        .updateEducation(_education);
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
              if (profile != null) _init(profile.education);
              return Column(
                children: [
                  _EditAppBar(title: 'Education', onBack: () => context.pop()),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Existing cards
                          ..._education.map((edu) => Padding(
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
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.school_rounded,
                                            color: Colors.white, size: 20),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(edu.degree,
                                                style: AppTypography.labelLG),
                                            Text(edu.institution,
                                                style: AppTypography.bodyMD),
                                            Text(
                                              '${edu.field} • ${edu.startYear}–${edu.endYear}',
                                              style: AppTypography.bodySM,
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => setState(() =>
                                            _education.removeWhere(
                                                (e) => e.id == edu.id)),
                                        icon: Container(
                                          width: 34,
                                          height: 34,
                                          decoration: BoxDecoration(
                                            color: AppColors.error
                                                .withOpacity(0.15),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                color: AppColors.error
                                                    .withOpacity(0.3)),
                                          ),
                                          child: const Icon(
                                              Icons.delete_rounded,
                                              color: AppColors.error,
                                              size: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),

                          // Add form
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            child: _showForm
                                ? GlassCard(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('New Education',
                                            style: AppTypography.h3),
                                        const SizedBox(height: 16),
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
                                        Row(children: [
                                          Expanded(
                                            child: GlowTextField(
                                                label: 'Start Year',
                                                hint: '2020',
                                                controller: _startCtrl,
                                                keyboardType:
                                                    TextInputType.number),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: GlowTextField(
                                                label: 'End Year',
                                                hint: '2024',
                                                controller: _endCtrl,
                                                keyboardType:
                                                    TextInputType.number),
                                          ),
                                        ]),
                                        const SizedBox(height: 12),
                                        GlowTextField(
                                            label: 'Grade / CGPA (optional)',
                                            hint: '8.5 / 10',
                                            controller: _gradeCtrl),
                                        const SizedBox(height: 16),
                                        Row(children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () => setState(
                                                  () => _showForm = false),
                                              child: Container(
                                                height: 48,
                                                decoration: BoxDecoration(
                                                  color: AppColors.bgDarkCard,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  border: Border.all(
                                                      color: AppColors
                                                          .glassBorderDark),
                                                ),
                                                child: Center(
                                                    child: Text('Cancel',
                                                        style: AppTypography
                                                            .labelLG)),
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
                                                  gradient:
                                                      AppColors.mintGradient,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                ),
                                                child: Center(
                                                    child: Text('Add',
                                                        style: AppTypography
                                                            .button)),
                                              ),
                                            ),
                                          ),
                                        ]),
                                      ],
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () =>
                                        setState(() => _showForm = true),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color:
                                            AppColors.accent.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                            color: AppColors.accent
                                                .withOpacity(0.3),
                                            width: 1.5),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              gradient: AppColors.mintGradient,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(Icons.add,
                                                color: Colors.white, size: 18),
                                          ),
                                          const SizedBox(width: 12),
                                          Text('Add Education',
                                              style: AppTypography.labelLG
                                                  .copyWith(
                                                color: AppColors.accent,
                                              )),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 32),
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
