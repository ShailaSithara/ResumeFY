// lib/presentation/auth/signup/signup_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/common/gradient_button.dart';
import '../../../widgets/inputs/glow_text_field.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscure = true;
  bool _obscureConfirm = true;
  String? _error;

  late AnimationController _animCtrl;
  late AnimationController _bgCtrl;

  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _fade = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));

    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _bgCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _error = null);

    await ref.read(authNotifierProvider.notifier).signUpWithEmail(
          _emailCtrl.text.trim(),
          _passCtrl.text,
        );

    final state = ref.read(authNotifierProvider);

    if (state.hasError && mounted) {
      setState(() => _error = state.error.toString());
    } else if (!state.hasError && mounted) {
      context.go(AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgCtrl,
        builder: (_, __) {
          return Stack(
            children: [
              // 🌌 Background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(
                      cos(_bgCtrl.value * 2 * pi),
                      sin(_bgCtrl.value * 2 * pi),
                    ),
                    end: Alignment.bottomRight,
                    colors: const [
                      Color(0xFF020617),
                      Color(0xFF0F172A),
                      Color(0xFF1E293B),
                    ],
                  ),
                ),
              ),

              // 🔮 Glow
              Positioned(
                top: -100,
                left: -60,
                child: _GlowOrb(
                    size: 300, color: AppColors.secondary.withOpacity(0.25)),
              ),

              // 🔙 Back button
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back),
                    ),
                  ),
                ),
              ),

              // 📱 Content
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(28),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 💎 Logo
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Center(
                                  child:
                                      Text('✦', style: TextStyle(fontSize: 28)),
                                ),
                              ),

                              const SizedBox(height: 20),

                              Text("Create account",
                                  style: AppTypography.displayMD),

                              const SizedBox(height: 6),

                              Text("Start your journey",
                                  style: AppTypography.bodyMD),

                              const SizedBox(height: 24),

                              // Email
                              GlowTextField(
                                label: 'Email',
                                controller: _emailCtrl,
                                prefixIcon: const Icon(Icons.email_outlined),
                              ),

                              const SizedBox(height: 14),

                              // Password
                              GlowTextField(
                                label: 'Password',
                                controller: _passCtrl,
                                obscureText: _obscure,
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscure
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                              ),

                              const SizedBox(height: 6),

                              // Password hint (UX upgrade)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "At least 6 characters",
                                  style: AppTypography.caption,
                                ),
                              ),

                              const SizedBox(height: 14),

                              // Confirm
                              GlowTextField(
                                label: 'Confirm Password',
                                controller: _confirmCtrl,
                                obscureText: _obscureConfirm,
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscureConfirm
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () => setState(
                                      () => _obscureConfirm = !_obscureConfirm),
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Error message
                              if (_error != null)
                                Text(
                                  _error!,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 12),
                                ),

                              const SizedBox(height: 20),

                              GradientButton(
                                label: 'Create Account',
                                onPressed: _signUp,
                                isLoading: isLoading,
                              ),

                              const SizedBox(height: 16),

                              GestureDetector(
                                onTap: () => context.go(AppRoutes.login),
                                child: Text(
                                  "Already have an account? Sign in",
                                  style: AppTypography.labelMD.copyWith(
                                    color: AppColors.primaryLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Glow
class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}
