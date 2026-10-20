import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dualingocoran/l10n/app_localizations.dart';
import 'package:dualingocoran/services/auth_service.dart';
import 'package:dualingocoran/services/language_provider.dart';
import 'package:dualingocoran/services/notification_service.dart';
import 'package:dualingocoran/services/sound_service.dart';
import 'package:dualingocoran/services/user_provider.dart';

const _gold = Color(0xFFD4AF37);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = NotificationService.defaultTime;
  bool _soundEnabled = true;
  String? _lastLocale;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Après un changement de langue, reprogrammer le rappel avec les
    // textes traduits dans la nouvelle langue
    final l10n = AppLocalizations.of(context)!;
    if (_lastLocale != null && _lastLocale != l10n.localeName) {
      NotificationService.refresh(
        title: l10n.reminderNotificationTitle,
        body: l10n.reminderNotificationBody,
        channelName: l10n.reminderChannelName,
      );
    }
    _lastLocale = l10n.localeName;
  }

  Future<void> _loadPreferences() async {
    final enabled = await NotificationService.isEnabled();
    final time = await NotificationService.getReminderTime();
    final sound = await SoundService.isSoundEnabled();
    if (!mounted) return;
    setState(() {
      _reminderEnabled = enabled;
      _reminderTime = time;
      _soundEnabled = sound;
    });
  }

  Future<void> _setReminder(bool enabled, {TimeOfDay? time}) async {
    final l10n = AppLocalizations.of(context)!;
    final reminderTime = time ?? _reminderTime;

    if (!enabled) {
      await NotificationService.disable();
      if (mounted) setState(() => _reminderEnabled = false);
      return;
    }

    final granted = await NotificationService.enable(
      time: reminderTime,
      title: l10n.reminderNotificationTitle,
      body: l10n.reminderNotificationBody,
      channelName: l10n.reminderChannelName,
    );
    if (!mounted) return;

    setState(() {
      _reminderEnabled = granted;
      if (granted) _reminderTime = reminderTime;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            granted
                ? l10n.reminderScheduled(reminderTime.format(context))
                : l10n.notificationPermissionDenied,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null) await _setReminder(true, time: picked);
  }

  Future<void> _setSound(bool enabled) async {
    await SoundService.setSoundEnabled(enabled);
    if (mounted) setState(() => _soundEnabled = enabled);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageProvider = context.watch<LanguageProvider>();
    final notificationsSupported = NotificationService.isSupported;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F0C29),
              Color(0xFF24243e),
              Color(0xFF302B63),
              Color(0xFF0F0C29),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                l10n.settings,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              _buildSectionHeader(l10n.language),
              _buildLanguageSelector(languageProvider, l10n),
              const SizedBox(height: 32),

              _buildSectionHeader(l10n.notifications),
              _buildSwitchTile(
                icon: Icons.notifications_active_outlined,
                title: l10n.dailyReminder,
                subtitle: notificationsSupported
                    ? l10n.dailyReminderSubtitle
                    : l10n.notificationsUnsupported,
                value: _reminderEnabled,
                onChanged: notificationsSupported ? _setReminder : null,
              ),
              if (_reminderEnabled) ...[
                const SizedBox(height: 12),
                _buildActionTile(
                  icon: Icons.schedule_rounded,
                  title: l10n.reminderTime,
                  trailing: Text(
                    _reminderTime.format(context),
                    style: GoogleFonts.poppins(
                      color: _gold,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: _pickReminderTime,
                ),
              ],
              const SizedBox(height: 32),

              _buildSectionHeader(l10n.sound),
              _buildSwitchTile(
                icon: Icons.volume_up_outlined,
                title: l10n.enableSound,
                value: _soundEnabled,
                onChanged: _setSound,
              ),
              const SizedBox(height: 32),

              _buildSectionHeader(l10n.account),
              _buildActionTile(
                icon: Icons.logout_rounded,
                title: l10n.signOut,
                subtitle: l10n.signOutSubtitle,
                isDanger: true,
                onTap: _showSignOutDialog,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  BoxDecoration _tileDecoration({bool selected = false}) => BoxDecoration(
    color: selected
        ? _gold.withValues(alpha: 0.18)
        : Colors.white.withValues(alpha: 0.08),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: selected ? _gold : Colors.white.withValues(alpha: 0.12),
    ),
  );

  Widget _buildLanguageSelector(
    LanguageProvider languageProvider,
    AppLocalizations l10n,
  ) {
    final languages = [
      ('fr', l10n.french, '🇫🇷'),
      ('en', l10n.english, '🇬🇧'),
      ('ar', l10n.arabic, '🇸🇦'),
    ];

    return Column(
      children: [
        for (final (code, name, flag) in languages)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => languageProvider.changeLanguage(code),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _tileDecoration(
                    selected: languageProvider.getCurrentLanguageCode() == code,
                  ),
                  child: Row(
                    children: [
                      Text(flag, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          name,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (languageProvider.getCurrentLanguageCode() == code)
                        const Icon(Icons.check_circle, color: _gold),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildIcon(IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.16),
      shape: BoxShape.circle,
    ),
    child: Icon(icon, color: color, size: 20),
  );

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool>? onChanged,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: _tileDecoration(),
      child: Row(
        children: [
          _buildIcon(icon, _gold),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeThumbColor: _gold),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? subtitle,
    Widget? trailing,
    bool isDanger = false,
  }) {
    final accent = isDanger ? Colors.redAccent : _gold;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: _tileDecoration(),
          child: Row(
            children: [
              _buildIcon(icon, accent),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: isDanger ? Colors.redAccent : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              trailing ??
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white54,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSignOutDialog() async {
    final l10n = AppLocalizations.of(context)!;

    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          l10n.signOut,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        content: Text(
          l10n.signOutConfirm,
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel, style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.signOut, style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );

    if (shouldSignOut == true && mounted) {
      HapticFeedback.mediumImpact();
      await Provider.of<AuthService>(context, listen: false).signOut();
      if (!mounted) return;
      Provider.of<UserProvider>(context, listen: false).logout();
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }
}
