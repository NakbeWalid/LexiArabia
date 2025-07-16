import 'package:flutter/material.dart';

class LessonBubble extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool completed;
  final bool unlocked;
  final VoidCallback? onTap;

  const LessonBubble({
    super.key,
    required this.title,
    required this.icon,
    required this.completed,
    required this.unlocked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: unlocked ? onTap : null,
      child: Column(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: unlocked
                    ? [Color(0xFFE9F5EF), Color(0xFF2D6A4F)]
                    : [Colors.grey.shade200, Colors.grey.shade400],
                center: Alignment.topLeft,
                radius: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: Offset(5, 5),
                  blurRadius: 10,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.8),
                  offset: Offset(-3, -3),
                  blurRadius: 8,
                ),
              ],
              border: Border.all(
                color: completed ? Color(0xFFD4AF37) : Colors.grey.shade500,
                width: 3,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  icon,
                  size: 36,
                  color: completed
                      ? Colors.white
                      : (unlocked ? Colors.black : Colors.grey),
                ),
                if (!unlocked)
                  Icon(
                    Icons.lock,
                    size: 32,
                    color: Colors.white.withOpacity(0.7),
                  ),
                if (completed)
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.amberAccent,
                      size: 24,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: unlocked ? Colors.black : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
