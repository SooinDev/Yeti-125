import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';

// 백그라운드 메시지 핸들러 (top-level function이어야 함)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background message
}

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  /// FCM 초기화
  Future<void> initialize() async {
    try {
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized &&
          settings.authorizationStatus != AuthorizationStatus.provisional) {
        return;
      }

      _fcmToken = await _fcm.getToken();

      if (_fcmToken != null) {
        await _saveFCMTokenLocally(_fcmToken!);
        await _sendTokenToServer(_fcmToken!);
      }

      _fcm.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        _saveFCMTokenLocally(newToken);
        _sendTokenToServer(newToken);
      });

      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showForegroundNotification(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleNotificationClick(message);
      });

      RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationClick(initialMessage);
      }
    } catch (e) {
      // Silent fail
    }
  }

  /// FCM 토큰을 로컬에 저장
  Future<void> _saveFCMTokenLocally(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
  }

  /// FCM 토큰을 서버에 전송
  Future<void> _sendTokenToServer(String token) async {
    try {
      final url = '${AppConfig.baseUrl}/api/notifications/token';
      await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'fcmToken': token}),
      ).timeout(const Duration(seconds: 3));
    } catch (e) {
      // Silent fail - 서버 연결 실패 시 조용히 처리
    }
  }

  /// 포그라운드 알림 표시
  void _showForegroundNotification(RemoteMessage message) {
    // 실제로는 flutter_local_notifications 패키지를 사용해서 로컬 알림 표시
  }

  /// 알림 클릭 핸들러
  void _handleNotificationClick(RemoteMessage message) {
    final data = message.data;

    // 알림 타입에 따라 다른 화면으로 이동
    if (data['type'] == 'live_start') {
      // Navigator를 사용해서 홈 화면으로 이동
    } else if (data['type'] == 'new_replay') {
      // 다시보기 섹션으로 이동
    } else if (data['type'] == 'schedule') {
      // 일정 페이지로 이동
    }
  }

  /// 특정 토픽 구독
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _fcm.subscribeToTopic(topic);
    } catch (e) {
      // Silent fail
    }
  }

  /// 특정 토픽 구독 해제
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _fcm.unsubscribeFromTopic(topic);
    } catch (e) {
      // Silent fail
    }
  }

  /// 알림 설정에 따라 토픽 구독 관리
  Future<void> updateTopicSubscriptions({
    required bool liveStart,
    required bool liveEnd,
    required bool newReplay,
    required bool schedule,
  }) async {
    // 방송 시작 알림
    if (liveStart) {
      await subscribeToTopic('live_start');
    } else {
      await unsubscribeFromTopic('live_start');
    }

    // 방송 종료 알림
    if (liveEnd) {
      await subscribeToTopic('live_end');
    } else {
      await unsubscribeFromTopic('live_end');
    }

    // 새 다시보기 알림
    if (newReplay) {
      await subscribeToTopic('new_replay');
    } else {
      await unsubscribeFromTopic('new_replay');
    }

    // 일정 알림
    if (schedule) {
      await subscribeToTopic('schedule');
    } else {
      await unsubscribeFromTopic('schedule');
    }
  }
}
