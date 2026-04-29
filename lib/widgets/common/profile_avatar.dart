// lib/widgets/common/profile_avatar.dart

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../providers/profile_provider.dart';

class ProfileAvatar extends ConsumerStatefulWidget {
  final String? photoUrl;
  final String? displayName;
  final double size;

  const ProfileAvatar({
    super.key,
    this.photoUrl,
    this.displayName,
    this.size = 96,
  });

  @override
  ConsumerState<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends ConsumerState<ProfileAvatar> {
  File? _localFile;
  bool _uploading = false;

  String get _initials {
    final name = widget.displayName?.trim() ?? '';
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  /// True only when photoUrl is a real non-empty string
  bool get _hasNetworkPhoto =>
      widget.photoUrl != null && widget.photoUrl!.isNotEmpty;

  Future<void> _pick(ImageSource source) async {
    Navigator.pop(context);
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (picked == null || picked.path.isEmpty) return;

    final file = File(picked.path);
    setState(() {
      _localFile = file;
      _uploading = true;
    });

    await ref.read(profileNotifierProvider.notifier).uploadAndSetPhoto(file);

    if (mounted) setState(() => _uploading = false);
  }

  Future<void> _remove() async {
    Navigator.pop(context);
    setState(() {
      _localFile = null;
      _uploading = true;
    });
    await ref.read(profileNotifierProvider.notifier).removePhoto();
    if (mounted) setState(() => _uploading = false);
  }

  void _showSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgDarkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.glassBorderDark,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Profile Photo', style: AppTypography.h2),
              const SizedBox(height: 20),
              _SheetTile(
                icon: Icons.camera_alt_rounded,
                label: 'Take a photo',
                onTap: () => _pick(ImageSource.camera),
              ),
              _SheetTile(
                icon: Icons.photo_library_rounded,
                label: 'Choose from gallery',
                onTap: () => _pick(ImageSource.gallery),
              ),
              if (_hasNetworkPhoto || _localFile != null)
                _SheetTile(
                  icon: Icons.delete_outline_rounded,
                  label: 'Remove photo',
                  destructive: true,
                  onTap: _remove,
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  /// Renders either a data-URI (base64) or a regular https URL correctly.
  Widget _remoteImage(String url) {
    if (url.startsWith('data:image')) {
      try {
        final base64Str = url.split(',').last;
        return Image.memory(
          base64Decode(base64Str),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _InitialsFallback(initials: _initials),
        );
      } catch (_) {
        return _InitialsFallback(initials: _initials);
      }
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        );
      },
      errorBuilder: (_, __, ___) => _InitialsFallback(initials: _initials),
    );
  }

  Widget _buildAvatarContent() {
    // 1. Uploading spinner
    if (_uploading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
      );
    }

    // 2. Optimistic local file preview (just picked, not yet confirmed)
    if (_localFile != null) {
      return Image.file(_localFile!, fit: BoxFit.cover);
    }

    // 3. Remote photo (data-URI or https) — guard against empty string
    if (_hasNetworkPhoto) {
      return _remoteImage(widget.photoUrl!);
    }

    // 4. Initials fallback
    return _InitialsFallback(initials: _initials);
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = _localFile != null || _hasNetworkPhoto;

    return GestureDetector(
      onTap: _showSheet,
      child: Stack(
        children: [
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              gradient: hasPhoto ? null : AppColors.primaryGradient,
              color: hasPhoto ? Colors.black : null,
              shape: BoxShape.circle,
              boxShadow: AppColors.primaryGlow,
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildAvatarContent(),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.bgDarkCard,
                shape: BoxShape.circle,
                border:
                    Border.all(color: AppColors.glassBorderDark, width: 1.5),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: AppColors.primaryLight,
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Initials fallback ─────────────────────────────────────────────────────
class _InitialsFallback extends StatelessWidget {
  final String initials;
  const _InitialsFallback({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ── Bottom-sheet tile ─────────────────────────────────────────────────────
class _SheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  const _SheetTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? Colors.redAccent : AppColors.textPrimary;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color, size: 22),
      title: Text(label, style: AppTypography.bodyMD.copyWith(color: color)),
      onTap: onTap,
    );
  }
}
