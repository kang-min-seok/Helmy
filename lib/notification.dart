import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlutterLocalNotification {
  FlutterLocalNotification._();

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static init() async {
    AndroidInitializationSettings androidInitializationSettings =
        const AndroidInitializationSettings('mipmap/ic_launcher');
    DarwinInitializationSettings iosInitializationSettings =
        const DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static requestNotificationPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static Future<void> showNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final bool? savedIsNotification = prefs.getBool('isNotification');

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('channel id', 'channel name',
            channelDescription: 'channel description',
            importance: Importance.max,
            priority: Priority.max,
            sound: RawResourceAndroidNotificationSound('ready'),
            playSound: true,
            showWhen: false);

    const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: DarwinNotificationDetails(
            badgeNumber: 2,
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'ready.aiff'
        ));
    if(savedIsNotification != null && savedIsNotification){
      await flutterLocalNotificationsPlugin.show(
          0, '운동 준비!', '자세를 잡으세요.', notificationDetails);
    } else if(savedIsNotification == null) {
      await flutterLocalNotificationsPlugin.show(
          0, '운동 준비!', '자세를 잡으세요.', notificationDetails);
    }
  }

  static Future<void> showExerciseStartNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final bool? savedIsNotification = prefs.getBool('isNotification');

    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails('channel id', 'channel name',
        channelDescription: 'channel description',
        importance: Importance.max,
        priority: Priority.max,
        sound: RawResourceAndroidNotificationSound('start'),
        playSound: true,
        showWhen: false);

    const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: DarwinNotificationDetails(
          badgeNumber: 3,
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'start.aiff',
        ));


    if(savedIsNotification != null && savedIsNotification){
      await flutterLocalNotificationsPlugin.show(
          0, '운동 시작!', '드가자잇!', notificationDetails);
    } else if(savedIsNotification == null) {
      await flutterLocalNotificationsPlugin.show(
          0, '운동 시작!', '드가자잇!', notificationDetails);
    }
  }
}
