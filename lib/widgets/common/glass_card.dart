// lib/widgets/common/glass_card.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final double blurSigma;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.borderColor,
    this.blurSigma = 12,
    this.backgroundColor,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(20);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: backgroundColor ??
                (isDark ? AppColors.glassDark : AppColors.glassLight),
            borderRadius: radius,
            border: Border.all(
              color: borderColor ??
                  (isDark
                      ? AppColors.glassBorderDark
                      : AppColors.glassBorderLight),
              width: 1,
            ),
            boxShadow: boxShadow ?? AppColors.cardShadow,
          ),
          child: child,
        ),
      ),
    );
  }
}
