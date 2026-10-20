import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'LexiArabia'**
  String get appTitle;

  /// No description provided for @roadmap.
  ///
  /// In en, this message translates to:
  /// **'Roadmap'**
  String get roadmap;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @progression.
  ///
  /// In en, this message translates to:
  /// **'Progression'**
  String get progression;

  /// No description provided for @exercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exercises;

  /// No description provided for @lessons.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get lessons;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @newWordsToLearn.
  ///
  /// In en, this message translates to:
  /// **'New Words to Learn'**
  String get newWordsToLearn;

  /// No description provided for @startLesson.
  ///
  /// In en, this message translates to:
  /// **'Start Lesson'**
  String get startLesson;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @example.
  ///
  /// In en, this message translates to:
  /// **'Example'**
  String get example;

  /// No description provided for @noLessonsFound.
  ///
  /// In en, this message translates to:
  /// **'No lessons found'**
  String get noLessonsFound;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @lesson.
  ///
  /// In en, this message translates to:
  /// **'Lesson'**
  String get lesson;

  /// No description provided for @section.
  ///
  /// In en, this message translates to:
  /// **'Section'**
  String get section;

  /// No description provided for @question.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get question;

  /// No description provided for @answer.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get answer;

  /// No description provided for @options.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @correct.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get correct;

  /// No description provided for @incorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect!'**
  String get incorrect;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @continue_lesson.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_lesson;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @notStarted.
  ///
  /// In en, this message translates to:
  /// **'Not Started'**
  String get notStarted;

  /// No description provided for @totalXP.
  ///
  /// In en, this message translates to:
  /// **'Total XP'**
  String get totalXP;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @bestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best Streak'**
  String get bestStreak;

  /// No description provided for @accuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracy;

  /// No description provided for @lessonsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Lessons Completed'**
  String get lessonsCompleted;

  /// No description provided for @totalLessons.
  ///
  /// In en, this message translates to:
  /// **'Total Lessons'**
  String get totalLessons;

  /// No description provided for @lessonProgress.
  ///
  /// In en, this message translates to:
  /// **'Lesson Progress'**
  String get lessonProgress;

  /// No description provided for @badgesAndAchievements.
  ///
  /// In en, this message translates to:
  /// **'Badges & Achievements'**
  String get badgesAndAchievements;

  /// No description provided for @detailedStats.
  ///
  /// In en, this message translates to:
  /// **'Detailed Statistics'**
  String get detailedStats;

  /// No description provided for @totalStudyTime.
  ///
  /// In en, this message translates to:
  /// **'Total Study Time'**
  String get totalStudyTime;

  /// No description provided for @exercisesCompleted.
  ///
  /// In en, this message translates to:
  /// **'Exercises Completed'**
  String get exercisesCompleted;

  /// No description provided for @wordsLearned.
  ///
  /// In en, this message translates to:
  /// **'Words Learned'**
  String get wordsLearned;

  /// No description provided for @studySessions.
  ///
  /// In en, this message translates to:
  /// **'Study Sessions'**
  String get studySessions;

  /// No description provided for @activeDays.
  ///
  /// In en, this message translates to:
  /// **'Active Days'**
  String get activeDays;

  /// No description provided for @firstStep.
  ///
  /// In en, this message translates to:
  /// **'First Step'**
  String get firstStep;

  /// No description provided for @streak7Days.
  ///
  /// In en, this message translates to:
  /// **'7 Day Streak'**
  String get streak7Days;

  /// No description provided for @accuracy80Plus.
  ///
  /// In en, this message translates to:
  /// **'80%+ Accuracy'**
  String get accuracy80Plus;

  /// No description provided for @fiveLessons.
  ///
  /// In en, this message translates to:
  /// **'5 Lessons'**
  String get fiveLessons;

  /// No description provided for @streak30Days.
  ///
  /// In en, this message translates to:
  /// **'30 Day Streak'**
  String get streak30Days;

  /// No description provided for @hundredPercentAccuracy.
  ///
  /// In en, this message translates to:
  /// **'100% Accuracy'**
  String get hundredPercentAccuracy;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @percent.
  ///
  /// In en, this message translates to:
  /// **'%'**
  String get percent;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description:'**
  String get descriptionLabel;

  /// No description provided for @exampleLabel.
  ///
  /// In en, this message translates to:
  /// **'Example:'**
  String get exampleLabel;

  /// No description provided for @unknownWord.
  ///
  /// In en, this message translates to:
  /// **'Unknown word'**
  String get unknownWord;

  /// No description provided for @translationNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Translation not available'**
  String get translationNotAvailable;

  /// No description provided for @descriptionNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Description not available'**
  String get descriptionNotAvailable;

  /// No description provided for @exampleNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Example not available'**
  String get exampleNotAvailable;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get streakDays;

  /// No description provided for @completedLabel.
  ///
  /// In en, this message translates to:
  /// **'completed'**
  String get completedLabel;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @enableSound.
  ///
  /// In en, this message translates to:
  /// **'Enable Sound'**
  String get enableSound;

  /// No description provided for @userSelection.
  ///
  /// In en, this message translates to:
  /// **'User Selection'**
  String get userSelection;

  /// No description provided for @chooseDemoProfile.
  ///
  /// In en, this message translates to:
  /// **'Choose a demo profile'**
  String get chooseDemoProfile;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @understood.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get understood;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorWithDetails.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {details}'**
  String errorWithDetails(String details);

  /// No description provided for @sectionDescBasics.
  ///
  /// In en, this message translates to:
  /// **'Foundations of Arabic'**
  String get sectionDescBasics;

  /// No description provided for @sectionDescPronouns.
  ///
  /// In en, this message translates to:
  /// **'Pronouns and references'**
  String get sectionDescPronouns;

  /// No description provided for @sectionDescGrammar.
  ///
  /// In en, this message translates to:
  /// **'Grammar rules'**
  String get sectionDescGrammar;

  /// No description provided for @sectionDescVocabulary.
  ///
  /// In en, this message translates to:
  /// **'Essential vocabulary'**
  String get sectionDescVocabulary;

  /// No description provided for @sectionDescConversation.
  ///
  /// In en, this message translates to:
  /// **'Dialogues and expressions'**
  String get sectionDescConversation;

  /// No description provided for @sectionDescCulture.
  ///
  /// In en, this message translates to:
  /// **'Culture and traditions'**
  String get sectionDescCulture;

  /// No description provided for @sectionDescReligion.
  ///
  /// In en, this message translates to:
  /// **'Religious terms'**
  String get sectionDescReligion;

  /// No description provided for @sectionDescAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced level'**
  String get sectionDescAdvanced;

  /// No description provided for @sectionDescDefault.
  ///
  /// In en, this message translates to:
  /// **'Step-by-step learning'**
  String get sectionDescDefault;

  /// No description provided for @lessonLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Locked lesson'**
  String get lessonLockedTitle;

  /// No description provided for @lessonLockedMessage.
  ///
  /// In en, this message translates to:
  /// **'Finish the previous lesson to unlock this one.'**
  String get lessonLockedMessage;

  /// No description provided for @loadLessonsError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the lessons. Check your connection.'**
  String get loadLessonsError;

  /// No description provided for @roadmapWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to your journey!'**
  String get roadmapWelcomeTitle;

  /// No description provided for @roadmapWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start learning the words of the Quran'**
  String get roadmapWelcomeSubtitle;

  /// No description provided for @lessonAlreadyCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Lesson already completed'**
  String get lessonAlreadyCompletedTitle;

  /// No description provided for @lessonAlreadyCompletedMessage.
  ///
  /// In en, this message translates to:
  /// **'You have already completed this lesson.\nDo you want to do it again?'**
  String get lessonAlreadyCompletedMessage;

  /// No description provided for @redo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get redo;

  /// No description provided for @unknownExerciseType.
  ///
  /// In en, this message translates to:
  /// **'Unknown exercise type: {type}'**
  String unknownExerciseType(String type);

  /// No description provided for @invalidExerciseData.
  ///
  /// In en, this message translates to:
  /// **'This exercise can\'t be displayed.'**
  String get invalidExerciseData;

  /// No description provided for @noExercisesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No exercises available'**
  String get noExercisesAvailable;

  /// No description provided for @trueLabel.
  ///
  /// In en, this message translates to:
  /// **'True'**
  String get trueLabel;

  /// No description provided for @falseLabel.
  ///
  /// In en, this message translates to:
  /// **'False'**
  String get falseLabel;

  /// No description provided for @chooseCorrectAnswer.
  ///
  /// In en, this message translates to:
  /// **'Choose the correct answer'**
  String get chooseCorrectAnswer;

  /// No description provided for @trueOrFalseHint.
  ///
  /// In en, this message translates to:
  /// **'Is this statement true or false?'**
  String get trueOrFalseHint;

  /// No description provided for @listenToAudio.
  ///
  /// In en, this message translates to:
  /// **'Listen to the audio'**
  String get listenToAudio;

  /// No description provided for @playAudio.
  ///
  /// In en, this message translates to:
  /// **'Play pronunciation'**
  String get playAudio;

  /// No description provided for @audioUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Audio unavailable for this word on this device.'**
  String get audioUnavailable;

  /// No description provided for @chooseWhatYouHeard.
  ///
  /// In en, this message translates to:
  /// **'Choose what you heard'**
  String get chooseWhatYouHeard;

  /// No description provided for @completeTheSentence.
  ///
  /// In en, this message translates to:
  /// **'Complete the sentence:'**
  String get completeTheSentence;

  /// No description provided for @dragTheCorrectWord.
  ///
  /// In en, this message translates to:
  /// **'Drag or tap the correct word:'**
  String get dragTheCorrectWord;

  /// No description provided for @matchThePairs.
  ///
  /// In en, this message translates to:
  /// **'Match the pairs'**
  String get matchThePairs;

  /// No description provided for @feedbackCorrect1.
  ///
  /// In en, this message translates to:
  /// **'Excellent!'**
  String get feedbackCorrect1;

  /// No description provided for @feedbackCorrect2.
  ///
  /// In en, this message translates to:
  /// **'Well done!'**
  String get feedbackCorrect2;

  /// No description provided for @feedbackCorrect3.
  ///
  /// In en, this message translates to:
  /// **'Perfect!'**
  String get feedbackCorrect3;

  /// No description provided for @feedbackIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Not quite…'**
  String get feedbackIncorrect;

  /// No description provided for @correctAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'Correct answer:'**
  String get correctAnswerLabel;

  /// No description provided for @feedbackRetryLater.
  ///
  /// In en, this message translates to:
  /// **'You\'ll see this question again at the end.'**
  String get feedbackRetryLater;

  /// No description provided for @quitSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Quit?'**
  String get quitSessionTitle;

  /// No description provided for @quitSessionMessage.
  ///
  /// In en, this message translates to:
  /// **'Your progress in this session will be lost.'**
  String get quitSessionMessage;

  /// No description provided for @quit.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get quit;

  /// No description provided for @keepLearning.
  ///
  /// In en, this message translates to:
  /// **'Keep learning'**
  String get keepLearning;

  /// No description provided for @soundOn.
  ///
  /// In en, this message translates to:
  /// **'Turn sound on'**
  String get soundOn;

  /// No description provided for @soundOff.
  ///
  /// In en, this message translates to:
  /// **'Turn sound off'**
  String get soundOff;

  /// No description provided for @lessonCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Excellent work!'**
  String get lessonCompleteTitle;

  /// No description provided for @lessonCompleteMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ve completed all the exercises in this lesson! 🎉'**
  String get lessonCompleteMessage;

  /// No description provided for @xpEarned.
  ///
  /// In en, this message translates to:
  /// **'XP earned'**
  String get xpEarned;

  /// No description provided for @streakLabel.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streakLabel;

  /// No description provided for @srsIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Time to review your words! 🚀'**
  String get srsIntroTitle;

  /// No description provided for @srsIntroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 word to review — a quick session to lock in what you know.} other{{count} words to review — a quick session to lock in what you know.}}'**
  String srsIntroSubtitle(int count);

  /// No description provided for @startReview.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startReview;

  /// No description provided for @srsDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Great job! 🎉'**
  String get srsDoneTitle;

  /// No description provided for @srsDoneMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ve finished all your reviews for today!'**
  String get srsDoneMessage;

  /// No description provided for @srsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No reviews for today! 🎉'**
  String get srsEmptyTitle;

  /// No description provided for @srsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Come back tomorrow to strengthen what you\'ve learned'**
  String get srsEmptyMessage;

  /// No description provided for @srsReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'SRS Review'**
  String get srsReviewTitle;

  /// No description provided for @exercisesToReview.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 exercise to review} other{{count} exercises to review}}'**
  String exercisesToReview(int count);

  /// No description provided for @noReviewsToday.
  ///
  /// In en, this message translates to:
  /// **'No reviews for today'**
  String get noReviewsToday;

  /// No description provided for @dailyLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily limit reached'**
  String get dailyLimitTitle;

  /// No description provided for @dailyLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ve completed {completed}/{limit} lessons today.'**
  String dailyLimitMessage(int completed, int limit);

  /// No description provided for @dailyLimitComeBack.
  ///
  /// In en, this message translates to:
  /// **'Come back tomorrow to keep learning!'**
  String get dailyLimitComeBack;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signOutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can sign back in anytime.'**
  String get signOutSubtitle;

  /// No description provided for @signOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirm;

  /// No description provided for @dailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get dailyReminder;

  /// No description provided for @dailyReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A notification to keep your streak'**
  String get dailyReminderSubtitle;

  /// No description provided for @notificationsUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Available on the mobile app only'**
  String get notificationsUnsupported;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get reminderTime;

  /// No description provided for @reminderScheduled.
  ///
  /// In en, this message translates to:
  /// **'Reminder set for {time} every day'**
  String reminderScheduled(String time);

  /// No description provided for @notificationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked. Allow them in your phone settings.'**
  String get notificationPermissionDenied;

  /// No description provided for @reminderNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Time to learn! 📖'**
  String get reminderNotificationTitle;

  /// No description provided for @reminderNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'A few minutes today to learn new words of the Quran.'**
  String get reminderNotificationBody;

  /// No description provided for @reminderChannelName.
  ///
  /// In en, this message translates to:
  /// **'Daily reminders'**
  String get reminderChannelName;

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// No description provided for @youProgressed.
  ///
  /// In en, this message translates to:
  /// **'You\'ve made progress!'**
  String get youProgressed;

  /// No description provided for @learningProgress.
  ///
  /// In en, this message translates to:
  /// **'Learning progress'**
  String get learningProgress;

  /// No description provided for @before.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get before;

  /// No description provided for @added.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get added;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @loginWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to LexiArabia'**
  String get loginWelcome;

  /// No description provided for @signupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get signupTitle;

  /// No description provided for @signupWelcome.
  ///
  /// In en, this message translates to:
  /// **'Join LexiArabia'**
  String get signupWelcome;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get nameHint;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get enterName;

  /// No description provided for @nameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get nameTooShort;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'example@email.com'**
  String get emailHint;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get enterEmail;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get enterPassword;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get enterNewPassword;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm the password'**
  String get confirmPassword;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwordsDontMatch;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @createMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Create my account'**
  String get createMyAccount;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @noAccountYet.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccountYet;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @authUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account found with this email.'**
  String get authUserNotFound;

  /// No description provided for @authWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password.'**
  String get authWrongPassword;

  /// No description provided for @authUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get authUserDisabled;

  /// No description provided for @authTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again later.'**
  String get authTooManyRequests;

  /// No description provided for @authOperationNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Operation not allowed.'**
  String get authOperationNotAllowed;

  /// No description provided for @authSignInCanceled.
  ///
  /// In en, this message translates to:
  /// **'Sign-in was canceled.'**
  String get authSignInCanceled;

  /// No description provided for @authGoogleFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed. Check your configuration.'**
  String get authGoogleFailed;

  /// No description provided for @authNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your internet connection.'**
  String get authNetworkError;

  /// No description provided for @authGoogleError.
  ///
  /// In en, this message translates to:
  /// **'Error while signing in with Google.'**
  String get authGoogleError;

  /// No description provided for @authAccountExistsDifferentCredential.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with this email but a different sign-in method.'**
  String get authAccountExistsDifferentCredential;

  /// No description provided for @authInvalidCredential.
  ///
  /// In en, this message translates to:
  /// **'The credentials provided are invalid.'**
  String get authInvalidCredential;

  /// No description provided for @authUnknownError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get authUnknownError;

  /// No description provided for @authEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already in use.'**
  String get authEmailInUse;

  /// No description provided for @authWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'The password is too weak.'**
  String get authWeakPassword;

  /// No description provided for @onboarding1Title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to LexiArabia'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Your mission'**
  String get onboarding1Subtitle;

  /// No description provided for @onboarding1Description.
  ///
  /// In en, this message translates to:
  /// **'Learn Arabic by mastering the most frequent words of the Quran. Our goal: help you understand 80% of the sacred text.'**
  String get onboarding1Description;

  /// No description provided for @onboarding1Feature1.
  ///
  /// In en, this message translates to:
  /// **'Master the essential words of the Quran'**
  String get onboarding1Feature1;

  /// No description provided for @onboarding1Feature2.
  ///
  /// In en, this message translates to:
  /// **'Learn at your own pace with progressive lessons'**
  String get onboarding1Feature2;

  /// No description provided for @onboarding1Feature3.
  ///
  /// In en, this message translates to:
  /// **'Track your progress in real time'**
  String get onboarding1Feature3;

  /// No description provided for @onboarding1Feature4.
  ///
  /// In en, this message translates to:
  /// **'Earn rewards by completing challenges'**
  String get onboarding1Feature4;

  /// No description provided for @onboarding2Title.
  ///
  /// In en, this message translates to:
  /// **'How does it work?'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn 80% of the words of the Quran'**
  String get onboarding2Subtitle;

  /// No description provided for @onboarding2Description.
  ///
  /// In en, this message translates to:
  /// **'By learning only the 200 most frequent words of the Quran, you can understand about 80% of the text. That\'s our proven method.'**
  String get onboarding2Description;

  /// No description provided for @onboarding2Feature1.
  ///
  /// In en, this message translates to:
  /// **'200 words = 80% understanding'**
  String get onboarding2Feature1;

  /// No description provided for @onboarding2Feature2.
  ///
  /// In en, this message translates to:
  /// **'Lessons organized by theme'**
  String get onboarding2Feature2;

  /// No description provided for @onboarding2Feature3.
  ///
  /// In en, this message translates to:
  /// **'Varied interactive exercises'**
  String get onboarding2Feature3;

  /// No description provided for @onboarding2Feature4.
  ///
  /// In en, this message translates to:
  /// **'Spaced repetition for lasting memory'**
  String get onboarding2Feature4;

  /// No description provided for @onboarding3Title.
  ///
  /// In en, this message translates to:
  /// **'Progress and rewards'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Stay motivated'**
  String get onboarding3Subtitle;

  /// No description provided for @onboarding3Description.
  ///
  /// In en, this message translates to:
  /// **'Track your progress, unlock badges and celebrate every step of your learning. Each completed lesson brings you closer to your goal.'**
  String get onboarding3Description;

  /// No description provided for @onboarding3Feature1.
  ///
  /// In en, this message translates to:
  /// **'Detailed progress tracking'**
  String get onboarding3Feature1;

  /// No description provided for @onboarding3Feature2.
  ///
  /// In en, this message translates to:
  /// **'Badges and rewards to unlock'**
  String get onboarding3Feature2;

  /// No description provided for @onboarding3Feature3.
  ///
  /// In en, this message translates to:
  /// **'Statistics on your performance'**
  String get onboarding3Feature3;

  /// No description provided for @onboarding3Feature4.
  ///
  /// In en, this message translates to:
  /// **'Daily reminders to keep your rhythm'**
  String get onboarding3Feature4;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @defaultUserName.
  ///
  /// In en, this message translates to:
  /// **'Learner'**
  String get defaultUserName;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String daysCount(int count);

  /// No description provided for @percentCompleted.
  ///
  /// In en, this message translates to:
  /// **'{percent}% completed'**
  String percentCompleted(int percent);

  /// No description provided for @noLessonsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No lessons available'**
  String get noLessonsAvailable;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @achFirstLesson.
  ///
  /// In en, this message translates to:
  /// **'First lesson'**
  String get achFirstLesson;

  /// No description provided for @ach100Xp.
  ///
  /// In en, this message translates to:
  /// **'100 XP'**
  String get ach100Xp;

  /// No description provided for @ach7DayStreak.
  ///
  /// In en, this message translates to:
  /// **'7-day streak'**
  String get ach7DayStreak;

  /// No description provided for @achQuickLearner.
  ///
  /// In en, this message translates to:
  /// **'Quick learner'**
  String get achQuickLearner;

  /// No description provided for @achExpert.
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get achExpert;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
