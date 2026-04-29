// lib/presentation/onboarding/steps/step3_experience.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/models/experience_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../widgets/common/gradient_button.dart';
import '../../../widgets/common/glass_card.dart';
import '../../../widgets/inputs/glow_text_field.dart';

const _uuid = Uuid();

class Step3Experience extends ConsumerStatefulWidget {
  const Step3Experience({super.key});

  @override
  ConsumerState<Step3Experience> createState() => _Step3ExperienceState();
}

class _Step3ExperienceState extends ConsumerState<Step3Experience> {
  bool _showForm = false;
  final _roleCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _isCurrent = false;

  void _toggleForm() => setState(() => _showForm = !_showForm);

  void _addExperience() {
    if (_roleCtrl.text.isEmpty || _companyCtrl.text.isEmpty) return;
    final uid = ref.read(currentUserProvider)?.uid ?? '';
    ref.read(onboardingProvider(uid).notifier).addExperience(
          ExperienceModel(
            id: _uuid.v4(),
            role: _roleCtrl.text.trim(),
            company: _companyCtrl.text.trim(),
            startDate: _startCtrl.text.trim(),
            endDate: _isCurrent ? null : _endCtrl.text.trim(),
            isCurrent: _isCurrent,
            description: _descCtrl.text.trim(),
          ),
        );
    _roleCtrl.clear();
    _companyCtrl.clear();
    _startCtrl.clear();
    _endCtrl.clear();
    _descCtrl.clear();
    setState(() {
      _isCurrent = false;
      _showForm = false;
    });
  }

  @override
  void dispose() {
    _roleCtrl.dispose();
    _companyCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(currentUserProvider)?.uid ?? '';
    final state = ref.watch(onboardingProvider(uid));
    final notifier = ref.read(onboardingProvider(uid).notifier);
    final experiences = state.experience;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Your work\nexperience 💼", style: AppTypography.displayMD),
          const SizedBox(height: 8),
          Text(
            'Showcase your professional journey.',
            style: AppTypography.bodyMD,
          ),
          const SizedBox(height: 28),

          // Experience list
          ...experiences.asMap().entries.map((entry) {
            final exp = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ExperienceCard(
                exp: exp,
                onDelete: () => notifier.removeExperience(exp.id),
              ),
            );
          }),

          // Add form
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: _showForm
                ? _AddExperienceForm(
                    roleCtrl: _roleCtrl,
                    companyCtrl: _companyCtrl,
                    startCtrl: _startCtrl,
                    endCtrl: _endCtrl,
                    descCtrl: _descCtrl,
                    isCurrent: _isCurrent,
                    onCurrentChanged: (v) => setState(() => _isCurrent = v),
                    onAdd: _addExperience,
                    onCancel: _toggleForm,
                  )
                : GestureDetector(
                    onTap: _toggleForm,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.add,
                                color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Add Work Experience',
                            style: AppTypography.labelLG.copyWith(
                              color: AppColors.primaryLight,
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

          if (experiences.isEmpty) ...[
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => notifier.nextStep(),
                child: Text(
                  'Skip for now',
                  style: AppTypography.labelMD.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  final ExperienceModel exp;
  final VoidCallback onDelete;

  const _ExperienceCard({required this.exp, required this.onDelete});

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
                const Icon(Icons.work_rounded, color: Colors.white, size: 22),
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
            icon: const Icon(Icons.delete_rounded,
                color: AppColors.error, size: 20),
          ),
        ],
      ),
    );
  }
}

class _AddExperienceForm extends StatelessWidget {
  final TextEditingController roleCtrl;
  final TextEditingController companyCtrl;
  final TextEditingController startCtrl;
  final TextEditingController endCtrl;
  final TextEditingController descCtrl;
  final bool isCurrent;
  final ValueChanged<bool> onCurrentChanged;
  final VoidCallback onAdd;
  final VoidCallback onCancel;

  const _AddExperienceForm({
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
        children: [
          GlowTextField(
              label: 'Job Title',
              hint: 'e.g. Flutter Developer',
              controller: roleCtrl),
          const SizedBox(height: 12),
          GlowTextField(
              label: 'Company', hint: 'e.g. Google', controller: companyCtrl),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: GlowTextField(
                      label: 'Start Date',
                      hint: 'Jan 2022',
                      controller: startCtrl)),
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
                              style: AppTypography.labelMD.copyWith(
                                color: AppColors.success,
                              )),
                        ),
                      )
                    : GlowTextField(
                        label: 'End Date',
                        hint: 'Dec 2023',
                        controller: endCtrl),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Switch(
                value: isCurrent,
                onChanged: onCurrentChanged,
                activeColor: AppColors.primary,
              ),
              Text('Currently working here', style: AppTypography.bodyMD),
            ],
          ),
          const SizedBox(height: 12),
          GlowTextField(
            label: 'Description (optional)',
            hint: 'Brief about your role...',
            controller: descCtrl,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
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
                      child: Text('Cancel', style: AppTypography.labelLG),
                    ),
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
                    child: Center(
                      child: Text('Add', style: AppTypography.button),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
