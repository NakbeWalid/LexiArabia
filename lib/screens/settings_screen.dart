import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dualingocoran/services/language_provider.dart';
import 'package:dualingocoran/services/theme_provider.dart';
import 'package:dualingocoran/l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final localizations = AppLocalizations.of(context)!;
        final themeProvider = context.watch<ThemeProvider>();
        final colorScheme = Theme.of(context).colorScheme;
        final isDarkMode = themeProvider.isDarkMode;

        final gradientColors = isDarkMode
            ? const [
                Color(0xFF0F0C29),
                Color(0xFF24243e),
                Color(0xFF302B63),
                Color(0xFF0F0C29),
              ]
            : const [
                Color(0xFFfef9f3),
                Color(0xFFeef3ff),
                Color(0xFFe4ebff),
                Color(0xFFf3f6ff),
              ];

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                stops: [0.0, 0.3, 0.7, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: colorScheme.onBackground,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        SizedBox(width: 16),
                        Text(
                          localizations.settings,
                          style: GoogleFonts.poppins(
                            color: colorScheme.onBackground,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),

                    // Section Langue
                    _buildSectionHeader(context, localizations.language),
                    SizedBox(height: 20),

                    // Sélecteur de langue
                    _buildLanguageSelector(
                      context,
                      languageProvider,
                      localizations,
                    ),

                    SizedBox(height: 40),

                    _buildSectionHeader(context, localizations.appearance),
                    SizedBox(height: 20),
                    _buildSwitchTile(
                      context,
                      icon: Icons.dark_mode_rounded,
                      title: localizations.enableDarkMode,
                      value: themeProvider.isDarkMode,
                      onChanged: (value) => themeProvider.toggleDarkMode(value),
                    ),

                    SizedBox(height: 40),

                    _buildSectionHeader(context, localizations.notifications),
                    SizedBox(height: 20),
                    _buildSwitchTile(
                      context,
                      icon: Icons.notifications_active_outlined,
                      title: localizations.enableNotifications,
                      value: _notificationsEnabled,
                      onChanged: (newValue) {
                        setState(() => _notificationsEnabled = newValue);
                      },
                    ),

                    SizedBox(height: 20),
                    _buildSectionHeader(context, localizations.sound),
                    SizedBox(height: 20),
                    _buildSwitchTile(
                      context,
                      icon: Icons.graphic_eq,
                      title: localizations.enableSound,
                      value: _soundEnabled,
                      onChanged: (newValue) {
                        setState(() => _soundEnabled = newValue);
                      },
                    ),

                    Spacer(),

                    // Bouton de sauvegarde
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            SnackBar(
                              content: Text(
                                'Paramètres sauvegardés',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Sauvegarder',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      title,
      style: GoogleFonts.poppins(
        color: colorScheme.onBackground,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildLanguageSelector(
    BuildContext context,
    LanguageProvider languageProvider,
    AppLocalizations localizations,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).colorScheme.onBackground;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;
    final highlightColor = Theme.of(context).colorScheme.primary;
    final selectedBackground = highlightColor.withOpacity(isDark ? 0.18 : 0.22);
    final tileBackground = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.white.withOpacity(0.9);

    final languages = [
      {'code': 'en', 'name': localizations.english, 'flag': '🇺🇸'},
      {'code': 'fr', 'name': localizations.french, 'flag': '🇫🇷'},
      {'code': 'ar', 'name': localizations.arabic, 'flag': '🇸🇦'},
    ];

    return Column(
      children: languages.map((language) {
        final isSelected =
            languageProvider.getCurrentLanguageCode() == language['code'];
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => languageProvider.changeLanguage(language['code']!),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? selectedBackground : tileBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? highlightColor
                        : (isDark
                            ? Colors.white.withOpacity(0.15)
                            : Colors.black12),
                    width: 1,
                  ),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: Offset(0, 8),
                          ),
                        ],
                ),
                child: Row(
                  children: [
                    Text(language['flag']!, style: TextStyle(fontSize: 24)),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            language['name']!,
                            style: GoogleFonts.poppins(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            language['code']!.toUpperCase(),
                            style: GoogleFonts.poppins(
                              color: subtitleColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: highlightColor,
                        size: 24,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    IconData? icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.white.withOpacity(0.95);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.12)
        : Colors.black.withOpacity(0.05);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(isDark ? 0.15 : 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                SizedBox(width: 16),
              ],
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: colorScheme.onBackground,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
