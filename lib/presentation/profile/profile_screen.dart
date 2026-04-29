// lib/presentation/profile/profile_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../data/models/user_model.dart';
import '../../data/models/experience_model.dart';
import '../../data/models/education_model.dart';
import '../../widgets/cards/skill_chip.dart';
import '../../widgets/common/glass_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Profile not found'));
          }
          return _ProfileContent(profile: profile);
        },
      ),
    );
  }
}

class _ProfileContent extends ConsumerWidget {
  final UserProfile profile;

  const _ProfileContent({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _HeroHeader(profile: profile),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 24),
              if (profile.goals.bio.isNotEmpty) ...[
                _SectionCard(
                  title: 'About',
                  emoji: '👤',
                  editRoute: AppRoutes.editGoals,
                  child: Text(profile.goals.bio, style: AppTypography.bodyMD),
                ),
                const SizedBox(height: 16),
              ],
              if (profile.skills.isNotEmpty) ...[
                _SectionCard(
                  title: 'Skills',
                  emoji: '🛠️',
                  editRoute: AppRoutes.editSkills,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: profile.skills.asMap().entries.map((e) {
                      return SkillChip(
                        label: e.value,
                        colorIndex: e.key,
                        showDelete: false,
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (profile.experience.isNotEmpty) ...[
                _SectionCard(
                  title: 'Experience',
                  emoji: '💼',
                  editRoute: AppRoutes.editExperience,
                  child: Column(
                    children: profile.experience
                        .asMap()
                        .entries
                        .map((e) => _ExperienceItem(
                              exp: e.value,
                              isLast: e.key == profile.experience.length - 1,
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (profile.education.isNotEmpty) ...[
                _SectionCard(
                  title: 'Education',
                  emoji: '🎓',
                  editRoute: AppRoutes.editEducation,
                  child: Column(
                    children: profile.education
                        .map((edu) => _EducationItem(edu: edu))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (profile.goals.interests.isNotEmpty ||
                  profile.goals.careerGoal.isNotEmpty) ...[
                _SectionCard(
                  title: 'Goals & Interests',
                  emoji: '🌟',
                  editRoute: AppRoutes.editGoals,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (profile.goals.careerGoal.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0x157C3AED), Color(0x15EC4899)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.primary.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              const Text('🎯', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(profile.goals.careerGoal,
                                    style: AppTypography.bodyMD),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                      if (profile.goals.interests.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: profile.goals.interests
                              .map((i) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.bgDarkCard,
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(
                                          color: AppColors.glassBorderDark),
                                    ),
                                    child: Text(
                                      i,
                                      style: AppTypography.bodySM.copyWith(
                                          color: AppColors.textSecondary),
                                    ),
                                  ))
                              .toList(),
                        ),
                    ],
                  ),
                ),
              ],
            ]),
          ),
        ),
      ],
    );
  }
}

// ============ HERO HEADER ============
class _HeroHeader extends ConsumerWidget {
  final UserProfile profile;

  const _HeroHeader({required this.profile});

  /// Returns true only when photoUrl is a real, non-empty URL
  bool get _hasPhoto =>
      profile.personal.photoUrl != null &&
      profile.personal.photoUrl!.isNotEmpty;

  String get _initials {
    final name = profile.personal.name.trim();
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Widget _avatarContent() {
    if (_hasPhoto) {
      return Image.network(
        profile.personal.photoUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return const Center(
            child:
                CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          );
        },
        errorBuilder: (_, __, ___) => _initialsWidget(),
      );
    }
    return _initialsWidget();
  }

  Widget _initialsWidget() {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: Center(
        child: Text(
          _initials,
          style: const TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontFamily: 'ClashDisplay',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative circles
          Positioned.fill(
            child: IgnorePointer(
              child: ClipRect(
                child: Stack(
                  children: [
                    Positioned(
                      top: -60,
                      right: -60,
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -40,
                      left: -40,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 100,
                      right: 20,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.04),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                children: [
                  // Top bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _IconBtn(
                        icon: Icons.home_rounded,
                        onTap: () => context.go(AppRoutes.home),
                        tooltip: 'Home',
                      ),
                      Text(
                        'My Profile',
                        style: AppTypography.h2.copyWith(
                          color: Colors.white.withOpacity(0.92),
                          letterSpacing: 0.3,
                        ),
                      ),
                      _IconBtn(
                        icon: Icons.logout_rounded,
                        onTap: () async {
                          await ref
                              .read(authNotifierProvider.notifier)
                              .signOut();
                          if (context.mounted) {
                            context.go(AppRoutes.login);
                          }
                        },
                        tooltip: 'Sign out',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Avatar + info
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.push(AppRoutes.editPersonal),
                        child: Stack(
                          children: [
                            // Outer glow ring
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppColors.primaryGradient,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.35),
                                    blurRadius: 24,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                            // Inner avatar
                            Positioned.fill(
                              child: Padding(
                                padding: const EdgeInsets.all(3),
                                child: ClipOval(child: _avatarContent()),
                              ),
                            ),
                            // Edit badge
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.18),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.edit_rounded,
                                  size: 13,
                                  color: Color(0xFF7C3AED),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.personal.name,
                              style: AppTypography.h1
                                  .copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profile.personal.headline,
                              style: AppTypography.bodyMD.copyWith(
                                  color: Colors.white.withOpacity(0.78)),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            if (profile.personal.email.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.2)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.email_rounded,
                                      color: Colors.white.withOpacity(0.7),
                                      size: 13,
                                    ),
                                    const SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        profile.personal.email,
                                        style: AppTypography.bodySM.copyWith(
                                            color:
                                                Colors.white.withOpacity(0.8)),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Stats row
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.11),
                          borderRadius: BorderRadius.circular(18),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.22)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatItem(
                              count: '${profile.skills.length}',
                              label: 'Skills',
                              emoji: '🛠️',
                            ),
                            _VerticalDivider(),
                            _StatItem(
                              count: '${profile.experience.length}',
                              label: 'Jobs',
                              emoji: '💼',
                            ),
                            _VerticalDivider(),
                            _StatItem(
                              count: '${profile.education.length}',
                              label: 'Degrees',
                              emoji: '🎓',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============ ICON BUTTON ============
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  const _IconBtn({required this.icon, required this.onTap, this.tooltip});

  @override
  Widget build(BuildContext context) {
    final btn = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.14),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Colors.white.withOpacity(0.22)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 19),
      ),
    );
    if (tooltip != null) return Tooltip(message: tooltip!, child: btn);
    return btn;
  }
}

// ============ STAT ITEM ============
class _StatItem extends StatelessWidget {
  final String count;
  final String label;
  final String emoji;

  const _StatItem(
      {required this.count, required this.label, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 4),
        Text(count, style: AppTypography.h2.copyWith(color: Colors.white)),
        Text(
          label,
          style: AppTypography.caption
              .copyWith(color: Colors.white.withOpacity(0.68)),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withOpacity(0.18),
    );
  }
}

// ============ SECTION CARD ============
class _SectionCard extends StatelessWidget {
  final String title;
  final String emoji;
  final String editRoute;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.emoji,
    required this.editRoute,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: AppColors.primary.withOpacity(0.18)),
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 12),
                Text(title, style: AppTypography.h3),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.push(editRoute),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Edit',
                      style: AppTypography.labelSM.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.glassBorderDark,
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.all(18), child: child),
        ],
      ),
    );
  }
}

// ============ EXPERIENCE ITEM ============
class _ExperienceItem extends StatelessWidget {
  final ExperienceModel exp;
  final bool isLast;

  const _ExperienceItem({required this.exp, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: AppColors.primaryGlow,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exp.role, style: AppTypography.labelLG),
                  const SizedBox(height: 2),
                  Text(
                    exp.company,
                    style: AppTypography.bodyMD
                        .copyWith(color: AppColors.primaryLight),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${exp.startDate} – ${exp.isCurrent ? 'Present' : (exp.endDate ?? '')}',
                    style: AppTypography.bodySM,
                  ),
                  if (exp.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(exp.description, style: AppTypography.bodySM),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============ EDUCATION ITEM ============
class _EducationItem extends StatelessWidget {
  final EducationModel edu;

  const _EducationItem({required this.edu});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: AppColors.mintGradient,
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child:
                const Icon(Icons.school_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(edu.degree, style: AppTypography.labelLG),
                Text(
                  edu.institution,
                  style: AppTypography.bodyMD.copyWith(color: AppColors.accent),
                ),
                Text(
                  '${edu.field} • ${edu.startYear}–${edu.endYear}',
                  style: AppTypography.bodySM,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
