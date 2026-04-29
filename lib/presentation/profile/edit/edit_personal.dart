// lib/presentation/profile/edit/edit_personal.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/profile_provider.dart';
import '../../../widgets/common/gradient_button.dart';
import '../../../widgets/common/profile_avatar.dart';
import '../../../widgets/inputs/glow_text_field.dart';

class EditPersonalScreen extends ConsumerStatefulWidget {
  const EditPersonalScreen({super.key});

  @override
  ConsumerState<EditPersonalScreen> createState() => _EditPersonalScreenState();
}

class _EditPersonalScreenState extends ConsumerState<EditPersonalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _headlineCtrl = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _headlineCtrl.dispose();
    super.dispose();
  }

  void _init(PersonalDetails personal) {
    if (_initialized) return;
    _initialized = true;
    _nameCtrl.text = personal.name;
    _emailCtrl.text = personal.email;
    _phoneCtrl.text = personal.phone;
    _headlineCtrl.text = personal.headline;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Preserve the existing photoUrl — photo changes are handled by
    // ProfileAvatar independently via uploadAndSetPhoto / removePhoto.
    final currentPhoto =
        ref.read(profileStreamProvider).value?.personal.photoUrl;

    await ref.read(profileNotifierProvider.notifier).updatePersonal(
          PersonalDetails(
            name: _nameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            headline: _headlineCtrl.text.trim(),
            photoUrl: currentPhoto,
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
              if (profile != null) _init(profile.personal);
              return Column(
                children: [
                  _EditAppBar(
                      title: 'Personal Details', onBack: () => context.pop()),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Avatar — handles its own upload via ProfileAvatar
                            ProfileAvatar(
                              photoUrl: profile?.personal.photoUrl,
                              displayName: profile?.personal.name,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to change photo',
                              style: AppTypography.bodySM.copyWith(
                                color: AppColors.primaryLight,
                              ),
                            ),
                            const SizedBox(height: 32),

                            GlowTextField(
                              label: 'Full Name',
                              controller: _nameCtrl,
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),
                            GlowTextField(
                              label: 'Email',
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),
                            GlowTextField(
                              label: 'Phone',
                              controller: _phoneCtrl,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),
                            GlowTextField(
                              label: 'Professional Headline',
                              controller: _headlineCtrl,
                              hint: 'e.g. Flutter Developer & UI Designer',
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

// ── Shared Edit AppBar ──────────────────────────────────────────────────────
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
