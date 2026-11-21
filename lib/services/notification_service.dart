import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:suchigo_collector/helpers/sp_helper.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  const border =
      '══════════════════════════════════════════════════════════════';
  print(border);
  print('🔔🔔🔔 [FCM BACKGROUND NOTIFICATION RECEIVED] 🔔🔔🔔');
  print('🆔 Message ID: ${message.messageId}');
  print('📦 Collapse Key / Target Package: ${message.collapseKey}');
  print('📤 From (Sender): ${message.from}');
  print('📝 Title: "${message.notification?.title}"');
  print('📄 Body: "${message.notification?.body}"');
  print('🔑 Data Keys (${message.data.length}): ${message.data.keys.toList()}');
  message.data.forEach((k, v) {
    print('   👉 $k: "$v"');
  });
  print(border);

  try {
    final FlutterLocalNotificationsPlugin localNotif =
        FlutterLocalNotificationsPlugin();
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await localNotif.initialize(initSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );
    await localNotif
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    final data = message.data;
    String title = message.notification?.title ?? '';
    String body = message.notification?.body ?? '';

    if (title.isEmpty) {
      if (data['type'] == 'payment_update' || data['payment_status'] != null) {
        final status =
            (data['payment_status'] ?? 'paid').toString().toUpperCase();
        final amount = data['amount'] != null ? '₹${data['amount']}' : '';
        final userName =
            data['user_name'] != null ? ' for ${data['user_name']}' : '';
        title = 'Payment $status';
        body = 'Payment of $amount$userName has been confirmed.';
      } else if (data['title'] != null) {
        title = data['title'].toString();
        body = data['body']?.toString() ?? '';
      } else {
        title = 'Payment Update';
        body = 'Payment status updated: ${data['payment_status'] ?? ''}';
      }
    }

    final int id = message.messageId?.hashCode ??
        (DateTime.now().millisecondsSinceEpoch ~/ 1000);

    await localNotif.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: 'ic_notification',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      ),
      payload: message.data.toString(),
    );
    print(
        '✅ [FCM Background Handler] Local notification displayed successfully (id: $id)');
  } catch (e, stack) {
    print(
        '❌ [FCM Background Handler] Failed to show local notification: $e\n$stack');
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  final StreamController<RemoteMessage> _messageStreamController =
      StreamController<RemoteMessage>.broadcast();

  Stream<RemoteMessage> get messageStream => _messageStreamController.stream;

  bool isPaymentNotification(RemoteMessage message) {
    final data = message.data;
    final title = message.notification?.title?.toLowerCase() ?? '';
    final body = message.notification?.body?.toLowerCase() ?? '';

    final type = (data['type'] ?? data['event'] ?? data['action'] ?? '')
        .toString()
        .toLowerCase();
    final status = (data['status'] ?? data['payment_status'] ?? '')
        .toString()
        .toLowerCase();

    if (type.contains('payment') ||
        status.contains('paid') ||
        status.contains('success') ||
        status.contains('approv') ||
        status.contains('complete') ||
        status.contains('verif')) {
      return true;
    }

    if (title.contains('payment') ||
        body.contains('payment') ||
        title.contains('cash') ||
        body.contains('cash') ||
        title.contains('paid') ||
        body.contains('paid') ||
        title.contains('approved') ||
        body.contains('approved')) {
      return true;
    }

    return false;
  }

  Future<void> initialize() async {
    try {
      await Firebase.initializeApp();

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      await _requestPermission();
      await _initLocalNotifications();
      await _setupMessagingListeners();
      await getFcmToken();
    } catch (e) {
      debugPrint('[NotificationService] Initialization error: $e');
    }
  }

  Future<void> _requestPermission() async {
    try {
      if (await Permission.notification.isDenied) {
        final perm = await Permission.notification.request();
        print('📱 [NotificationService] POST_NOTIFICATIONS status: $perm');
      }
    } catch (e) {
      debugPrint('[NotificationService] Permission handler error: $e');
    }

    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    print(
      '📱 [NotificationService] Firebase authorizationStatus: ${settings.authorizationStatus}',
    );

    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint(
          '[NotificationService] Notification tapped: ${response.payload}',
        );
      },
    );

    final androidImplementation =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.createNotificationChannel(_androidChannel);
  }

  void _logNotification(String source, RemoteMessage message) {
    const border =
        '══════════════════════════════════════════════════════════════';
    print(border);
    print('🔔🔔🔔 [FCM NOTIFICATION RECEIVED] 🔔🔔🔔');
    print('📍 Source / State: $source');
    print('🆔 Message ID: ${message.messageId}');
    print('📦 Collapse Key / Target Package: ${message.collapseKey}');
    print('📤 From (Sender): ${message.from}');

    print('📝 Title: "${message.notification?.title}"');
    print('📄 Body: "${message.notification?.body}"');
    print(
        '🔑 Data Keys (${message.data.length}): ${message.data.keys.toList()}');
    message.data.forEach((k, v) {
      print('   👉 $k: "$v"');
    });
    print('💳 Is Payment Notification: ${isPaymentNotification(message)}');
    print(border);
  }

  Future<void> _setupMessagingListeners() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _logNotification('FOREGROUND (App Active)', message);
      _messageStreamController.add(message);
      // _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _logNotification(
          'OPENED FROM BACKGROUND (User Tapped Notification)', message);
      _messageStreamController.add(message);
    });

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _logNotification(
          'TERMINATED (App Opened from Dead State via Notification)',
          initialMessage);
      _messageStreamController.add(initialMessage);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      _fcmToken = newToken;
      await SpHelper.saveString('fcm_token', newToken);
      print('====================================================');
      print('🔄 [FCM TOKEN REFRESHED]: $newToken');
      print('====================================================');
    });
  }

  /// Completely wipes any existing FCM token from memory, local storage, and Firebase servers
  Future<void> deleteToken() async {
    try {
      print(
          '🗑️ [NotificationService] Invalidating and deleting old FCM token...');
      _fcmToken = null;
      await SpHelper.remove('fcm_token');
      await SpHelper.remove('fcm_token', secure: true);
      await FirebaseMessaging.instance.deleteToken();
      print('✅ [NotificationService] Old FCM token successfully wiped.');
    } catch (e) {
      debugPrint('[NotificationService] deleteToken error: $e');
    }
  }

  /// Forces the creation of a BRAND-NEW FCM token at login time (strictly ignores and deletes old tokens)
  Future<String?> generateNewFcmToken() async {
    try {
      print('════════════════════════════════════════════════════');
      print(
          '🔄 [NotificationService] LOGIN TIME: CREATING BRAND-NEW FCM TOKEN...');
      print('════════════════════════════════════════════════════');

      // 1. Immediately clear memory and persistent storage so old token cannot be reused
      _fcmToken = null;
      await SpHelper.remove('fcm_token');
      await SpHelper.remove('fcm_token', secure: true);

      // 2. Ensure permissions are in place
      await _requestPermission();

      // 3. Unregister and delete the old token on Firebase servers
      try {
        await FirebaseMessaging.instance.deleteToken();
        print(
            '🗑️ [NotificationService] Old token unregistered on Firebase servers.');
      } catch (e) {
        debugPrint('[NotificationService] deleteToken notice: $e');
      }

      // 4. Brief delay for Google Play Services to finalize unregistration
      await Future.delayed(const Duration(milliseconds: 350));

      // 5. Ask Firebase for a fresh registration token
      final freshToken = await FirebaseMessaging.instance.getToken();
      if (freshToken != null && freshToken.isNotEmpty) {
        _fcmToken = freshToken;
        await SpHelper.saveString('fcm_token', freshToken);
        print('════════════════════════════════════════════════════');
        print('🎉 [BRAND-NEW FCM TOKEN GENERATED AT LOGIN]:');
        print('👉 $freshToken');
        print('════════════════════════════════════════════════════');
        return freshToken;
      }
    } catch (e) {
      print(
          '❌ [NotificationService] Error during fresh FCM token generation: $e');
    }

    // Direct fallback retry if initial request timed out (without using any cached old token)
    try {
      final retryToken = await FirebaseMessaging.instance.getToken();
      if (retryToken != null && retryToken.isNotEmpty) {
        _fcmToken = retryToken;
        await SpHelper.saveString('fcm_token', retryToken);
        return retryToken;
      }
    } catch (e) {
      print('❌ [NotificationService] Retry token fetch error: $e');
    }

    return null;
  }

  Future<String?> getFcmToken() async {
    try {
      _fcmToken = await FirebaseMessaging.instance.getToken();
      if (_fcmToken != null) {
        await SpHelper.saveString('fcm_token', _fcmToken!);
        print('====================================================');
        print('🔑 [FCM TOKEN] CURRENT DEVICE TOKEN:');
        print(_fcmToken);
        print('====================================================');
      }
      return _fcmToken;
    } catch (e) {
      print('❌ [NotificationService] Failed to get FCM token: $e');
      return null;
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    if (kIsWeb) return;

    try {
      final notification = message.notification;
      final android = message.notification?.android;
      final data = message.data;

      String title = notification?.title ?? '';
      String body = notification?.body ?? '';

      // If it's a data-only FCM message (no notification object)
      if (title.isEmpty) {
        if (data['type'] == 'payment_update' ||
            data['payment_status'] != null) {
          final status =
              (data['payment_status'] ?? 'paid').toString().toUpperCase();
          final amount = data['amount'] != null ? '₹${data['amount']}' : '';
          final userName =
              data['user_name'] != null ? ' for ${data['user_name']}' : '';
          title = 'Payment $status';
          body = 'Payment of $amount$userName has been confirmed.';
        } else if (data['title'] != null) {
          title = data['title'].toString();
          body = data['body']?.toString() ?? '';
        } else {
          title = 'Payment Update';
          body = 'Payment status updated: ${data['payment_status'] ?? ''}';
        }
      }

      final int id = message.messageId?.hashCode ??
          (DateTime.now().millisecondsSinceEpoch ~/ 1000);

      await _localNotifications.show(
        id,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: 'ic_notification',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
      print(
          '📢 [NotificationService] Local notification displayed successfully (id: $id, title: "$title")');
    } catch (e, stack) {
      print(
          '❌ [NotificationService] Error displaying local notification: $e\n$stack');
    }
  }

  /// Triggers a test notification locally on the device to verify permissions and system tray delivery
  Future<void> showTestLocalNotification() async {
    try {
      await _requestPermission();
      await _localNotifications.show(
        99999,
        '🔔 SuchiGo Notification Test',
        'Notification system is active and ready to receive real-time updates!',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: 'ic_notification',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: 'test_notification',
      );
      print(
          '✅ [NotificationService] Test notification fired successfully on device!');
    } catch (e, stack) {
      print(
          '❌ [NotificationService] Error showing test notification: $e\n$stack');
    }
  }
}
