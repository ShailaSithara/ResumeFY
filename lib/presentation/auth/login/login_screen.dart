// lib/presentation/auth/login/login_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/common/gradient_button.dart';
import '../../../widgets/inputs/glow_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _obscure = true;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOut,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animCtrl,
        curve: Curves.easeOutCubic,
      ),
    );

    _animCtrl.forward();

    /// ✅ SAFE LISTENER (runs once)
    ref.listenManual(authNotifierProvider, (prev, next) {
      next.when(
        data: (_) {
          if (mounted) context.go('/home');
        },
        loading: () {},
        error: (err, _) {
          if (mounted) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(err.toString()),
                  behavior: SnackBarBehavior.floating,
                ),
              );
          }
        },
      );
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authNotifierProvider.notifier).signInWithEmail(
          _emailCtrl.text.trim(),
          _passCtrl.text.trim(),
        );
  }

  Future<void> _googleSignIn() async {
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: Stack(
        children: [
          /// 🌌 BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF050816),
                  Color(0xFF0F172A),
                  Color(0xFF020617),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /// ✨ GLOWS
          Positioned(
            top: -120,
            right: -80,
            child:
                _GlowOrb(size: 280, color: Colors.blueAccent.withOpacity(0.25)),
          ),
          Positioned(
            bottom: 60,
            left: -90,
            child: _GlowOrb(
                size: 260, color: Colors.purpleAccent.withOpacity(0.2)),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: _GlassCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// HEADER
                            ShaderMask(
                              shaderCallback: (bounds) => AppColors
                                  .primaryGradient
                                  .createShader(bounds),
                              child: Text(
                                'Welcome Back',
                                style: AppTypography.displayLG.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              'Login to continue your journey 🚀',
                              style: AppTypography.bodyMD.copyWith(
                                color: Colors.white70,
                              ),
                            ),

                            const SizedBox(height: 28),

                            /// EMAIL
                            GlowTextField(
                              label: 'Email',
                              controller: _emailCtrl,
                              hint: 'you@example.com',
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Enter email' : null,
                            ),

                            const SizedBox(height: 14),

                            /// PASSWORD
                            GlowTextField(
                              label: 'Password',
                              controller: _passCtrl,
                              obscureText: _obscure,
                              validator: (v) => v != null && v.length < 6
                                  ? 'Min 6 characters'
                                  : null,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  color: Colors.white70,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),

                            const SizedBox(height: 8),

                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            /// LOGIN BUTTON
                            GradientButton(
                              label: 'Sign In',
                              onPressed: _signIn,
                              isLoading: isLoading,
                            ),

                            const SizedBox(height: 18),

                            /// DIVIDER
                            Row(
                              children: const [
                                Expanded(child: Divider(color: Colors.white24)),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                ),
                                Expanded(child: Divider(color: Colors.white24)),
                              ],
                            ),

                            const SizedBox(height: 18),

                            /// GOOGLE
                            _GoogleButton(onPressed: _googleSignIn),

                            const SizedBox(height: 22),

                            /// SIGNUP
                            Center(
                              child: GestureDetector(
                                onTap: () => context.go('/signup'),
                                child: RichText(
                                  text: const TextSpan(
                                    text: "Don't have an account? ",
                                    style: TextStyle(color: Colors.white70),
                                    children: [
                                      TextSpan(
                                        text: "Sign Up",
                                        style: TextStyle(
                                          color: Colors.blueAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    ],
                                  ),
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
          ),
        ],
      ),
    );
  }
}

/// 💎 GLASS CARD
class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// ✨ GLOW ORB
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
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
        ),
      ),
    );
  }
}

/// 🔵 GOOGLE BUTTON
class _GoogleButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _GoogleButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: Colors.white24),
        ),
        child: const Center(
          child: Text(
            'Continue with Google',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
