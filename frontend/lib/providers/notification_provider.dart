import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/fcm_service.dart';

class NotificationProvider extends ChangeNotifier {
  bool _liveStartNotification = true;
  bool _liveEndNotification = false;
  bool _newReplayNotification = true;
  bool _scheduleNotification = true;

  bool get liveStartNotification => _liveStartNotification;
  bool get liveEndNotification => _liveEndNotification;
  bool get newReplayNotification => _newReplayNotification;
  bool get scheduleNotification => _scheduleNotification;

  NotificationProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _liveStartNotification = prefs.getBool('liveStartNotification') ?? true;
    _liveEndNotification = prefs.getBool('liveEndNotification') ?? false;
    _newReplayNotification = prefs.getBool('newReplayNotification') ?? true;
    _scheduleNotification = prefs.getBool('scheduleNotification') ?? true;
    notifyListeners();
  }

  Future<void> setLiveStartNotification(bool value) async {
    _liveStartNotification = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('liveStartNotification', value);
    await _updateFCMSubscriptions();
  }

  Future<void> setLiveEndNotification(bool value) async {
    _liveEndNotification = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('liveEndNotification', value);
    await _updateFCMSubscriptions();
  }

  Future<void> setNewReplayNotification(bool value) async {
    _newReplayNotification = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('newReplayNotification', value);
    await _updateFCMSubscriptions();
  }

  Future<void> setScheduleNotification(bool value) async {
    _scheduleNotification = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('scheduleNotification', value);
    await _updateFCMSubscriptions();
  }

  Future<void> _updateFCMSubscriptions() async {
    await FCMService().updateTopicSubscriptions(
      liveStart: _liveStartNotification,
      liveEnd: _liveEndNotification,
      newReplay: _newReplayNotification,
      schedule: _scheduleNotification,
    );
  }
}
