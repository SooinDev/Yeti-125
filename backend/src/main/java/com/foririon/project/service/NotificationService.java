package com.foririon.project.service;

public interface NotificationService {

  void registerToken(String fcmToken);

  void sendNotification(String title, String body);

}
