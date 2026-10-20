import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Rappel quotidien d'étude (notification locale programmée)
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _reminderId = 1001;
  static const String _enabledKey = 'daily_reminder_enabled';
  static const String _hourKey = 'daily_reminder_hour';
  static const String _minuteKey = 'daily_reminder_minute';
  static const TimeOfDay defaultTime = TimeOfDay(hour: 19, minute: 0);

  static bool _initialized = false;

  /// Les rappels programmés ne sont gérés que sur mobile / macOS
  static bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  static Future<void> init() async {
    if (!isSupported || _initialized) return;
    try {
      tz_data.initializeTimeZones();
      try {
        final timezone = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timezone.identifier));
      } catch (e) {
        print('⚠️ Fuseau horaire local introuvable, UTC utilisé: $e');
      }

      // Les permissions sont demandées seulement quand l'utilisateur
      // active le rappel (pas au lancement de l'app)
      const darwin = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: darwin,
          macOS: darwin,
        ),
      );
      _initialized = true;
    } catch (e) {
      print("❌ Erreur lors de l'initialisation des notifications: $e");
    }
  }

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  static Future<TimeOfDay> getReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    return TimeOfDay(
      hour: prefs.getInt(_hourKey) ?? defaultTime.hour,
      minute: prefs.getInt(_minuteKey) ?? defaultTime.minute,
    );
  }

  /// Demander l'autorisation d'afficher des notifications
  static Future<bool> requestPermission() async {
    if (!isSupported) return false;
    await init();
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return await _plugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >()
                ?.requestNotificationsPermission() ??
            false;
      case TargetPlatform.iOS:
        return await _plugin
                .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin
                >()
                ?.requestPermissions(alert: true, badge: true, sound: true) ??
            false;
      case TargetPlatform.macOS:
        return await _plugin
                .resolvePlatformSpecificImplementation<
                  MacOSFlutterLocalNotificationsPlugin
                >()
                ?.requestPermissions(alert: true, badge: true, sound: true) ??
            false;
      default:
        return false;
    }
  }

  /// Activer le rappel quotidien. Retourne false si la permission est refusée.
  static Future<bool> enable({
    required TimeOfDay time,
    required String title,
    required String body,
    required String channelName,
  }) async {
    if (!await requestPermission()) return false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, true);
    await prefs.setInt(_hourKey, time.hour);
    await prefs.setInt(_minuteKey, time.minute);

    await _schedule(
      time: time,
      title: title,
      body: body,
      channelName: channelName,
    );
    return true;
  }

  static Future<void> disable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, false);
    if (!isSupported) return;
    await init();
    await _plugin.cancel(id: _reminderId);
  }

  /// Reprogrammer avec les textes actuels (ex. après un changement de langue)
  static Future<void> refresh({
    required String title,
    required String body,
    required String channelName,
  }) async {
    if (!isSupported || !await isEnabled()) return;
    await _schedule(
      time: await getReminderTime(),
      title: title,
      body: body,
      channelName: channelName,
    );
  }

  static Future<void> _schedule({
    required TimeOfDay time,
    required String title,
    required String body,
    required String channelName,
  }) async {
    if (!isSupported) return;
    await init();
    await _plugin.cancel(id: _reminderId);

    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));

    await _plugin.zonedSchedule(
      id: _reminderId,
      scheduledDate: next,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
        macOS: const DarwinNotificationDetails(),
      ),
      // Pas besoin d'alarme exacte pour un rappel : évite une permission sensible
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
