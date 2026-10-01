import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'api_service.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await _localNotif.initialize(initSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'sikad_channel',
      'SIKAD Notifications',
      description: 'Notifikasi dari aplikasi SIKAD UIR',
      importance: Importance.high,
    );

    await _localNotif
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Minta izin notifikasi dari user
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // ============================================================
    // DEBUG - Cek FCM token saat app pertama kali dibuka
    // Hapus setelah testing selesai
    // ============================================================
    String? currentToken = await _messaging.getToken();
    print('=== FCM TOKEN SAAT INIT: $currentToken ===');

    // Jika token berubah, update ke Laravel
    _messaging.onTokenRefresh.listen((newToken) {
      print('=== FCM TOKEN REFRESH: $newToken ===');
      ApiService.saveFcmToken(newToken);
    });

    // Tampilkan notifikasi saat app di FOREGROUND
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('=== NOTIF FOREGROUND DITERIMA: ${message.notification?.title} ===');
      _showLocalNotification(message);
    });

    // Debug: notifikasi saat app di background (user tap)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('=== NOTIF BACKGROUND DIBUKA: ${message.notification?.title} ===');
    });
  }

  // Dipanggil setelah login berhasil
  static Future<void> saveFcmTokenAfterLogin() async {
    try {
      String? token = await _messaging.getToken();
      print('=== FCM TOKEN AFTER LOGIN: $token ===');
      if (token != null) {
        await ApiService.saveFcmToken(token);
        print('=== TOKEN TERSIMPAN SETELAH LOGIN! ===');
      } else {
        print('=== TOKEN NULL - FCM GAGAL! ===');
      }
    } catch (e) {
      print('=== ERROR SAVE TOKEN: $e ===');
    }
  }

  // Tampilkan notifikasi lokal
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'sikad_channel',
      'SIKAD Notifications',
      channelDescription: 'Notifikasi dari aplikasi SIKAD UIR',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _localNotif.show(
      0,
      message.notification?.title ?? 'SIKAD UIR',
      message.notification?.body ?? '',
      details,
    );
  }
}