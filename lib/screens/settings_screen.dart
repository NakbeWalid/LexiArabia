import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:dualingocoran/services/language_provider.dart';
import 'package:dualingocoran/utils/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final localizations = AppLocalizations(languageProvider.currentLocale);
        
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
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
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        SizedBox(width: 16),
                        Text(
                          localizations.get('settings'),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    
                    // Section Langue
                    _buildSectionHeader(localizations.get('language')),
                    SizedBox(height: 20),
                    
                    // Sélecteur de langue
                    _buildLanguageSelector(languageProvider, localizations),
                    
                    SizedBox(height: 40),
                    
                    // Autres paramètres peuvent être ajoutés ici
                    _buildSectionHeader('Notifications'),
                    SizedBox(height: 20),
                    _buildSwitchTile('Activer les notifications', true),
                    
                    SizedBox(height: 20),
                    _buildSectionHeader('Son'),
                    SizedBox(height: 20),
                    _buildSwitchTile('Activer le son', true),
                    
                    Spacer(),
                    
                    // Bouton de sauvegarde
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Paramètres sauvegardés'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFD4AF37),
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
  
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );
  }
  
  Widget _buildLanguageSelector(LanguageProvider languageProvider, AppLocalizations localizations) {
    final languages = [
      {'code': 'en', 'name': localizations.get('english'), 'flag': '🇺🇸'},
      {'code': 'fr', 'name': localizations.get('french'), 'flag': '🇫🇷'},
      {'code': 'ar', 'name': localizations.get('arabic'), 'flag': '🇸🇦'},
    ];
    
    return Column(
      children: languages.map((language) {
        final isSelected = languageProvider.getCurrentLanguageCode() == language['code'];
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
                  color: isSelected 
                      ? Color(0xFFD4AF37).withOpacity(0.2)
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? Color(0xFFD4AF37)
                        : Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      language['flag']!,
                      style: TextStyle(fontSize: 24),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        language['name']!,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: Color(0xFFD4AF37),
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
  
  Widget _buildSwitchTile(String title, bool value) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          Switch(
            value: value,
            onChanged: (newValue) {
              // TODO: Implémenter la logique
            },
            activeColor: Color(0xFFD4AF37),
          ),
        ],
      ),
    );
  }
}
