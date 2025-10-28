import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dualingocoran/l10n/app_localizations.dart';

class ProgressionScreen extends StatefulWidget {
  const ProgressionScreen({super.key});

  @override
  _ProgressionScreenState createState() => _ProgressionScreenState();
}

class _ProgressionScreenState extends State<ProgressionScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  final int _totalXP = 1250;
  final int _currentStreak = 7;
  final int _bestStreak = 12;
  final int _lessonsCompleted = 8;
  final int _totalLessons = 15;
  final int _accuracy = 87;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header avec XP et Streak
                _buildHeader(),
                SizedBox(height: 20),

                // Statistiques principales
                _buildMainStats(),
                SizedBox(height: 20),

                // Progression des leçons
                _buildLessonProgress(),
                SizedBox(height: 20),

                // Badges et accomplissements
                _buildBadges(),
                SizedBox(height: 20),

                // Statistiques détaillées
                _buildDetailedStats(),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
                          '$_currentStreak ${localizations.days}',
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
                      '$_totalXP',
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

  Widget _buildMainStats() {
    return Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  AppLocalizations.of(context)!.accuracy,
                  '$_accuracy${AppLocalizations.of(context)!.percent}',
                  Icons.track_changes,
                  Colors.green,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  AppLocalizations.of(context)!.bestStreak,
                  '$_bestStreak ${AppLocalizations.of(context)!.days}',
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

  Widget _buildLessonProgress() {
    final progress = _lessonsCompleted / _totalLessons;

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
                    '$_lessonsCompleted/$_totalLessons',
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

  Widget _buildDetailedStats() {
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
              Text(
                AppLocalizations.of(context)!.detailedStats,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16),

              _buildStatRow(
                AppLocalizations.of(context)!.totalStudyTime,
                '2h 45m',
              ),
              _buildStatRow(
                AppLocalizations.of(context)!.exercisesCompleted,
                '156',
              ),
              _buildStatRow(AppLocalizations.of(context)!.wordsLearned, '89'),
              _buildStatRow(AppLocalizations.of(context)!.studySessions, '23'),
              _buildStatRow(AppLocalizations.of(context)!.activeDays, '18'),
            ],
          ),
        )
        .animate(controller: _animationController)
        .slideY(begin: 0.3, end: 0.0, delay: Duration(milliseconds: 1000));
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
