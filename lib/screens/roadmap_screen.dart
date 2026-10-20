import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dualingocoran/l10n/app_localizations.dart';
import 'package:dualingocoran/models/user_model.dart';
import 'package:dualingocoran/screens/lesson_preview_screen.dart';
import 'package:dualingocoran/services/learning_progress_service.dart';
import 'package:dualingocoran/services/user_provider.dart';
import 'package:dualingocoran/utils/translation_helper.dart';

const _gold = Color(0xFFD4AF37);
const _backgroundGradient = LinearGradient(
  colors: [
    Color(0xFF0F0C29),
    Color(0xFF24243e),
    Color(0xFF302B63),
    Color(0xFF0F0C29),
  ],
  stops: [0.0, 0.3, 0.7, 1.0],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

/// État d'une leçon sur la roadmap
enum LessonStatus { locked, current, unlocked, completed }

/// Élément de la roadmap : séparateur de section ou leçon
class _RoadmapItem {
  final int sectionIndex;
  final QueryDocumentSnapshot? lesson;
  final int animationIndex;
  final LessonStatus status;

  _RoadmapItem.separator(this.sectionIndex)
    : lesson = null,
      animationIndex = 0,
      status = LessonStatus.locked;

  _RoadmapItem.lesson({
    required this.sectionIndex,
    required QueryDocumentSnapshot this.lesson,
    required this.animationIndex,
    required this.status,
  });

  bool get isSeparator => lesson == null;
}

class RoadmapBubbleScreen extends StatefulWidget {
  const RoadmapBubbleScreen({super.key});

  @override
  State<RoadmapBubbleScreen> createState() => _RoadmapBubbleScreenState();
}

class _RoadmapBubbleScreenState extends State<RoadmapBubbleScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // Géométrie de la roadmap
  static const double _topOffset = 90;
  static const double _itemSpacing = 160;
  static const double _bubbleSize = 96;

  late AnimationController _bubbleController;
  late AnimationController _sectionPanelController;
  late AnimationController _pulseController;
  late AnimationController _percentageController;
  final ScrollController _scrollController = ScrollController();

  List<QueryDocumentSnapshot> _lessons = [];
  List<Map<String, dynamic>> _sections = [];
  List<Animation<double>> _bubbleAnimations = [];
  int _currentSectionIndex = 0;
  bool _isLoading = true;
  bool _hasError = false;
  double _learningPercentage = 0.0;

  @override
  void initState() {
    super.initState();
    _bubbleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _sectionPanelController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    )..repeat();
    _percentageController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scrollController.addListener(_updateCurrentSection);
    WidgetsBinding.instance.addObserver(this);

    _loadLessons();
    _loadLearningPercentage();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bubbleController.dispose();
    _sectionPanelController.dispose();
    _pulseController.dispose();
    _percentageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadLearningPercentage();
    }
  }

  // ---------------------------------------------------------------------------
  // Chargement des données
  // ---------------------------------------------------------------------------

  Future<void> _loadLessons() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('lessons')
          .orderBy('sectionOrder')
          .orderBy('lessonOrder')
          .get();
      if (!mounted) return;

      setState(() {
        _lessons = snapshot.docs;
        _sections = _organizeLessonsIntoSections(snapshot.docs);
        _bubbleAnimations = List.generate(_lessons.length, (index) {
          final start = math.min(index * 0.08, 0.8);
          return CurvedAnimation(
            parent: _bubbleController,
            curve: Interval(
              start,
              math.min(start + 0.2, 1.0),
              curve: Curves.elasticOut,
            ),
          );
        });
        _isLoading = false;
      });

      _sectionPanelController.forward();
      _bubbleController.forward();
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scrollToCurrentLesson(),
      );
    } catch (e) {
      print('Erreur lors du chargement des leçons: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  Future<void> _loadLearningPercentage() async {
    try {
      final percentage = await LearningProgressService.getLearningPercentage();
      if (mounted) {
        setState(() => _learningPercentage = percentage);
        _percentageController
          ..reset()
          ..forward();
      }
    } catch (e) {
      print('Erreur lors du chargement du pourcentage: $e');
    }
  }

  List<Map<String, dynamic>> _organizeLessonsIntoSections(
    List<QueryDocumentSnapshot> lessons,
  ) {
    final sectionMap = <String, List<QueryDocumentSnapshot>>{};
    for (final lesson in lessons) {
      final data = lesson.data() as Map<String, dynamic>;
      final section = data['section'] as String? ?? 'Basics';
      sectionMap.putIfAbsent(section, () => []).add(lesson);
    }

    final sections = sectionMap.entries.map((entry) {
      final firstData = entry.value.first.data() as Map<String, dynamic>;
      return <String, dynamic>{
        'name': entry.key,
        'title': firstData['sectionTitle'],
        'icon': _getSectionIcon(entry.key),
        'lessons': entry.value,
      };
    }).toList();

    sections.sort(
      (a, b) =>
          _getSectionOrder(a['name']).compareTo(_getSectionOrder(b['name'])),
    );
    return sections;
  }

  // ---------------------------------------------------------------------------
  // État des leçons (verrouillage progressif)
  // ---------------------------------------------------------------------------

  /// Construit la liste ordonnée des éléments de la roadmap.
  ///
  /// Une leçon est débloquée si c'est la première, si la leçon précédente est
  /// terminée, ou si elle a déjà été commencée. La leçon "courante" est la
  /// première leçon débloquée non terminée.
  List<_RoadmapItem> _buildRoadmapItems(Map<String, LessonProgress> progress) {
    final items = <_RoadmapItem>[];
    bool previousCompleted = true;
    bool currentAssigned = false;

    for (
      int sectionIndex = 0;
      sectionIndex < _sections.length;
      sectionIndex++
    ) {
      final sectionLessons =
          _sections[sectionIndex]['lessons'] as List<QueryDocumentSnapshot>;
      if (sectionLessons.isEmpty) continue;

      items.add(_RoadmapItem.separator(sectionIndex));

      for (final lesson in sectionLessons) {
        final lessonProgress = progress[lesson.id];
        final isCompleted = lessonProgress?.completed ?? false;
        final isUnlocked =
            previousCompleted || isCompleted || lessonProgress != null;

        LessonStatus status;
        if (isCompleted) {
          status = LessonStatus.completed;
        } else if (!isUnlocked) {
          status = LessonStatus.locked;
        } else if (!currentAssigned) {
          status = LessonStatus.current;
          currentAssigned = true;
        } else {
          status = LessonStatus.unlocked;
        }

        items.add(
          _RoadmapItem.lesson(
            sectionIndex: sectionIndex,
            lesson: lesson,
            animationIndex: _lessons.indexWhere((l) => l.id == lesson.id),
            status: status,
          ),
        );
        previousCompleted = isCompleted;
      }
    }
    return items;
  }

  Map<String, LessonProgress> _currentProgress({bool listen = false}) {
    final userProvider = Provider.of<UserProvider>(context, listen: listen);
    return userProvider.currentUser?.progress.lessons ?? {};
  }

  /// Faire défiler la roadmap jusqu'à la leçon courante
  void _scrollToCurrentLesson() {
    if (!mounted || !_scrollController.hasClients) return;
    final items = _buildRoadmapItems(_currentProgress());
    final index = items.indexWhere((i) => i.status == LessonStatus.current);
    if (index <= 1) return;

    final position = _scrollController.position;
    final target = (_itemY(index) - position.viewportDimension / 2).clamp(
      0.0,
      position.maxScrollExtent,
    );
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOutCubic,
    );
  }

  void _updateCurrentSection() {
    if (_sections.isEmpty || !_scrollController.hasClients) return;
    final items = _buildRoadmapItems(_currentProgress());
    if (items.isEmpty) return;

    final viewportCenter =
        _scrollController.offset +
        _scrollController.position.viewportDimension / 2;
    final index = ((viewportCenter - _topOffset) / _itemSpacing).round().clamp(
      0,
      items.length - 1,
    );
    final sectionIndex = items[index].sectionIndex;

    if (sectionIndex != _currentSectionIndex) {
      setState(() => _currentSectionIndex = sectionIndex);
      _sectionPanelController
        ..reset()
        ..forward();
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers de présentation
  // ---------------------------------------------------------------------------

  String _translate(dynamic field, {String fallback = ''}) {
    if (field is Map) {
      return TranslationHelper.getTranslation(
        context,
        Map<String, dynamic>.from(field),
        '',
      );
    }
    if (field is String && field.isNotEmpty) return field;
    return fallback;
  }

  String _sectionTitle(Map<String, dynamic> section) =>
      _translate(section['title'], fallback: section['name'] as String);

  String _sectionDescription(String sectionName, AppLocalizations l10n) {
    switch (sectionName.toLowerCase()) {
      case 'basics':
        return l10n.sectionDescBasics;
      case 'pronouns':
        return l10n.sectionDescPronouns;
      case 'grammar':
        return l10n.sectionDescGrammar;
      case 'vocabulary':
        return l10n.sectionDescVocabulary;
      case 'conversation':
        return l10n.sectionDescConversation;
      case 'culture':
        return l10n.sectionDescCulture;
      case 'religion':
        return l10n.sectionDescReligion;
      case 'advanced':
        return l10n.sectionDescAdvanced;
      default:
        return l10n.sectionDescDefault;
    }
  }

  IconData _getSectionIcon(String sectionName) {
    switch (sectionName.toLowerCase()) {
      case 'basics':
        return Icons.abc;
      case 'pronouns':
        return Icons.person;
      case 'grammar':
        return Icons.book;
      case 'vocabulary':
        return Icons.translate;
      case 'conversation':
        return Icons.chat;
      case 'culture':
        return Icons.celebration;
      case 'religion':
        return Icons.church;
      case 'advanced':
        return Icons.school;
      default:
        return Icons.star;
    }
  }

  int _getSectionOrder(String sectionName) {
    switch (sectionName.toLowerCase()) {
      case 'pronouns':
        return 1;
      case 'basics':
        return 2;
      case 'grammar':
        return 3;
      case 'vocabulary':
        return 4;
      case 'conversation':
        return 5;
      case 'culture':
        return 6;
      case 'religion':
        return 7;
      case 'advanced':
        return 8;
      default:
        return 999;
    }
  }

  IconData _getLessonIcon(int lessonOrder) {
    const icons = [
      Icons.school_rounded,
      Icons.menu_book_rounded,
      Icons.lightbulb_rounded,
      Icons.star_rounded,
      Icons.emoji_events_rounded,
    ];
    return icons[(lessonOrder - 1) % icons.length];
  }

  double _itemY(int index) => _topOffset + index * _itemSpacing;

  Offset _bubblePosition(int index, double width) {
    final zigzag = index.isEven ? -1.0 : 1.0;
    return Offset(width * 0.5 + zigzag * width * 0.22, _itemY(index));
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _onLessonTap(_RoadmapItem item, String title) async {
    final l10n = AppLocalizations.of(context)!;

    if (item.status == LessonStatus.locked) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.lock_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.lessonLockedMessage,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF302B63),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      return;
    }

    HapticFeedback.selectionClick();

    if (item.status == LessonStatus.completed) {
      final shouldRedo = await showDialog<bool>(
        context: context,
        builder: (context) => _LessonRedoDialog(lessonTitle: title),
      );
      if (shouldRedo != true || !mounted) return;
    }

    final data = item.lesson!.data() as Map<String, dynamic>;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonPreviewScreen(
          lessonTitle: title,
          lessonDescription: _translate(data['description']),
          newWords: data['words'] as List<dynamic>? ?? [],
          exercises: data['exercises'] as List<dynamic>? ?? [],
          sectionTitle: l10n.lesson,
          lessonId: item.lesson!.id,
        ),
      ),
    );

    // La progression est déjà mise à jour dans UserProvider par la leçon :
    // on rafraîchit seulement le pourcentage et on montre la leçon suivante.
    if (result == true && mounted) {
      _loadLearningPercentage();
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scrollToCurrentLesson(),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final progress = _currentProgress(listen: true);
    final items = _buildRoadmapItems(progress);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: _backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildLearningPercentageWidget(),
              const SizedBox(height: 12),
              _buildSectionPanel(progress),
              Expanded(child: _buildBody(items)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(List<_RoadmapItem> items) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _gold));
    }

    if (_hasError || items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _hasError ? Icons.cloud_off_rounded : Icons.menu_book_rounded,
                size: 56,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                _hasError ? l10n.loadLessonsError : l10n.noLessonsFound,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadLessons,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      controller: _scrollController,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth - 40;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: _topOffset + items.length * _itemSpacing + 40,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                for (int i = 0; i < items.length; i++)
                  items[i].isSeparator
                      ? _buildSectionSeparator(items[i], i)
                      : _buildLessonBubble(items[i], i, width),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionSeparator(_RoadmapItem item, int index) {
    final title = _sectionTitle(_sections[item.sectionIndex]);

    return Positioned(
      left: 0,
      right: 0,
      top: _itemY(index) - 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.3),
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.3),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF302B63).withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonBubble(_RoadmapItem item, int index, double width) {
    final l10n = AppLocalizations.of(context)!;
    final data = item.lesson!.data() as Map<String, dynamic>;
    final title = _translate(data['title'], fallback: l10n.lesson);
    final position = _bubblePosition(index, width);
    final status = item.status;

    final Color color;
    final IconData icon;
    switch (status) {
      case LessonStatus.completed:
        color = const Color(0xFF4CAF50);
        icon = Icons.check_rounded;
        break;
      case LessonStatus.current:
        color = _gold;
        icon = _getLessonIcon((data['lessonOrder'] as int?) ?? 1);
        break;
      case LessonStatus.unlocked:
        color = const Color(0xFF6D5DF6);
        icon = _getLessonIcon((data['lessonOrder'] as int?) ?? 1);
        break;
      case LessonStatus.locked:
        color = const Color(0xFF4A4A5E);
        icon = Icons.lock_rounded;
        break;
    }
    final isLocked = status == LessonStatus.locked;
    final isCurrent = status == LessonStatus.current;

    final bubble = Container(
      width: _bubbleSize,
      height: _bubbleSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Color.lerp(color, Colors.black, 0.25)!],
          center: const Alignment(-0.3, -0.4),
          radius: 1.0,
        ),
        border: Border.all(
          color: isLocked
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: isCurrent ? 0.95 : 0.5),
          width: 3,
        ),
        boxShadow: isLocked
            ? null
            : [
                BoxShadow(
                  color: color.withValues(alpha: 0.45),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Icon(
        icon,
        size: 40,
        color: isLocked ? Colors.white.withValues(alpha: 0.4) : Colors.white,
      ),
    );

    final animation =
        item.animationIndex >= 0 &&
            item.animationIndex < _bubbleAnimations.length
        ? _bubbleAnimations[item.animationIndex]
        : const AlwaysStoppedAnimation(1.0);

    return Positioned(
      left: position.dx - 70,
      top: position.dy - 60,
      width: 140,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final value = animation.value;
          return Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: Transform.scale(scale: math.max(0.0, value), child: child),
          );
        },
        child: Semantics(
          button: true,
          label: isLocked ? '$title — ${l10n.lessonLockedTitle}' : title,
          child: GestureDetector(
            onTap: () => _onLessonTap(item, title),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 124,
                  height: 124,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isCurrent)
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, _) {
                            final t = _pulseController.value;
                            return Container(
                              width: _bubbleSize + 26 * t,
                              height: _bubbleSize + 26 * t,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _gold.withValues(alpha: 1 - t),
                                  width: 3,
                                ),
                              ),
                            );
                          },
                        ),
                      bubble,
                    ],
                  ),
                ),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    height: 1.2,
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                    color: isCurrent
                        ? _gold
                        : Colors.white.withValues(alpha: isLocked ? 0.4 : 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionPanel(Map<String, LessonProgress> progress) {
    final l10n = AppLocalizations.of(context)!;

    final String title;
    final String description;
    final IconData icon;
    String? counter;

    if (_sections.isEmpty) {
      title = l10n.roadmapWelcomeTitle;
      description = l10n.roadmapWelcomeSubtitle;
      icon = Icons.school;
    } else {
      final section =
          _sections[_currentSectionIndex.clamp(0, _sections.length - 1)];
      final lessons = section['lessons'] as List<QueryDocumentSnapshot>;
      final completed = lessons
          .where((l) => progress[l.id]?.completed ?? false)
          .length;
      title = _sectionTitle(section);
      description = _sectionDescription(section['name'] as String, l10n);
      icon = section['icon'] as IconData;
      counter = '$completed/${lessons.length}';
    }

    return AnimatedBuilder(
      animation: _sectionPanelController,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, (1 - _sectionPanelController.value) * -20),
        child: Opacity(opacity: _sectionPanelController.value, child: child),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF302B63).withValues(alpha: 0.95),
              const Color(0xFF24243e).withValues(alpha: 0.9),
              const Color(0xFF0F0C29).withValues(alpha: 0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: _gold.withValues(alpha: 0.6), width: 2),
          boxShadow: [
            BoxShadow(
              color: _gold.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _gold.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _gold.withValues(alpha: 0.6),
                  width: 2,
                ),
              ),
              child: Icon(icon, color: _gold, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            if (counter != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: _gold.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: _gold, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      counter,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningPercentageWidget() {
    return AnimatedBuilder(
      animation: _percentageController,
      builder: (context, child) {
        final animatedPercentage =
            _learningPercentage * _percentageController.value;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _gold.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.trending_up,
                color: _gold.withValues(alpha: 0.8),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                '${animatedPercentage.toStringAsFixed(1)}%',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 60,
                height: 4,
                alignment: AlignmentDirectional.centerStart,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                child: Container(
                  width: 60 * (animatedPercentage / 100).clamp(0.0, 1.0),
                  decoration: BoxDecoration(
                    color: _gold.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Dialogue demandant si l'utilisateur veut refaire une leçon complétée
class _LessonRedoDialog extends StatelessWidget {
  final String lessonTitle;

  const _LessonRedoDialog({required this.lessonTitle});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade300, Colors.orange.shade400],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 42,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.lessonAlreadyCompletedTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.lessonAlreadyCompletedMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                lessonTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(true),
                    icon: const Icon(Icons.refresh, size: 20),
                    label: Text(
                      l10n.redo,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
