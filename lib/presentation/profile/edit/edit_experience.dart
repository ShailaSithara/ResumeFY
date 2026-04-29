// lib/presentation/profile/edit/edit_experience.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/models/experience_model.dart';
import '../../../providers/profile_provider.dart';
import '../../../widgets/common/glass_card.dart';
import '../../../widgets/common/gradient_button.dart';
import '../../../widgets/inputs/glow_text_field.dart';

const _expUuid = Uuid();

class EditExperienceScreen extends ConsumerStatefulWidget {
  const EditExperienceScreen({super.key});

  @override
  ConsumerState<EditExperienceScreen> createState() =>
      _EditExperienceScreenState();
}

class _EditExperienceScreenState extends ConsumerState<EditExperienceScreen> {
  List<ExperienceModel> _experiences = [];
  bool _initialized = false;
  bool _showForm = false;

  // Form controllers
  final _roleCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _isCurrent = false;

  @override
  void dispose() {
    _roleCtrl.dispose();
    _companyCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _init(List<ExperienceModel> exp) {
    if (_initialized) return;
    _initialized = true;
    _experiences = List.from(exp);
  }

  void _addExperience() {
    if (_roleCtrl.text.isEmpty || _companyCtrl.text.isEmpty) return;
    setState(() {
      _experiences.add(ExperienceModel(
        id: _expUuid.v4(),
        role: _roleCtrl.text.trim(),
        company: _companyCtrl.text.trim(),
        startDate: _startCtrl.text.trim(),
        endDate: _isCurrent ? null : _endCtrl.text.trim(),
        isCurrent: _isCurrent,
        description: _descCtrl.text.trim(),
      ));
      _roleCtrl.clear();
      _companyCtrl.clear();
      _startCtrl.clear();
      _endCtrl.clear();
      _descCtrl.clear();
      _isCurrent = false;
      _showForm = false;
    });
  }

  Future<void> _save() async {
    await ref
        .read(profileNotifierProvider.notifier)
        .updateExperience(_experiences);
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
              if (profile != null) _init(profile.experience);
              return Column(
                children: [
                  _EditAppBar(
                      title: 'Work Experience', onBack: () => context.pop()),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Existing cards
                          ..._experiences.map((exp) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _ExperienceEditCard(
                                  exp: exp,
                                  onDelete: () => setState(() => _experiences
                                      .removeWhere((e) => e.id == exp.id)),
                                ),
                              )),

                          // Add form toggle
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            child: _showForm
                                ? _ExperienceForm(
                                    roleCtrl: _roleCtrl,
                                    companyCtrl: _companyCtrl,
                                    startCtrl: _startCtrl,
                                    endCtrl: _endCtrl,
                                    descCtrl: _descCtrl,
                                    isCurrent: _isCurrent,
                                    onCurrentChanged: (v) =>
                                        setState(() => _isCurrent = v),
                                    onAdd: _addExperience,
                                    onCancel: () =>
                                        setState(() => _showForm = false),
                                  )
                                : _AddButton(
                                    label: 'Add Work Experience',
                                    gradient: AppColors.primaryGradient,
                                    accentColor: AppColors.primary,
                                    onTap: () =>
                                        setState(() => _showForm = true),
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

class _ExperienceEditCard extends StatelessWidget {
  final ExperienceModel exp;
  final VoidCallback onDelete;

  const _ExperienceEditCard({required this.exp, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppColors.cyanGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                const Icon(Icons.work_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exp.role, style: AppTypography.labelLG),
                Text(exp.company, style: AppTypography.bodyMD),
                Text(
                  '${exp.startDate} – ${exp.isCurrent ? "Present" : (exp.endDate ?? "")}',
                  style: AppTypography.bodySM,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: const Icon(Icons.delete_rounded,
                  color: AppColors.error, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExperienceForm extends StatelessWidget {
  final TextEditingController roleCtrl;
  final TextEditingController companyCtrl;
  final TextEditingController startCtrl;
  final TextEditingController endCtrl;
  final TextEditingController descCtrl;
  final bool isCurrent;
  final ValueChanged<bool> onCurrentChanged;
  final VoidCallback onAdd;
  final VoidCallback onCancel;

  const _ExperienceForm({
    required this.roleCtrl,
    required this.companyCtrl,
    required this.startCtrl,
    required this.endCtrl,
    required this.descCtrl,
    required this.isCurrent,
    required this.onCurrentChanged,
    required this.onAdd,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New Experience', style: AppTypography.h3),
          const SizedBox(height: 16),
          GlowTextField(
              label: 'Job Title',
              hint: 'e.g. Flutter Developer',
              controller: roleCtrl),
          const SizedBox(height: 12),
          GlowTextField(
              label: 'Company', hint: 'e.g. Google', controller: companyCtrl),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: GlowTextField(
                  label: 'Start Date', hint: 'Jan 2022', controller: startCtrl),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: isCurrent
                  ? Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.success.withOpacity(0.3)),
                      ),
                      child: Center(
                        child: Text('Present',
                            style: AppTypography.labelMD
                                .copyWith(color: AppColors.success)),
                      ),
                    )
                  : GlowTextField(
                      label: 'End Date', hint: 'Dec 2023', controller: endCtrl),
            ),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Switch(
                value: isCurrent,
                onChanged: onCurrentChanged,
                activeColor: AppColors.primary),
            Text('Currently working here', style: AppTypography.bodyMD),
          ]),
          const SizedBox(height: 12),
          GlowTextField(
            label: 'Description (optional)',
            hint: 'Describe your role...',
            controller: descCtrl,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: onCancel,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.bgDarkCard,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: AppColors.glassBorderDark),
                  ),
                  child: Center(
                      child: Text('Cancel', style: AppTypography.labelLG)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: onAdd,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child:
                      Center(child: Text('Add', style: AppTypography.button)),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final String label;
  final Gradient gradient;
  final Color accentColor;
  final VoidCallback onTap;

  const _AddButton({
    required this.label,
    required this.gradient,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Text(label,
                style: AppTypography.labelLG.copyWith(color: accentColor)),
          ],
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
