import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dualingocoran/Exercises/Exercise.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../utils/arabic_text_style.dart';

class PairsExercise extends StatefulWidget {
  final Exercise exercise;
  final Function(bool) onNext;

  const PairsExercise({
    super.key,
    required this.exercise,
    required this.onNext,
  });

  @override
  State<PairsExercise> createState() => _PairsExerciseState();
}

class _PairsExerciseState extends State<PairsExercise>
    with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _controller;
  late AnimationController _successController;

  // Variables pour pairs matching
  Map<String, String> correctPairs = {};
  Map<String, String> userPairs = {};
  List<String> leftItems = [];
  List<String> rightItems = [];
  String? selectedLeftItem;
  Set<String> connectedItems = {};

  // Keys pour obtenir les positions réelles des éléments
  Map<String, GlobalKey> leftItemKeys = {};
  Map<String, GlobalKey> rightItemKeys = {};

  // Flag pour savoir si on a déjà initialisé les traductions
  bool _translationsInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _successController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _initializeExercise();
    _controller.forward();
  }

  void _initializeExercise() {
    // Debug
    print('🔍 PairsExercise Debug:');
    print('Exercise type: ${widget.exercise.type}');
    print('Exercise dragDropPairs: ${widget.exercise.dragDropPairs}');
    print(
      'Exercise dragDropPairs length: ${widget.exercise.dragDropPairs?.length}',
    );
    print('Exercise answer: ${widget.exercise.answer}');
    print('Exercise options: ${widget.exercise.options}');

    // Pour les exercices de matching avec pairs
    if (widget.exercise.dragDropPairs != null &&
        widget.exercise.dragDropPairs!.isNotEmpty) {
      correctPairs.clear();
      userPairs.clear();
      leftItems.clear();
      rightItems.clear();
      connectedItems.clear();
      selectedLeftItem = null;
      leftItemKeys.clear();
      rightItemKeys.clear();

      // Utiliser dragDropPairs sans traduction (traduction se fera dans build)
      for (var pair in widget.exercise.dragDropPairs!) {
        final from = pair['from']?.toString() ?? '';
        final to = pair['to']?.toString() ?? '';
        if (from.isNotEmpty && to.isNotEmpty) {
          correctPairs[from] = to;
          leftItems.add(from);
          rightItems.add(to);
          // Créer les clés pour chaque élément
          leftItemKeys[from] = GlobalKey();
          rightItemKeys[to] = GlobalKey();
        }
      }
      leftItems.shuffle();
      rightItems.shuffle();
    }
  }

  // Méthode pour obtenir les pairs traduites avec context
  void _updateTranslatedPairs() {
    // Ne faire la traduction qu'une seule fois
    if (_translationsInitialized) return;

    if (widget.exercise.dragDropPairs != null &&
        widget.exercise.dragDropPairs!.isNotEmpty) {
      final translatedPairs = widget.exercise.getTranslatedPairs(context);

      if (translatedPairs != null && translatedPairs.isNotEmpty) {
        // Mettre à jour les items avec les traductions
        leftItems.clear();
        rightItems.clear();
        correctPairs.clear();
        leftItemKeys.clear();
        rightItemKeys.clear();

        for (var pair in translatedPairs) {
          final from = pair['from']?.toString() ?? '';
          final to = pair['to']?.toString() ?? '';
          if (from.isNotEmpty && to.isNotEmpty) {
            correctPairs[from] = to;
            leftItems.add(from);
            rightItems.add(to);
            leftItemKeys[from] = GlobalKey();
            rightItemKeys[to] = GlobalKey();
          }
        }

        // Mélanger après avoir ajouté tous les items
        leftItems.shuffle();
        rightItems.shuffle();

        _translationsInitialized = true;
      }
    }
  }

  @override
  void didUpdateWidget(covariant PairsExercise oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise != widget.exercise) {
      _translationsInitialized = false; // Réinitialiser pour le nouvel exercice
      _initializeExercise();
      setState(() {});
    }
  }

  void handleItemTap(String item, bool isLeft) {
    print("🎯 handleItemTap called - item: $item, isLeft: $isLeft");
    print("🎯 Current selectedLeftItem: $selectedLeftItem");
    print("🎯 Current connectedItems: $connectedItems");

    if (isLeft) {
      print("🎯 Processing LEFT item tap");
      // Logique de toggle : si c'est le même élément, on le désélectionne
      // Sinon, on sélectionne le nouvel élément
      setState(() {
        if (selectedLeftItem == item) {
          print("🎯 Deselecting item: $item");
          selectedLeftItem = null; // Désélectionner
        } else {
          print("🎯 Selecting item: $item");
          selectedLeftItem = item; // Sélectionner le nouvel élément
        }
      });
    } else {
      print("🎯 Processing RIGHT item tap");
      // Right item tapped
      if (selectedLeftItem != null) {
        print("🎯 Connecting $selectedLeftItem with $item");
        _connectItems(selectedLeftItem!, item);
      } else {
        print("🎯 No left item selected, ignoring right tap");
      }
    }
  }

  void _connectItems(String leftItem, String rightItem) async {
    setState(() {
      // Si l'élément de droite est déjà connecté à un autre élément de gauche,
      // on déconnecte d'abord cette connexion
      String? existingLeftItem;
      for (var entry in userPairs.entries) {
        if (entry.value == rightItem) {
          existingLeftItem = entry.key;
          break;
        }
      }

      if (existingLeftItem != null) {
        userPairs.remove(existingLeftItem);
        connectedItems.remove(existingLeftItem);
        connectedItems.remove(rightItem);
      }

      // Si l'élément de gauche est déjà connecté à un autre élément de droite,
      // on déconnecte d'abord cette connexion
      if (userPairs.containsKey(leftItem)) {
        String existingRightItem = userPairs[leftItem]!;
        userPairs.remove(leftItem);
        connectedItems.remove(leftItem);
        connectedItems.remove(existingRightItem);
      }

      // Créer la nouvelle connexion
      userPairs[leftItem] = rightItem;
      connectedItems.add(leftItem);
      connectedItems.add(rightItem);
      selectedLeftItem = null; // Remettre à null après connexion
    });

    // Vérifie si c'est correct
    bool isCorrectPair = correctPairs[leftItem] == rightItem;

    if (isCorrectPair) {
      HapticFeedback.lightImpact();
      try {
        //await _audioPlayer.play(AssetSource('assets/sounds/correct.mp3'));
      } catch (e) {
        print('Audio error: $e');
      }
    } else {
      HapticFeedback.mediumImpact();
      try {
        //await _audioPlayer.play(AssetSource('sounds/wrong.mp3'));
      } catch (e) {
        print('Audio error: $e');
      }
    }

    // Vérifie si tous les pairs sont complétés
    if (userPairs.length == correctPairs.length) {
      bool allCorrect = true;
      for (var entry in userPairs.entries) {
        if (correctPairs[entry.key] != entry.value) {
          allCorrect = false;
          break;
        }
      }

      if (allCorrect) {
        // ✅ TOUTES LES RÉPONSES SONT CORRECTES
        if (mounted) _successController.forward();
        try {
          await _audioPlayer.play(AssetSource('sounds/success.mp3'));
        } catch (e) {
          print('Audio error: $e');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.celebration, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  "Perfect! All pairs matched! ✨",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        // Passer à l'exercice suivant après 2 secondes
        Future.delayed(const Duration(milliseconds: 2000), () => widget.onNext(true)); // Toutes les paires sont correctes
      } else {
        // ❌ CERTAINES RÉPONSES SONT INCORRECTES MAIS ON PASSE QUAND MÊME
        if (mounted) _successController.forward();
        try {
          await _audioPlayer.play(AssetSource('sounds/success.mp3'));
        } catch (e) {
          print('Audio error: $e');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  "Exercise completed! Some pairs were incorrect, but let's continue! 📚",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: Colors.orange.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        // Passer à l'exercice suivant même avec des erreurs après 2 secondes
        Future.delayed(const Duration(milliseconds: 2000), () => widget.onNext(false)); // Certaines paires sont incorrectes
      }
    }
  }

  void reset() {
    setState(() {
      _initializeExercise();
    });
    _controller.reset();
    if (mounted) _successController.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _successController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mettre à jour les pairs traduites maintenant qu'on a accès au context
    _updateTranslatedPairs();

    // Check if we have valid exercise data
    if (widget.exercise.dragDropPairs == null ||
        widget.exercise.dragDropPairs!.isEmpty) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade900, Colors.blue.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.white70),
                SizedBox(height: 16),
                Text(
                  "No valid exercise data available",
                  style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
                ),
                SizedBox(height: 20),
                Text(
                  "Debug info:",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  "Type: ${widget.exercise.type}",
                  style: GoogleFonts.robotoMono(color: Colors.white60),
                ),
                Text(
                  "Answer: ${widget.exercise.answer}",
                  style: GoogleFonts.robotoMono(color: Colors.white60),
                ),
                Text(
                  "DragDropPairs: ${widget.exercise.dragDropPairs}",
                  style: GoogleFonts.robotoMono(color: Colors.white60),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Main content
              Column(
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "Match Pairs",
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            IconButton(
                              onPressed: reset,
                              icon: Icon(Icons.refresh, color: Colors.white),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        ArabicText(
                          widget.exercise.question.isNotEmpty
                              ? widget.exercise.question
                              : "Match the pairs correctly",
                          style: ArabicTextStyle.smartStyle(
                            widget.exercise.question.isNotEmpty
                                ? widget.exercise.question
                                : "Match the pairs correctly",
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),

                  // Progress indicator
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: LinearProgressIndicator(
                      value: userPairs.length / correctPairs.length,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.greenAccent,
                      ),
                      minHeight: 6,
                    ),
                  ).animate().fadeIn(delay: 300.ms).scaleX(),

                  SizedBox(height: 20),

                  // Main content
                  Expanded(
                    child: AnimationLimiter(
                      child: Row(
                        children: [
                          // Left column
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  "Drag from here",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.8),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: leftItems.length,
                                    itemBuilder: (context, index) {
                                      return AnimationConfiguration.staggeredList(
                                        position: index,
                                        duration: const Duration(
                                          milliseconds: 600,
                                        ),
                                        child: SlideAnimation(
                                          horizontalOffset: -50.0,
                                          child: FadeInAnimation(
                                            child: _buildLeftItem(
                                              leftItems[index],
                                              index,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Center divider
                          SizedBox(
                            width: 20,
                            child: Center(
                              child: Container(
                                width: 2,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.1),
                                      Colors.white.withOpacity(0.3),
                                      Colors.white.withOpacity(0.1),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Right column
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  "Match here",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.8),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: rightItems.length,
                                    itemBuilder: (context, index) {
                                      return AnimationConfiguration.staggeredList(
                                        position: index,
                                        duration: const Duration(
                                          milliseconds: 600,
                                        ),
                                        child: SlideAnimation(
                                          horizontalOffset: 50.0,
                                          child: FadeInAnimation(
                                            child: _buildRightItem(
                                              rightItems[index],
                                              index,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Connection lines overlay
              if (userPairs.isNotEmpty)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: ConnectionLinesPainter(
                        userPairs: userPairs,
                        correctPairs: correctPairs,
                        leftItems: leftItems,
                        rightItems: rightItems,
                        context: context,
                        leftItemKeys: leftItemKeys,
                        rightItemKeys: rightItemKeys,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftItem(String item, int index) {
    bool isSelected = selectedLeftItem == item;
    bool isConnected = connectedItems.contains(item);

    print(
      "🔍 Left Item: $item - isSelected: $isSelected - isConnected: $isConnected",
    );

    return Container(
          key: leftItemKeys[item], // Ajouter la clé
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: GestureDetector(
            onTap: () {
              print("🖱️ Left item tapped: $item");
              // Permettre de cliquer même si connecté pour changer la connexion
              handleItemTap(item, true);
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isSelected
                      ? [Colors.yellow.shade400, Colors.orange.shade500]
                      : isConnected
                      ? [Colors.green.shade400, Colors.green.shade600]
                      : [
                          Colors.white.withOpacity(0.9),
                          Colors.white.withOpacity(0.7),
                        ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
                border: isSelected
                    ? Border.all(color: Colors.yellow.shade300, width: 3)
                    : null,
              ),
              child: Row(
                children: [
                  if (isSelected)
                    Icon(Icons.touch_app, color: Colors.white, size: 20)
                  else if (isConnected)
                    Icon(Icons.check_circle, color: Colors.white, size: 20)
                  else
                    Icon(
                      Icons.drag_indicator,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ArabicText(
                      item,
                      style: ArabicTextStyle.smartStyle(
                        item,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: (isConnected || isSelected)
                            ? Colors.white
                            : Colors.grey.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate(target: isSelected ? 1 : 0)
        .scale(begin: Offset(1, 1), end: Offset(1.05, 1.05))
        .shimmer(duration: isSelected ? 1000.ms : 0.ms);
  }

  Widget _buildRightItem(String item, int index) {
    bool isConnected = connectedItems.contains(item);
    String? connectedLeftItem = userPairs.entries
        .where((entry) => entry.value == item)
        .map((entry) => entry.key)
        .firstOrNull;
    bool isCorrect =
        connectedLeftItem != null && correctPairs[connectedLeftItem] == item;

    print(
      "🔍 Right Item: $item - isConnected: $isConnected - isCorrect: $isCorrect",
    );

    return Container(
      key: rightItemKeys[item], // Ajouter la clé
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () {
          print("🖱️ Right item tapped: $item");
          // Permettre de cliquer même si connecté pour changer la connexion
          handleItemTap(item, false);
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isConnected
                  ? isCorrect
                        ? [Colors.green.shade400, Colors.green.shade600]
                        : [Colors.red.shade400, Colors.red.shade600]
                  : [
                      Colors.white.withOpacity(0.9),
                      Colors.white.withOpacity(0.7),
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              if (isConnected)
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                  size: 20,
                )
              else
                Icon(
                  Icons.radio_button_unchecked,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
              SizedBox(width: 12),
              Expanded(
                child: ArabicText(
                  item,
                  style: ArabicTextStyle.smartStyle(
                    item,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isConnected ? Colors.white : Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConnectionLinesPainter extends CustomPainter {
  final Map<String, String> userPairs;
  final Map<String, String> correctPairs;
  final List<String> leftItems;
  final List<String> rightItems;
  final BuildContext context;
  final Map<String, GlobalKey> leftItemKeys;
  final Map<String, GlobalKey> rightItemKeys;

  ConnectionLinesPainter({
    required this.userPairs,
    required this.correctPairs,
    required this.leftItems,
    required this.rightItems,
    required this.context,
    required this.leftItemKeys,
    required this.rightItemKeys,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (var entry in userPairs.entries) {
      final leftItem = entry.key;
      final rightItem = entry.value;

      // Obtenir les vraies positions des éléments
      final leftKey = leftItemKeys[leftItem];
      final rightKey = rightItemKeys[rightItem];

      if (leftKey?.currentContext != null && rightKey?.currentContext != null) {
        final leftRenderBox =
            leftKey!.currentContext!.findRenderObject() as RenderBox;
        final rightRenderBox =
            rightKey!.currentContext!.findRenderObject() as RenderBox;

        final leftPosition = leftRenderBox.localToGlobal(Offset.zero);
        final rightPosition = rightRenderBox.localToGlobal(Offset.zero);

        // Convertir en coordonnées locales du canvas
        final leftX =
            leftPosition.dx +
            leftRenderBox.size.width * 1; // Position X dans l'élément
        final rightX = rightPosition.dx; // Position X dans l'élément
        final leftY =
            leftPosition.dy + leftRenderBox.size.height / 2; // Centre Y
        final rightY =
            rightPosition.dy + rightRenderBox.size.height / 2; // Centre Y

        // Vérifier si la connexion est correcte
        final isCorrect = correctPairs[leftItem] == rightItem;

        // Couleur de la ligne
        paint.color = isCorrect ? Colors.greenAccent : Colors.redAccent;

        // Dessiner la ligne avec une courbe
        final path = Path();
        path.moveTo(leftX, leftY);

        // Créer une courbe douce
        final controlPoint1 = Offset(leftX + (rightX - leftX) * 0.3, leftY);
        final controlPoint2 = Offset(leftX + (rightX - leftX) * 0.7, rightY);
        path.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          rightX,
          rightY,
        );

        canvas.drawPath(path, paint);

        // Ajouter une flèche à la fin
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
