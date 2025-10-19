package com.foririon.project.service.impl;

import com.foririon.project.mapper.NotificationMapper;
import com.foririon.project.service.NotificationService;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class NotificationServiceImpl implements NotificationService {

  @Autowired
  private NotificationMapper notificationMapper;

  @Override
  @Transactional
  public void registerToken(String fcmToken) {
    notificationMapper.insertToken(fcmToken);
  }

  public void sendNotification(String title, String body) {
    String topic = "live_start";

    Message message = Message.builder()
            .setNotification(Notification.builder()
                    .setTitle(title)
                    .setBody(body)
                    .build())
            .setTopic(topic)
            .build();

    try {
      FirebaseMessaging.getInstance().send(message);
    } catch (Exception e) {
      // Silent fail
    }
  }
}