package com.foririon.project.service.impl;

import com.foririon.project.service.FCMService;
import com.google.firebase.messaging.*;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Service
public class FCMServiceImpl implements FCMService {

    @Override
    public void sendToTopic(String topic, String title, String body, String type) {
        try {
            // 데이터 페이로드 구성
            Map<String, String> data = new HashMap<>();
            data.put("type", type);
            data.put("click_action", "FLUTTER_NOTIFICATION_CLICK");

            // 알림 메시지 구성
            Notification notification = Notification.builder()
                    .setTitle(title)
                    .setBody(body)
                    .build();

            // 메시지 구성
            Message message = Message.builder()
                    .setNotification(notification)
                    .putAllData(data)
                    .setTopic(topic)
                    .build();

            // 메시지 전송
            FirebaseMessaging.getInstance().send(message);

        } catch (Exception e) {
            // Silent fail
        }
    }

    @Override
    public void sendToToken(String token, String title, String body, String type) {
        try {
            // 데이터 페이로드 구성
            Map<String, String> data = new HashMap<>();
            data.put("type", type);
            data.put("click_action", "FLUTTER_NOTIFICATION_CLICK");

            // 알림 메시지 구성
            Notification notification = Notification.builder()
                    .setTitle(title)
                    .setBody(body)
                    .build();

            // 메시지 구성
            Message message = Message.builder()
                    .setNotification(notification)
                    .putAllData(data)
                    .setToken(token)
                    .build();

            // 메시지 전송
            FirebaseMessaging.getInstance().send(message);

        } catch (Exception e) {
            // Silent fail
        }
    }
}
