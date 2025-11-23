import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Widget pour noter la difficulté d'un exercice SRS
/// Affiche les boutons AGAIN, HARD, GOOD, EASY
class SRSRatingWidget extends StatelessWidget {
  final Function(int quality) onRatingSelected;
  final bool showLabels;

  const SRSRatingWidget({
    super.key,
    required this.onRatingSelected,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLabels)
            Text(
              "How well did you know this?",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          if (showLabels) SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRatingButton(
                context: context,
                quality: 0,
                label: "AGAIN",
                icon: Icons.close,
                color: Colors.red,
                onTap: () => onRatingSelected(0),
              ),
              _buildRatingButton(
                context: context,
                quality: 1,
                label: "HARD",
                icon: Icons.warning,
                color: Colors.orange,
                onTap: () => onRatingSelected(1),
              ),
              _buildRatingButton(
                context: context,
                quality: 2,
                label: "GOOD",
                icon: Icons.check_circle,
                color: Colors.green,
                onTap: () => onRatingSelected(2),
              ),
              _buildRatingButton(
                context: context,
                quality: 3,
                label: "EASY",
                icon: Icons.star,
                color: Colors.blue,
                onTap: () => onRatingSelected(3),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2);
  }

  Widget _buildRatingButton({
    required BuildContext context,
    required int quality,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.8),
              color.withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate().scale(delay: (quality * 50).ms);
  }
}

