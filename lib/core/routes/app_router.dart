import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../presentation/home/home_page.dart';
import '../../providers/auth_provider.dart';

// Screens
import '../../presentation/splash/splash_screen.dart';
import '../../presentation/auth/login/login_screen.dart';
import '../../presentation/auth/signup/signup_screen.dart';
import '../../presentation/onboarding/onboarding_shell.dart';
import '../../presentation/profile/profile_screen.dart';
import '../../presentation/profile/edit/edit_personal.dart';
import '../../presentation/profile/edit/edit_skills.dart';
import '../../presentation/profile/edit/edit_experience.dart';
import '../../presentation/profile/edit/edit_education.dart';
import '../../presentation/profile/edit/edit_goals.dart';

import 'app_routes.dart';

/// A [ChangeNotifier] that listens to Firebase auth state changes
/// and notifies GoRouter to re-run its redirect logic.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier() {
    FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });
  }
}

final _authChangeNotifier = _AuthChangeNotifier();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,

    /// 🔥 KEY FIX: GoRouter now re-runs redirect every time auth state changes
    refreshListenable: _authChangeNotifier,

    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final isLoggedIn = user != null;

      final loc = state.matchedLocation;

      final isSplash = loc == AppRoutes.splash;
      final isLogin = loc == AppRoutes.login;
      final isSignup = loc == AppRoutes.signup;

      // Always allow splash
      if (isSplash) return null;

      // Not logged in → force login
      if (!isLoggedIn && !(isLogin || isSignup)) {
        return AppRoutes.login;
      }

      // Logged in → block login/signup
      if (isLoggedIn && (isLogin || isSignup)) {
        return AppRoutes.home;
      }

      return null;
    },

    routes: [
      /// ───────────── SPLASH ─────────────
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        pageBuilder: (context, state) => _fadePage(state, const SplashScreen()),
      ),

      /// ───────────── LOGIN ─────────────
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => _fadePage(state, const LoginScreen()),
      ),

      /// ───────────── SIGNUP ─────────────
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        pageBuilder: (context, state) => _fadePage(state, const SignupScreen()),
      ),

      /// ───────────── ONBOARDING ─────────────
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) =>
            _fadePage(state, const OnboardingShell()),
      ),

      /// ───────────── HOME ─────────────
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const HomeScreen()),
      ),

      /// ───────────── PROFILE ─────────────
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        pageBuilder: (context, state) =>
            _fadePage(state, const ProfileScreen()),
      ),

      /// ───────────── EDIT PAGES (slide up) ─────────────
      GoRoute(
        path: AppRoutes.editPersonal,
        name: 'editPersonal',
        pageBuilder: (context, state) =>
            _slidePage(state, const EditPersonalScreen()),
      ),
      GoRoute(
        path: AppRoutes.editSkills,
        name: 'editSkills',
        pageBuilder: (context, state) =>
            _slidePage(state, const EditSkillsScreen()),
      ),
      GoRoute(
        path: AppRoutes.editExperience,
        name: 'editExperience',
        pageBuilder: (context, state) =>
            _slidePage(state, const EditExperienceScreen()),
      ),
      GoRoute(
        path: AppRoutes.editEducation,
        name: 'editEducation',
        pageBuilder: (context, state) =>
            _slidePage(state, const EditEducationScreen()),
      ),
      GoRoute(
        path: AppRoutes.editGoals,
        name: 'editGoals',
        pageBuilder: (context, state) =>
            _slidePage(state, const EditGoalsScreen()),
      ),
    ],

    /// ERROR PAGE
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.error}'),
      ),
    ),
  );
});

/// ─────────────────────────────────────────
/// FADE PAGE
CustomTransitionPage _fadePage(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (context, animation, _, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ),
        child: child,
      );
    },
  );
}

/// ─────────────────────────────────────────
/// FADE + SLIDE (HOME)
CustomTransitionPage _fadeSlidePage(
  GoRouterState state,
  Widget child,
) {
  final tween = Tween(
    begin: const Offset(0, 0.12),
    end: Offset.zero,
  ).chain(CurveTween(curve: Curves.easeOutCubic));

  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 450),
    transitionsBuilder: (context, animation, _, child) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: animation.drive(tween),
          child: child,
        ),
      );
    },
  );
}

/// ─────────────────────────────────────────
/// SLIDE UP (EDIT PAGES)
CustomTransitionPage _slidePage(
  GoRouterState state,
  Widget child,
) {
  final tween = Tween(
    begin: const Offset(0, 0.08),
    end: Offset.zero,
  ).chain(CurveTween(curve: Curves.easeOut));

  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, _, child) {
      return SlideTransition(
        position: animation.drive(tween),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
  );
}
