// lib/presentation/splash/splash_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../providers/profile_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainCtrl;
  late AnimationController _bgCtrl;

  late Animation<double> _fade;
  late Animation<double> _scale;
  late Animation<double> _slide;

  @override
  void initState() {
    super.initState();

    _mainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _fade = CurvedAnimation(parent: _mainCtrl, curve: Curves.easeIn);
    _scale = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(parent: _mainCtrl, curve: Curves.elasticOut),
    );
    _slide = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _mainCtrl, curve: Curves.easeOut),
    );

    _mainCtrl.forward();
    _navigate();
  }

  // 🚀 Navigation Logic
  void _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final user = ref.read(currentUserProvider);

    if (user == null) {
      context.go(AppRoutes.login);
    } else {
      final profile =
          await ref.read(profileRepositoryProvider).getProfile(user.uid);

      if (profile == null || !profile.onboardingComplete) {
        context.go(AppRoutes.onboarding);
      } else {
        context.go(AppRoutes.profile);
      }
    }
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    _bgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgCtrl,
        builder: (_, __) {
          return Stack(
            children: [
              // 🌌 Aurora Background
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
                      Color(0xFF0B1120),
                      Color(0xFF1E293B),
                    ],
                  ),
                ),
              ),

              // 🌊 Moving light effect
              Positioned.fill(
                child: Opacity(
                  opacity: 0.25,
                  child: Transform.translate(
                    offset: Offset(
                      sin(_bgCtrl.value * 2 * pi) * 40,
                      cos(_bgCtrl.value * 2 * pi) * 40,
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Color(0xFF38BDF8),
                            Colors.transparent,
                          ],
                          radius: 0.6,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 🔮 Glow orbs
              Positioned(
                top: -100,
                left: -60,
                child: _glowCircle(340, AppColors.primary.withOpacity(0.25)),
              ),
              Positioned(
                bottom: -120,
                right: -80,
                child: _glowCircle(300, AppColors.secondary.withOpacity(0.25)),
              ),

              // 🧊 Glass overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                  ),
                ),
              ),

              // ✨ Main Content
              Center(
                child: FadeTransition(
                  opacity: _fade,
                  child: Transform.translate(
                    offset: Offset(0, _slide.value),
                    child: ScaleTransition(
                      scale: _scale,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 💎 Logo with shimmer
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.95, end: 1.05),
                            duration: const Duration(seconds: 2),
                            curve: Curves.easeInOut,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: child,
                              );
                            },
                            child: Stack(
                              children: [
                                Container(
                                  width: 115,
                                  height: 115,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(32),
                                    boxShadow: [
                                      ...AppColors.primaryGlow,
                                      BoxShadow(
                                        color:
                                            AppColors.primary.withOpacity(0.5),
                                        blurRadius: 50,
                                        spreadRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '✦',
                                      style: TextStyle(
                                        fontSize: 46,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),

                                // ✨ Shimmer sweep
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(32),
                                    child: AnimatedBuilder(
                                      animation: _bgCtrl,
                                      builder: (_, __) {
                                        return Transform.translate(
                                          offset: Offset(
                                            _bgCtrl.value * 200 - 100,
                                            0,
                                          ),
                                          child: Container(
                                            width: 60,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.transparent,
                                                  Colors.white.withOpacity(0.4),
                                                  Colors.transparent,
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 34),

                          // 🌈 App Name
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                AppColors.primaryGradient.createShader(bounds),
                            child: Text(
                              'ResumeFY',
                              style: AppTypography.displayLG.copyWith(
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // 💬 Subtitle
                          Opacity(
                            opacity: 0.65,
                            child: Text(
                              'Design your digital identity',
                              style: AppTypography.bodyMD.copyWith(
                                fontSize: 14,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),

                          const SizedBox(height: 60),

                          // ⚡ Loader
                          const _PulseLoader(),
                        ],
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

  Widget _glowCircle(double size, Color color) {
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

// ⚡ Premium Pulse Loader
class _PulseLoader extends StatefulWidget {
  const _PulseLoader();

  @override
  State<_PulseLoader> createState() => _PulseLoaderState();
}

class _PulseLoaderState extends State<_PulseLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.6),
            width: 2,
          ),
        ),
      ),
    );
  }
}
