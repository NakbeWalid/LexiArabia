import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dualingocoran/services/learning_progress_service.dart';
import 'dart:math' as math;

/// Page de célébration montrant l'ajout du pourcentage d'apprentissage
class LearningProgressCelebrationScreen extends StatefulWidget {
  final String lessonId;
  final double percentageGained;

  const LearningProgressCelebrationScreen({
    super.key,
    required this.lessonId,
    required this.percentageGained,
  });

  @override
  State<LearningProgressCelebrationScreen> createState() =>
      _LearningProgressCelebrationScreenState();
}

class _LearningProgressCelebrationScreenState
    extends State<LearningProgressCelebrationScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _celebrationController;
  late AnimationController _sparkleController;
  double _previousPercentage = 0.0;
  double _newPercentage = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat();

    _loadPercentages();
  }

  Future<void> _loadPercentages() async {
    // Récupérer le pourcentage actuel (après complétion)
    final currentPercentage =
        await LearningProgressService.getLearningPercentage();

    // Calculer le pourcentage précédent
    final previousPercentage = currentPercentage - widget.percentageGained;

    setState(() {
      _previousPercentage = previousPercentage.clamp(0.0, 100.0);
      _newPercentage = currentPercentage.clamp(0.0, 100.0);
      _isLoading = false;
    });

    // Démarrer les animations
    Future.delayed(const Duration(milliseconds: 500), () {
      _celebrationController.forward();
      _progressController.forward();
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _celebrationController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFF1a1a2e)],
            ),
          ),
          child: Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFF1a1a2e)],
          ),
        ),
        child: Stack(
          children: [
            // Confettis animés
            ...List.generate(30, (index) => _buildConfetti(index)),

            // Contenu principal
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Espace en haut
                    const SizedBox(height: 40),

                    // Icône de célébration
                    AnimatedBuilder(
                      animation: _celebrationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 0.5 + (_celebrationController.value * 0.5),
                          child: Transform.rotate(
                            angle: _celebrationController.value * 2 * math.pi,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.amber.shade300,
                                    Colors.orange.shade400,
                                    Colors.pink.shade400,
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.amber.withOpacity(0.6),
                                    blurRadius: 30,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.emoji_events,
                                size: 70,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ).animate().fadeIn(duration: 500.ms).scale(),

                    const SizedBox(height: 40),

                    // Titre
                    Text(
                      'Félicitations !',
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: -0.3),

                    const SizedBox(height: 12),

                    // Sous-titre
                    Text(
                      'Vous avez progressé !',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: -0.2),

                    const SizedBox(height: 60),

                    // Carte de progression
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Label
                          Text(
                            'Progression d\'apprentissage',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Barre de progression
                          Stack(
                            children: [
                              // Barre de fond
                              Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),

                              // Barre de progression animée
                              AnimatedBuilder(
                                animation: _progressController,
                                builder: (context, child) {
                                  final animatedPercentage =
                                      _previousPercentage +
                                      ((_newPercentage - _previousPercentage) *
                                          _progressController.value);

                                  return Container(
                                    height: 50,
                                    width:
                                        MediaQuery.of(context).size.width *
                                        (animatedPercentage / 100) *
                                        0.75, // 75% de la largeur de l'écran moins les marges
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.green.shade400,
                                          Colors.green.shade600,
                                          Colors.teal.shade400,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(25),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green.withOpacity(0.5),
                                          blurRadius: 15,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        // Effet de brillance
                                        Positioned.fill(
                                          child: AnimatedBuilder(
                                            animation: _sparkleController,
                                            builder: (context, child) {
                                              return Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment(
                                                      -1.0 +
                                                          (_sparkleController
                                                                  .value *
                                                              2),
                                                      0,
                                                    ),
                                                    end: Alignment(
                                                      1.0 +
                                                          (_sparkleController
                                                                  .value *
                                                              2),
                                                      0,
                                                    ),
                                                    colors: [
                                                      Colors.transparent,
                                                      Colors.white.withOpacity(
                                                        0.3,
                                                      ),
                                                      Colors.transparent,
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),

                              // Pourcentage affiché
                              Positioned.fill(
                                child: Center(
                                  child: AnimatedBuilder(
                                    animation: _progressController,
                                    builder: (context, child) {
                                      final animatedPercentage =
                                          _previousPercentage +
                                          ((_newPercentage -
                                                  _previousPercentage) *
                                              _progressController.value);

                                      return Text(
                                        '${animatedPercentage.toStringAsFixed(1)}%',
                                        style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withOpacity(
                                                0.5,
                                              ),
                                              offset: Offset(0, 2),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // Détails de progression
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildProgressDetail(
                                'Avant',
                                '${_previousPercentage.toStringAsFixed(1)}%',
                                Colors.blue.shade300,
                              ),
                              Container(
                                width: 2,
                                height: 40,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              _buildProgressDetail(
                                'Ajouté',
                                '+${widget.percentageGained.toStringAsFixed(1)}%',
                                Colors.green.shade300,
                              ),
                              Container(
                                width: 2,
                                height: 40,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              _buildProgressDetail(
                                'Maintenant',
                                '${_newPercentage.toStringAsFixed(1)}%',
                                Colors.amber.shade300,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.3),

                    const SizedBox(height: 40),

                    // Bouton continuer
                    Container(
                      margin: const EdgeInsets.only(
                        left: 30,
                        right: 30,
                        bottom: 40,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop(); // Fermer cette page
                          Navigator.of(
                            context,
                          ).pop(true); // Retourner à la roadmap
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade400,
                                Colors.green.shade600,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.shade400.withOpacity(0.4),
                                blurRadius: 20,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Continuer',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.3),
                    const SizedBox(height: 20), // Espace supplémentaire en bas
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressDetail(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.5), width: 1.5),
          ),
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfetti(int index) {
    final random = math.Random(index);
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.pink,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    return Positioned(
      left: random.nextDouble() * MediaQuery.of(context).size.width,
      top: -50,
      child: AnimatedBuilder(
        animation: _celebrationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              (random.nextDouble() - 0.5) * 100 * _celebrationController.value,
              MediaQuery.of(context).size.height * _celebrationController.value,
            ),
            child: Transform.rotate(
              angle: _celebrationController.value * 4 * math.pi,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colors[random.nextInt(colors.length)],
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
