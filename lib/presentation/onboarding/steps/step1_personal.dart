// lib/presentation/onboarding/steps/step1_personal.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../widgets/common/gradient_button.dart';
import '../../../widgets/common/profile_avatar.dart';
import '../../../widgets/inputs/glow_text_field.dart';

class Step1Personal extends ConsumerStatefulWidget {
  const Step1Personal({super.key});

  @override
  ConsumerState<Step1Personal> createState() => _Step1PersonalState();
}

class _Step1PersonalState extends ConsumerState<Step1Personal> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _headlineCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final uid = ref.read(currentUserProvider)?.uid ?? '';
    final state = ref.read(onboardingProvider(uid));
    _nameCtrl.text = state.personal.name;
    _emailCtrl.text = state.personal.email.isNotEmpty
        ? state.personal.email
        : (ref.read(currentUserProvider)?.email ?? '');
    _phoneCtrl.text = state.personal.phone;
    _headlineCtrl.text = state.personal.headline;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _headlineCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (!_formKey.currentState!.validate()) return;
    final uid = ref.read(currentUserProvider)?.uid ?? '';

    // Preserve photoUrl if already uploaded during this onboarding step
    final currentPhoto =
        ref.read(profileStreamProvider).value?.personal.photoUrl;

    ref.read(onboardingProvider(uid).notifier).updatePersonal(
          PersonalDetails(
            name: _nameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            headline: _headlineCtrl.text.trim(),
            photoUrl: currentPhoto,
          ),
        );
    ref.read(onboardingProvider(uid).notifier).nextStep();
  }

  @override
  Widget build(BuildContext context) {
    // Watch live profile so avatar reflects upload instantly
    final profile = ref.watch(profileStreamProvider).value;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Let's build\nyour profile ✨", style: AppTypography.displayMD),
            const SizedBox(height: 8),
            Text(
              'Start with the basics. You can always update these later.',
              style: AppTypography.bodyMD,
            ),
            const SizedBox(height: 36),

            // Avatar
            Center(
              child: Column(
                children: [
                  ProfileAvatar(
                    photoUrl: profile?.personal.photoUrl,
                    // Use typed name as display hint for initials
                    displayName: _nameCtrl.text.isNotEmpty
                        ? _nameCtrl.text
                        : profile?.personal.name,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to add a photo',
                    style: AppTypography.bodySM
                        .copyWith(color: AppColors.primaryLight),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            GlowTextField(
              label: 'Full Name',
              hint: 'Jane Doe',
              controller: _nameCtrl,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Enter your name' : null,
            ),
            const SizedBox(height: 16),

            GlowTextField(
              label: 'Email',
              hint: 'jane@example.com',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter your email';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            GlowTextField(
              label: 'Phone (optional)',
              hint: '+91 98765 43210',
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            GlowTextField(
              label: 'Professional Headline',
              hint: 'e.g. Flutter Developer & UI Designer',
              controller: _headlineCtrl,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Add a headline' : null,
            ),
            const SizedBox(height: 40),

            GradientButton(label: 'Continue →', onPressed: _next),
          ],
        ),
      ),
    );
  }
}
