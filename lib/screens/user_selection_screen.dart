import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dualingocoran/services/user_provider.dart';
import 'package:dualingocoran/main.dart';
import 'package:dualingocoran/l10n/app_localizations.dart';

class UserSelectionScreen extends StatelessWidget {
  const UserSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
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
                child: Column(
                  children: [
                    Text(
                      localizations.userSelection,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      localizations.chooseDemoProfile,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),

              // Liste des utilisateurs
              Expanded(
                child: Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    final demoUserIds = userProvider.getAvailableDemoUserIds();

                    return ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      itemCount: demoUserIds.length,
                      itemBuilder: (context, index) {
                        final userId = demoUserIds[index];
                        final userInfo = _getUserInfo(userId);

                        return Container(
                          margin: EdgeInsets.only(bottom: 16),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                await userProvider.loadDemoUserById(userId);
                                if (userProvider.currentUser != null) {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => MainScreen(),
                                    ),
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
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
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 15,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // Avatar
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.purple.shade400,
                                            Colors.blue.shade400,
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          userInfo['displayName'][0],
                                          style: GoogleFonts.poppins(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(width: 16),

                                    // Informations utilisateur
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            userInfo['displayName'],
                                            style: GoogleFonts.poppins(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            userInfo['bio'],
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.white.withOpacity(
                                                0.7,
                                              ),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              _buildStatChip(
                                                'Niveau ${userInfo['level']}',
                                                Colors.amber,
                                              ),
                                              SizedBox(width: 8),
                                              _buildStatChip(
                                                '${userInfo['xp']} XP',
                                                Colors.purple,
                                              ),
                                              SizedBox(width: 8),
                                              _buildStatChip(
                                                '${userInfo['streak']} jours',
                                                Colors.orange,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Flèche
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white.withOpacity(0.6),
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Map<String, dynamic> _getUserInfo(String userId) {
    final userInfoMap = {
      'demo_user_001': {
        'displayName': 'QuranLearner',
        'bio': 'Passionné d\'apprentissage de l\'arabe',
        'level': 5,
        'xp': 1250,
        'streak': 7,
      },
      'demo_user_002': {
        'displayName': 'ArabicMaster',
        'bio': 'Expert en langue arabe',
        'level': 8,
        'xp': 3200,
        'streak': 15,
      },
      'demo_user_003': {
        'displayName': 'BeginnerStudent',
        'bio': 'Débutant enthousiaste',
        'level': 2,
        'xp': 450,
        'streak': 3,
      },
      'demo_user_004': {
        'displayName': 'IntermediateLearner',
        'bio': 'Apprenant intermédiaire',
        'level': 6,
        'xp': 1800,
        'streak': 10,
      },
      'demo_user_005': {
        'displayName': 'AdvancedStudent',
        'bio': 'Étudiant avancé en arabe',
        'level': 10,
        'xp': 4500,
        'streak': 22,
      },
      'demo_user_006': {
        'displayName': 'CasualLearner',
        'bio': 'Apprentissage occasionnel',
        'level': 3,
        'xp': 800,
        'streak': 2,
      },
      'demo_user_007': {
        'displayName': 'DedicatedStudent',
        'bio': 'Étudiant dévoué',
        'level': 7,
        'xp': 2800,
        'streak': 18,
      },
      'demo_user_008': {
        'displayName': 'WeekendWarrior',
        'bio': 'Étudie le weekend',
        'level': 3,
        'xp': 650,
        'streak': 1,
      },
      'demo_user_009': {
        'displayName': 'SpeedLearner',
        'bio': 'Apprend rapidement',
        'level': 9,
        'xp': 3800,
        'streak': 12,
      },
      'demo_user_010': {
        'displayName': 'ConsistentLearner',
        'bio': 'Apprentissage régulier',
        'level': 6,
        'xp': 2200,
        'streak': 14,
      },
    };

    return userInfoMap[userId] ??
        {
          'displayName': 'Unknown',
          'bio': 'Utilisateur inconnu',
          'level': 1,
          'xp': 0,
          'streak': 0,
        };
  }
}
