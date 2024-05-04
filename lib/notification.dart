import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FlutterLocalNotification {
  // Singleton instance
  static final FlutterLocalNotification _instance = FlutterLocalNotification._();

  // Get singleton instance
  static FlutterLocalNotification get instance => _instance;

  // Private constructor
  FlutterLocalNotification._();

  // Static field for flutter local notifications plugin
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Initialization of the plugin
  static init() async {
    AndroidInitializationSettings androidInitializationSettings =
    const AndroidInitializationSettings('mipmap/ic_launcher');
    DarwinInitializationSettings iosInitializationSettings =
    const DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false);

    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Request notification permissions (iOS)
  static requestNotificationPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> showNotification() async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'channel id', 'channel name',
      channelDescription: 'channel description',
      importance: Importance.max,
      priority: Priority.max,
      sound: RawResourceAndroidNotificationSound('ready'),
      playSound: true,
      showWhen: false,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(
        badgeNumber: 2,
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'ready.aiff',
      ),
    );

    await flutterLocalNotificationsPlugin.show(
        0, '운동 준비!', '자세를 잡으세요.', notificationDetails);

  }

  Future<void> showExerciseStartNotification() async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'channel id', 'channel name',
      channelDescription: 'channel description',
      importance: Importance.max,
      priority: Priority.max,
      sound: RawResourceAndroidNotificationSound('start'),
      playSound: true,
      showWhen: false,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(
        badgeNumber: 3,
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'start.aiff',
      ),
    );

    await flutterLocalNotificationsPlugin.show(
        0, '운동 시작!', '드가자잇!', notificationDetails);

  }
}
