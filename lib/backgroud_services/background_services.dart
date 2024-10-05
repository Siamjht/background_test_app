import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final StopWatchTimer _stopWatchTimer = StopWatchTimer(mode: StopWatchMode.countUp);

const AndroidNotificationChannel notificationChannel = AndroidNotificationChannel(
  "stopwatch_foreground",
  "Stopwatch Foreground",
  description: "This channel is used for stopwatch notifications",
  importance: Importance.high,
);

Future<void> initService() async {
  var service = FlutterBackgroundService();

  if (Platform.isIOS) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(iOS: DarwinInitializationSettings()),
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(notificationChannel);

  await service.configure(
    iosConfiguration: IosConfiguration(
      onBackground: iosBackground,
      onForeground: onStart,
    ),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
      notificationChannelId: notificationChannel.id,
      initialNotificationTitle: "Stopwatch Service",
      initialNotificationContent: "Counting your progress",
      foregroundServiceNotificationId: 100,
    ),
  );

  service.startService(); // Start background service
}

@pragma("vm:entry-point")
void onStart(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized();

  _stopWatchTimer.onStartTimer();

  Timer.periodic(const Duration(hours: 1), (timer) {
    final currentTime = _stopWatchTimer.rawTime.value;
    final displayTime = StopWatchTimer.getDisplayTime(currentTime, hours: true, milliSecond: false);

    flutterLocalNotificationsPlugin.show(
      100,
      "Stopwatch Running",
      displayTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          notificationChannel.id,
          notificationChannel.name,
          ongoing: false,

          importance: Importance.high,
           icon: "app_icon",
        ),
      ),
    );
  });
}

@pragma("vm:entry-point")
Future<bool> iosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}
