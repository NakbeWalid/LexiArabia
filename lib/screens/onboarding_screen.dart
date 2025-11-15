import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Bienvenue sur DualingOcoran',
      subtitle: 'Votre mission',
      description:
          'Apprenez l\'arabe en maîtrisant les mots les plus fréquents du Coran. Notre objectif : vous permettre de comprendre 80% du texte sacré.',
      icon: Icons.auto_stories,
      features: [
        'Maîtrisez les mots essentiels du Coran',
        'Apprenez à votre rythme avec des leçons progressives',
        'Suivez votre progression en temps réel',
        'Gagnez des récompenses en complétant les défis',
      ],
      color: Color(0xFF4CAF50),
    ),
    OnboardingPage(
      title: 'Comment ça marche ?',
      subtitle: 'Apprendre 80% des mots du Coran',
      description:
          'En apprenant seulement les 200 mots les plus fréquents du Coran, vous pourrez comprendre environ 80% du texte. C\'est notre méthode éprouvée.',
      icon: Icons.school,
      features: [
        '200 mots = 80% de compréhension',
        'Leçons structurées par thème',
        'Exercices interactifs variés',
        'Répétition espacée pour une mémorisation durable',
      ],
      color: Color(0xFF2196F3),
    ),
    OnboardingPage(
      title: 'Progression et Récompenses',
      subtitle: 'Restez motivé',
      description:
          'Suivez votre avancement, débloquez des badges et célébrez chaque étape de votre apprentissage. Chaque leçon complétée vous rapproche de votre objectif.',
      icon: Icons.emoji_events,
      features: [
        'Suivi détaillé de votre progression',
        'Badges et récompenses à débloquer',
        'Statistiques de vos performances',
        'Défis quotidiens pour maintenir votre rythme',
      ],
      color: Color(0xFFD4AF37),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            children: [
              // Header avec bouton Skip
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo ou espace vide
                    SizedBox(width: 60),
                    // Indicateurs de page
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        _pages.length,
                        (index) => Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? Color(0xFFD4AF37)
                                : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    // Bouton Skip
                    TextButton(
                      onPressed: _skipOnboarding,
                      child: Text(
                        'Passer',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // PageView avec les pages d'onboarding
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildOnboardingPage(_pages[index], index);
                  },
                ),
              ),

              // Bouton de navigation
              Padding(
                padding: EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Bouton Précédent
                    if (_currentPage > 0)
                      TextButton.icon(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        icon: Icon(Icons.arrow_back, color: Colors.white70),
                        label: Text(
                          'Précédent',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      )
                    else
                      SizedBox(width: 100),

                    // Bouton Suivant / Commencer
                    ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                        shadowColor: Color(0xFFD4AF37).withOpacity(0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentPage == _pages.length - 1
                                ? 'Commencer'
                                : 'Suivant',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            _currentPage == _pages.length - 1
                                ? Icons.check
                                : Icons.arrow_forward,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPage page, int index) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icône animée
          Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      page.color.withOpacity(0.3),
                      page.color.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(page.icon, size: 60, color: page.color),
              )
              .animate()
              .scale(delay: 200.ms, duration: 600.ms, curve: Curves.elasticOut)
              .fadeIn(delay: 100.ms),

          SizedBox(height: 40),

          // Titre
          Text(
            page.title,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),

          SizedBox(height: 12),

          // Sous-titre
          Text(
            page.subtitle,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: page.color,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),

          SizedBox(height: 24),

          // Description
          Text(
            page.description,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),

          SizedBox(height: 40),

          // Liste des fonctionnalités
          ...page.features.asMap().entries.map((entry) {
            final featureIndex = entry.key;
            final feature = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: 16),
              child:
                  Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 4, right: 16),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: page.color.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: page.color, width: 2),
                            ),
                            child: Icon(
                              Icons.check,
                              size: 14,
                              color: page.color,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              feature,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.85),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      )
                      .animate()
                      .fadeIn(delay: (600 + featureIndex * 100).ms)
                      .slideX(
                        begin: -0.2,
                        end: 0,
                        delay: (600 + featureIndex * 100).ms,
                      ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final List<String> features;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.features,
    required this.color,
  });
}
