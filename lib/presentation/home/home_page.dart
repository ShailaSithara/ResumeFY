import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/theme_provider.dart';
import '../../data/models/user_model.dart';
import '../../widgets/common/glass_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileStreamProvider);
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradientDark),
        child: Stack(children: [
          // Background orbs
          Positioned(
              top: -80,
              right: -60,
              child: _Orb(260, AppColors.primary.withOpacity(0.2))),
          Positioned(
              bottom: 200,
              left: -80,
              child: _Orb(220, AppColors.secondary.withOpacity(0.15))),

          SafeArea(
            child: profileAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (profile) =>
                  _HomeContent(profile: profile, themeMode: themeMode),
            ),
          ),
        ]),
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  final UserProfile? profile;
  final ThemeMode themeMode;
  const _HomeContent({required this.profile, required this.themeMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = profile?.personal.name ?? 'User';
    final firstName = name.split(' ').first;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    final completionPct = _completionPercent(profile);

    return CustomScrollView(
      slivers: [
        // ── Top bar ──────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('$greeting 👋',
                      style: AppTypography.bodySM
                          .copyWith(color: AppColors.textMuted)),
                  Text(firstName, style: AppTypography.h1),
                ]),
                Row(children: [
                  // Theme toggle
                  GestureDetector(
                    onTap: () => ref.read(themeProvider.notifier).toggle(),
                    child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                            color: AppColors.bgDarkCard,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: AppColors.glassBorderDark)),
                        child: Icon(
                            themeMode == ThemeMode.dark
                                ? Icons.light_mode_rounded
                                : Icons.dark_mode_rounded,
                            color: AppColors.textSecondary,
                            size: 20)),
                  ),
                  const SizedBox(width: 10),
                  // Avatar
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.profile),
                    child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: AppColors.primaryGlow),
                        child: Center(
                            child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)))),
                  ),
                ]),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(child: const SizedBox(height: 24)),

        // ── Profile Completion Card ───────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _CompletionCard(percent: completionPct),
          ),
        ),

        SliverToBoxAdapter(child: const SizedBox(height: 24)),

        // ── Quick Actions ────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Quick Actions', style: AppTypography.h3),
              const SizedBox(height: 14),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _ActionCard(
                      emoji: '👤',
                      label: 'Edit Profile',
                      subtitle: 'Update your info',
                      gradient: AppColors.primaryGradient,
                      onTap: () => context.go(AppRoutes.profile)),
                  // _ActionCard(
                  //     emoji: '📄',
                  //     label: 'Download PDF',
                  //     subtitle: 'Export your resume',
                  //     gradient: AppColors.cyanGradient,
                  //     onTap: () => context.go(AppRoutes.resumePreview)),
                  _ActionCard(
                      emoji: '🛠️',
                      label: 'Edit Skills',
                      subtitle: 'Add new skills',
                      gradient: AppColors.mintGradient,
                      onTap: () => context.push(AppRoutes.editSkills)),
                  _ActionCard(
                      emoji: '💼',
                      label: 'Experience',
                      subtitle: 'Add work history',
                      gradient: AppColors.sunsetGradient,
                      onTap: () => context.push(AppRoutes.editExperience)),
                ],
              ),
            ]),
          ),
        ),

        SliverToBoxAdapter(child: const SizedBox(height: 24)),

        // ── Profile Summary ──────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Profile Summary', style: AppTypography.h3),
              const SizedBox(height: 14),
              _SummaryCard(profile: profile),
            ]),
          ),
        ),

        SliverToBoxAdapter(child: const SizedBox(height: 24)),

        // ── Resume Stats ─────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Resume Stats', style: AppTypography.h3),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                    child: _StatCard(
                        count: '${profile?.skills.length ?? 0}',
                        label: 'Skills',
                        emoji: '🛠️',
                        color: AppColors.primary)),
                const SizedBox(width: 12),
                Expanded(
                    child: _StatCard(
                        count: '${profile?.experience.length ?? 0}',
                        label: 'Jobs',
                        emoji: '💼',
                        color: AppColors.secondary)),
                const SizedBox(width: 12),
                Expanded(
                    child: _StatCard(
                        count: '${profile?.education.length ?? 0}',
                        label: 'Degrees',
                        emoji: '🎓',
                        color: AppColors.accent)),
              ]),
            ]),
          ),
        ),

        SliverToBoxAdapter(child: const SizedBox(height: 24)),

        // ── Sign Out ─────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
            child: GestureDetector(
              onTap: () => ref.read(authNotifierProvider.notifier).signOut(),
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.logout_rounded,
                      color: AppColors.error, size: 18),
                  const SizedBox(width: 8),
                  Text('Sign Out',
                      style: AppTypography.labelLG
                          .copyWith(color: AppColors.error)),
                ]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  int _completionPercent(UserProfile? p) {
    if (p == null) return 0;
    int score = 0;
    if (p.personal.name.isNotEmpty) score += 20;
    if (p.personal.headline.isNotEmpty) score += 10;
    if (p.skills.isNotEmpty) score += 20;
    if (p.experience.isNotEmpty) score += 20;
    if (p.education.isNotEmpty) score += 20;
    if (p.goals.bio.isNotEmpty) score += 10;
    return score;
  }
}

