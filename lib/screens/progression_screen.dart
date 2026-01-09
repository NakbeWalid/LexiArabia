import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dualingocoran/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:dualingocoran/services/srs_service.dart';
import 'package:dualingocoran/services/user_provider.dart';
import 'package:dualingocoran/services/srs_database_init.dart';
import 'package:dualingocoran/services/learning_progress_service.dart';
import 'package:dualingocoran/screens/srs_review_screen.dart';

class ProgressionScreen extends StatefulWidget {
  const ProgressionScreen({super.key});

  @override
  _ProgressionScreenState createState() => _ProgressionScreenState();
}

class _ProgressionScreenState extends State<ProgressionScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  int _pendingReviews = 0;
  bool _isLoadingReviews = true;
  int _totalLessons = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animationController.forward();
    _loadPendingReviews();
    _loadTotalLessons();
  }

  Future<void> _loadTotalLessons() async {
    try {
      final progressDetails =
          await LearningProgressService.getLearningProgressDetails();
      if (mounted) {
        setState(() {
          _totalLessons = progressDetails['totalLessons'] ?? 0;
        });
      }
    } catch (e) {
      print('❌ Erreur lors du chargement du nombre total de leçons: $e');
    }
  }

  Future<void> _loadPendingReviews() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.currentUser?.userId;

      if (userId == null) {
        setState(() {
          _isLoadingReviews = false;
        });
        return;
      }

      // S'assurer que SRS est initialisé
      if (!await SRSDatabaseInit.isSRSInitialized(userId)) {
        await SRSDatabaseInit.initializeSRSCollections(userId);
      }

      // Charger les exercices à réviser
      final dueExercises = await SRSService.getDueExercises(userId);
      final newExercises = await SRSService.getNewExercises(userId);

      setState(() {
        _pendingReviews = dueExercises.length + newExercises.length;
        _isLoadingReviews = false;
      });
    } catch (e) {
      print('❌ Erreur lors du chargement des révisions: $e');
      setState(() {
        _isLoadingReviews = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;

    // Récupérer les données réelles de l'utilisateur
    final int totalXP = currentUser?.stats.totalXP ?? 0;
    final int currentStreak = currentUser?.stats.currentStreak ?? 0;
    final int bestStreak = currentUser?.stats.bestStreak ?? 0;
    final int lessonsCompleted = currentUser?.stats.lessonsCompleted ?? 0;
    final double accuracy = currentUser?.stats.accuracy ?? 0.0;
    final int totalLessons = _totalLessons > 0
        ? _totalLessons
        : (currentUser?.stats.totalLessons ?? 0);

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
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header avec XP et Streak
                _buildHeader(totalXP, currentStreak),
                SizedBox(height: 20),

                // Bouton SRS Review
                _buildSRSReviewButton(),
                SizedBox(height: 20),

                // Statistiques principales
                _buildMainStats(accuracy, bestStreak),
                SizedBox(height: 20),

                // Progression des leçons
                _buildLessonProgress(lessonsCompleted, totalLessons),
                SizedBox(height: 20),

                // Badges et accomplissements
                _buildBadges(),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int totalXP, int currentStreak) {
    final localizations = AppLocalizations.of(context)!;
    return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    localizations.progression,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: Colors.orange,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '$currentStreak ${localizations.days}',
                          style: GoogleFonts.poppins(
                            color: Colors.orange,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // XP Total
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.withOpacity(0.3),
                      Colors.blue.withOpacity(0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '$totalXP',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      localizations.totalXP,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate(controller: _animationController)
        .fadeIn(delay: Duration(milliseconds: 200));
  }

  Widget _buildSRSReviewButton() {
    return Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: GestureDetector(
            onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SRSReviewScreen()),
              ).then((_) {
                // Recharger les révisions après retour
                _loadPendingReviews();
              });
            },
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF667eea).withOpacity(0.4),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.repeat, color: Colors.white, size: 28),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SRS Review',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _isLoadingReviews
                              ? 'Loading...'
                              : _pendingReviews > 0
                              ? '$_pendingReviews exercises to review'
                              : 'No reviews for today',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        )
        .animate(controller: _animationController)
        .fadeIn(delay: Duration(milliseconds: 300))
        .slideX(begin: -0.2, end: 0.0);
  }

  Widget _buildMainStats(double accuracy, int bestStreak) {
    return Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  AppLocalizations.of(context)!.accuracy,
                  '${accuracy.round()}${AppLocalizations.of(context)!.percent}',
                  Icons.track_changes,
                  Colors.green,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  AppLocalizations.of(context)!.bestStreak,
                  '$bestStreak ${AppLocalizations.of(context)!.days}',
                  Icons.emoji_events,
                  Colors.amber,
                ),
              ),
            ],
          ),
        )
        .animate(controller: _animationController)
        .slideX(begin: -0.3, end: 0.0, delay: Duration(milliseconds: 400));
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLessonProgress(int lessonsCompleted, int totalLessons) {
    final progress = totalLessons > 0 ? (lessonsCompleted / totalLessons) : 0.0;

    return Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.lessonProgress,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$lessonsCompleted/$totalLessons',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Barre de progression
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green, Colors.blue],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 12),

              // Pourcentage
              Text(
                '${(progress * 100).round()}% ${AppLocalizations.of(context)!.completedLabel}',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        )
        .animate(controller: _animationController)
        .slideX(begin: 0.3, end: 0.0, delay: Duration(milliseconds: 600));
  }

  Widget _buildBadges() {
    final localizations = AppLocalizations.of(context)!;
    final badges = [
      {
        'name': localizations.firstStep,
        'icon': Icons.directions_walk,
        'color': Colors.blue,
        'unlocked': true,
      },
      {
        'name': localizations.streak7Days,
        'icon': Icons.local_fire_department,
        'color': Colors.orange,
        'unlocked': true,
      },
      {
        'name': localizations.accuracy80Plus,
        'icon': Icons.track_changes,
        'color': Colors.green,
        'unlocked': true,
      },
      {
        'name': localizations.fiveLessons,
        'icon': Icons.school,
        'color': Colors.purple,
        'unlocked': true,
      },
      {
        'name': localizations.streak30Days,
        'icon': Icons.emoji_events,
        'color': Colors.amber,
        'unlocked': false,
      },
      {
        'name': localizations.hundredPercentAccuracy,
        'icon': Icons.star,
        'color': Colors.yellow,
        'unlocked': false,
      },
    ];

    return Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.badgesAndAchievements,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16),

              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: badges.length,
                itemBuilder: (context, index) {
                  final badge = badges[index];
                  return _buildBadgeCard(badge);
                },
              ),
            ],
          ),
        )
        .animate(controller: _animationController)
        .fadeIn(delay: Duration(milliseconds: 800));
  }

  Widget _buildBadgeCard(Map<String, dynamic> badge) {
    return Container(
      decoration: BoxDecoration(
        color: badge['unlocked']
            ? badge['color'].withOpacity(0.2)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: badge['unlocked']
              ? badge['color'].withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            badge['icon'],
            color: badge['unlocked']
                ? badge['color']
                : Colors.white.withOpacity(0.3),
            size: 32,
          ),
          SizedBox(height: 8),
          Text(
            badge['name'],
            style: GoogleFonts.poppins(
              color: badge['unlocked']
                  ? Colors.white
                  : Colors.white.withOpacity(0.5),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
