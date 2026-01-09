import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/user_provider.dart';
import '../services/learning_progress_service.dart';
import 'dart:math' as math;

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _sparkleController;
  int _totalLessons = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _sparkleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _controller.forward();
    _sparkleController.repeat();
    _loadUserData();
    _loadTotalLessons();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recharger les données utilisateur quand on revient sur la page
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);

      // Recharger les données utilisateur depuis Firestore
      if (authService.currentUser != null) {
        await userProvider.loadUser(authService.currentUser!.uid);
      }
    } catch (e) {
      print('❌ Erreur lors du rechargement des données utilisateur: $e');
    }
  }

  Future<void> _loadTotalLessons() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);

      // Charger l'utilisateur si nécessaire
      if (userProvider.currentUser == null && authService.currentUser != null) {
        await userProvider.loadUser(authService.currentUser!.uid);
      }

      final progressDetails =
          await LearningProgressService.getLearningProgressDetails();
      if (mounted) {
        setState(() {
          _totalLessons = progressDetails['totalLessons'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Erreur lors du chargement du nombre total de leçons: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final authService = Provider.of<AuthService>(context);
    final currentUser = userProvider.currentUser;
    final firebaseUser = authService.currentUser;

    // Récupérer les données réelles de l'utilisateur
    final String avatarUrl = currentUser?.profile.avatarUrl ?? '';
    final String username =
        currentUser?.profile.displayName ??
        currentUser?.profile.username ??
        firebaseUser?.displayName ??
        'User';
    final String email =
        currentUser?.profile.email ?? firebaseUser?.email ?? 'user@email.com';

    // Statistiques réelles
    final int xp = currentUser?.stats.totalXP ?? 0;
    final int level = currentUser?.stats.currentLevel ?? 1;
    final int streak = currentUser?.stats.currentStreak ?? 0;
    final int completedLessons = currentUser?.stats.lessonsCompleted ?? 0;
    final int totalLessons = _totalLessons > 0
        ? _totalLessons
        : (currentUser?.stats.totalLessons ?? 0);

    // Récupérer les achievements réels
    final List<Map<String, dynamic>> achievements = _getRealAchievements(
      currentUser,
    );

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
              // Header
              Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      'Profile',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Spacer(),
                    Consumer<AuthService>(
                      builder: (context, authService, child) {
                        return PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, color: Colors.white),
                          onSelected: (value) async {
                            if (value == 'logout') {
                              final shouldLogout = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Se déconnecter'),
                                  content: Text(
                                    'Êtes-vous sûr de vouloir vous déconnecter ?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: Text('Annuler'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: Text(
                                        'Se déconnecter',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (shouldLogout == true) {
                                await authService.signOut();
                              }
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'logout',
                              child: Row(
                                children: [
                                  Icon(Icons.logout, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Se déconnecter'),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Profile Content
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      SizedBox(height: 20),

                      // Avatar Section
                      _buildAvatarSection(avatarUrl, username, email),
                      SizedBox(height: 30),

                      // Stats Cards Row
                      _buildStatsRow(level, xp, streak),
                      SizedBox(height: 30),

                      // Progress Card
                      _isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : _buildProgressCard(
                              totalLessons > 0
                                  ? (completedLessons / totalLessons)
                                  : 0.0,
                              completedLessons,
                              totalLessons,
                            ),
                      SizedBox(height: 30),

                      // Achievements Section
                      _buildAchievementsSection(achievements),
                      SizedBox(height: 40),

                      // Action Buttons
                      _buildActionButtons(),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(String avatarUrl, String username, String email) {
    return Column(
      children: [
        // Avatar with glow effect
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Animated border
              AnimatedBuilder(
                animation: _sparkleController,
                builder: (context, child) {
                  return Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          Colors.purple.shade400,
                          Colors.blue.shade400,
                          Colors.teal.shade400,
                          Colors.purple.shade400,
                        ],
                        transform: GradientRotation(
                          _sparkleController.value * 2 * math.pi,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(4),
                      child: CircleAvatar(
                        radius: 56,
                        backgroundImage: avatarUrl.isNotEmpty
                            ? NetworkImage(avatarUrl)
                            : null,
                        backgroundColor: Colors.grey.shade800,
                        child: avatarUrl.isEmpty
                            ? Icon(Icons.person, size: 60, color: Colors.white)
                            : null,
                      ),
                    ),
                  );
                },
              ),

              // Camera button
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade400, Colors.blue.shade400],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      // TODO: Implement avatar change
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 20),

        // Username
        Text(
          username,
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.purple.withOpacity(0.5),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),

        SizedBox(height: 8),

        // Email
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Text(
            email,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(int level, int xp, int streak) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            "Level",
            level.toString(),
            Icons.emoji_events,
            Colors.amber,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildStatCard("XP", xp.toString(), Icons.star, Colors.purple),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            "Streak",
            "$streak days",
            Icons.local_fire_department,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color.withOpacity(0.8), color]),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(double progress, int completed, int total) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Learning Progress",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                "$completed/$total",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade300,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Progress bar with animation
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: total > 0
                    ? (completed / total).clamp(0.0, 1.0)
                    : 0.0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade400,
                        Colors.purple.shade400,
                        Colors.pink.shade400,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 12),

          Text(
            total > 0
                ? "${((completed / total) * 100).round()}% completed"
                : "No lessons available",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(List<Map<String, dynamic>> achievements) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Achievements",
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 16),

        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            itemCount: achievements.length,
            separatorBuilder: (_, __) => SizedBox(width: 16),
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return Container(
                width: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      achievement['color'].withOpacity(0.2),
                      achievement['color'].withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: achievement['color'].withOpacity(0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: achievement['color'].withOpacity(0.2),
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            achievement['color'].withOpacity(0.8),
                            achievement['color'],
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        achievement['icon'],
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        achievement['label'],
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Settings button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.selectionClick();
              // TODO: Implement settings
            },
            icon: Icon(Icons.settings, color: Colors.white),
            label: Text(
              'Settings',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              elevation: 0,
            ),
          ),
        ),

        SizedBox(height: 16),

        // Logout button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.mediumImpact();
              _showLogoutDialog();
            },
            icon: Icon(Icons.logout, color: Colors.white),
            label: Text(
              'Logout',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 8,
              shadowColor: Colors.red.withOpacity(0.3),
            ),
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getRealAchievements(userModel) {
    if (userModel == null) return [];

    final List<Map<String, dynamic>> realAchievements = [];
    final userAchievements = userModel.achievements;

    // Définir les achievements disponibles avec leurs critères
    final achievementDefinitions = [
      {
        'id': 'first_lesson',
        'icon': Icons.star,
        'label': 'First Lesson',
        'color': Colors.amber,
        'check': () => userModel.stats.lessonsCompleted >= 1,
      },
      {
        'id': 'hundred_xp',
        'icon': Icons.emoji_events,
        'label': '100 XP',
        'color': Colors.purple,
        'check': () => userModel.stats.totalXP >= 100,
      },
      {
        'id': 'seven_day_streak',
        'icon': Icons.local_fire_department,
        'label': '7 Day Streak',
        'color': Colors.orange,
        'check': () => userModel.stats.currentStreak >= 7,
      },
      {
        'id': 'quick_learner',
        'icon': Icons.psychology,
        'label': 'Quick Learner',
        'color': Colors.blue,
        'check': () => userModel.stats.accuracy >= 80,
      },
      {
        'id': 'expert',
        'icon': Icons.military_tech,
        'label': 'Expert',
        'color': Colors.green,
        'check': () => userModel.stats.lessonsCompleted >= 10,
      },
    ];

    for (final achievement in achievementDefinitions) {
      // Vérifier d'abord si l'achievement est débloqué dans Firestore
      final achievementId = achievement['id'] as String;
      final unlockedInFirestore = userAchievements[achievementId]?.unlocked;

      // Si pas dans Firestore, vérifier les critères
      bool isUnlocked = false;
      if (unlockedInFirestore != null) {
        isUnlocked = unlockedInFirestore;
      } else {
        // Appeler la fonction check de manière sûre
        final checkFunction = achievement['check'];
        if (checkFunction is bool Function()) {
          isUnlocked = checkFunction();
        } else if (checkFunction is Function) {
          try {
            final result = checkFunction();
            isUnlocked = result == true;
          } catch (e) {
            print(
              '❌ Erreur lors de la vérification de l\'achievement $achievementId: $e',
            );
            isUnlocked = false;
          }
        }
      }

      if (isUnlocked) {
        realAchievements.add({
          'icon': achievement['icon'],
          'label': achievement['label'],
          'color': achievement['color'],
        });
      }
    }

    return realAchievements;
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout, size: 60, color: Colors.white),
              SizedBox(height: 16),
              Text(
                "Logout",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Are you sure you want to logout?",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Implement actual logout
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color(0xFF667eea),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Logout",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