// ── Completion Card ─────────────────────────────────────────────────────────
class _CompletionCard extends StatelessWidget {
  final int percent;
  const _CompletionCard({required this.percent});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.25),
                AppColors.secondary.withOpacity(0.15)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Profile Completion', style: AppTypography.labelLG),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(100)),
                child: Text('$percent%',
                    style: AppTypography.labelMD.copyWith(color: Colors.white)),
              ),
            ]),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: percent / 100,
                minHeight: 8,
                backgroundColor: AppColors.glassBorderDark,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              percent < 50
                  ? '🚀 Add more sections to stand out!'
                  : percent < 80
                      ? '✨ Almost there! Keep adding details.'
                      : '🎉 Great profile! Ready to download.',
              style: AppTypography.bodySM,
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Action Card ─────────────────────────────────────────────────────────────
class _ActionCard extends StatelessWidget {
  final String emoji, label, subtitle;
  final Gradient gradient;
  final VoidCallback onTap;

  const _ActionCard(
      {required this.emoji,
      required this.label,
      required this.subtitle,
      required this.gradient,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgDarkCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.glassBorderDark),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                      child:
                          Text(emoji, style: const TextStyle(fontSize: 18)))),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: AppTypography.labelLG),
                Text(subtitle, style: AppTypography.bodySM),
              ]),
            ]),
      ),
    );
  }
}

// ── Summary Card ────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final UserProfile? profile;
  const _SummaryCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(children: [
        _Row(Icons.person_rounded, AppColors.primary, 'Name',
            profile?.personal.name ?? '—'),
        const Divider(height: 20, color: AppColors.glassBorderDark),
        _Row(Icons.work_rounded, AppColors.secondary, 'Headline',
            profile?.personal.headline ?? '—'),
        const Divider(height: 20, color: AppColors.glassBorderDark),
        _Row(Icons.email_rounded, AppColors.accent, 'Email',
            profile?.personal.email ?? '—'),
        if (profile?.goals.careerGoal.isNotEmpty == true) ...[
          const Divider(height: 20, color: AppColors.glassBorderDark),
          _Row(Icons.flag_rounded, AppColors.success, 'Goal',
              profile!.goals.careerGoal),
        ],
      ]),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label, value;
  const _Row(this.icon, this.color, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18)),
      const SizedBox(width: 14),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppTypography.bodySM),
        Text(value,
            style: AppTypography.labelMD.copyWith(color: AppColors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ])),
    ]);
  }
}

// ── Stat Card ────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String count, label, emoji;
  final Color color;
  const _StatCard(
      {required this.count,
      required this.label,
      required this.emoji,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 6),
        Text(count, style: AppTypography.h1.copyWith(color: color)),
        Text(label, style: AppTypography.bodySM),
      ]),
    );
  }
}

// ── Gradient consts used in action cards ────────────────────────────────────
extension on AppColors {
  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class _Orb extends StatelessWidget {
  final double size;
  final Color color;
  const _Orb(this.size, this.color);
  @override
  Widget build(BuildContext context) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, Colors.transparent])));
}
