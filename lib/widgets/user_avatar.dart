import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_theme.dart';

class UserAvatar extends StatelessWidget {
  final String? displayName;
  final String? avatarUrl;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.displayName,
    this.avatarUrl,
    this.size = 60.0,
    this.backgroundColor,
    this.textColor,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 2.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor =
        backgroundColor ?? _generateColorFromName(displayName ?? 'User');

    final effectiveTextColor = textColor ?? AppTheme.textPrimaryColor;

    Widget avatarWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            effectiveBackgroundColor,
            effectiveBackgroundColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: borderColor ?? AppTheme.primaryColor,
                width: borderWidth,
              )
            : null,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Center(child: _buildAvatarContent(effectiveTextColor)),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(size / 2),
          child: avatarWidget,
        ),
      );
    }

    return avatarWidget;
  }

  Widget _buildAvatarContent(Color textColor) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          avatarUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildTextAvatar(textColor);
          },
        ),
      );
    }

    return _buildTextAvatar(textColor);
  }

  Widget _buildTextAvatar(Color textColor) {
    final initials = _getInitials(displayName ?? 'User');
    final fontSize = size * 0.4;

    return Text(
      initials,
      style: GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';

    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return name[0].toUpperCase();
    }

    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Color _generateColorFromName(String name) {
    if (name.isEmpty) return AppTheme.primaryColor;

    final colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.accentColor,
      Colors.purple.shade400,
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.red.shade400,
      Colors.teal.shade400,
      Colors.indigo.shade400,
    ];

    final hash = name.hashCode;
    return colors[hash.abs() % colors.length];
  }
}

// Variantes d'avatars
class SmallAvatar extends StatelessWidget {
  final String? displayName;
  final String? avatarUrl;
  final VoidCallback? onTap;

  const SmallAvatar({super.key, this.displayName, this.avatarUrl, this.onTap});

  @override
  Widget build(BuildContext context) {
    return UserAvatar(
      displayName: displayName,
      avatarUrl: avatarUrl,
      size: 40.0,
      onTap: onTap,
    );
  }
}

class MediumAvatar extends StatelessWidget {
  final String? displayName;
  final String? avatarUrl;
  final VoidCallback? onTap;

  const MediumAvatar({super.key, this.displayName, this.avatarUrl, this.onTap});

  @override
  Widget build(BuildContext context) {
    return UserAvatar(
      displayName: displayName,
      avatarUrl: avatarUrl,
      size: 60.0,
      onTap: onTap,
    );
  }
}

class LargeAvatar extends StatelessWidget {
  final String? displayName;
  final String? avatarUrl;
  final VoidCallback? onTap;

  const LargeAvatar({super.key, this.displayName, this.avatarUrl, this.onTap});

  @override
  Widget build(BuildContext context) {
    return UserAvatar(
      displayName: displayName,
      avatarUrl: avatarUrl,
      size: 80.0,
      onTap: onTap,
    );
  }
}

class AvatarWithStatus extends StatelessWidget {
  final String? displayName;
  final String? avatarUrl;
  final bool isOnline;
  final double size;
  final VoidCallback? onTap;

  const AvatarWithStatus({
    super.key,
    this.displayName,
    this.avatarUrl,
    this.isOnline = false,
    this.size = 60.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        UserAvatar(
          displayName: displayName,
          avatarUrl: avatarUrl,
          size: size,
          onTap: onTap,
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: size * 0.25,
            height: size * 0.25,
            decoration: BoxDecoration(
              color: isOnline ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.scaffoldBackgroundColor,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
