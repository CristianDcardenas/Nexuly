import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.instance.initializeLocalNotifications();
  await NotificationService.instance.showRemoteMessage(message);
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _localReady = false;
  bool _fcmReady = false;

  bool get _supportsLocalNotifications {
    if (kIsWeb) return false;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.macOS ||
      TargetPlatform.linux => true,
      _ => false,
    };
  }

  bool get _supportsFirebaseMessaging {
    if (kIsWeb) return false;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.macOS => true,
      _ => false,
    };
  }

  static const AndroidNotificationChannel _careChannel =
      AndroidNotificationChannel(
        'nexuly_care_alerts',
        'Recordatorios de cuidado',
        description: 'Recordatorios, alertas de reserva y mensajes remotos.',
        importance: Importance.high,
      );

  Future<void> initialize() async {
    await initializeLocalNotifications();
    await initializeFirebaseMessaging();
  }

  Future<void> initializeLocalNotifications() async {
    if (_localReady) return;
    if (!_supportsLocalNotifications) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        macOS: iosSettings,
      ),
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(_careChannel);
    await androidPlugin?.requestNotificationsPermission();

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    _localReady = true;
  }

  Future<void> initializeFirebaseMessaging() async {
    if (_fcmReady || !_supportsFirebaseMessaging) return;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(showRemoteMessage);

    try {
      final token = await messaging.getToken();
      if (kDebugMode) debugPrint('FCM token: $token');
    } catch (error) {
      if (kDebugMode) debugPrint('FCM token unavailable: $error');
    }

    _fcmReady = true;
  }

  Future<void> showRemoteMessage(RemoteMessage message) async {
    if (!_localReady) return;

    final title =
        message.notification?.title ?? message.data['title'] as String?;
    final body = message.notification?.body ?? message.data['body'] as String?;
    if (title == null && body == null) return;

    await _localNotifications.show(
      message.hashCode,
      title ?? 'Nexuly',
      body ?? 'Tienes una nueva actualización.',
      _notificationDetails(),
      payload: message.data['route'] as String?,
    );
  }

  Future<void> showCareAlert({
    required String title,
    required String body,
  }) async {
    if (!_localReady) return;

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      _notificationDetails(),
    );
  }

  Future<void> scheduleDailyCareReminder({
    required int hour,
    required int minute,
  }) async {
    if (!_localReady) return;

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _localNotifications.zonedSchedule(
      2001,
      'Recordatorio de cuidado',
      'Es momento de revisar signos, hidratación o medicamentos pendientes.',
      scheduled,
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleUpcomingAppointmentAlert({
    Duration delay = const Duration(seconds: 15),
  }) async {
    if (!_localReady) return;

    final scheduled = tz.TZDateTime.now(tz.local).add(delay);

    await _localNotifications.zonedSchedule(
      2002,
      'Alerta de reserva',
      'Tu próximo servicio está cerca. Confirma dirección y detalles del paciente.',
      scheduled,
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'nexuly_care_alerts',
        'Recordatorios de cuidado',
        channelDescription:
            'Recordatorios, alertas de reserva y mensajes remotos.',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );
  }
}
