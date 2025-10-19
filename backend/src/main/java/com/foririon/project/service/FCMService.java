package com.foririon.project.service;

public interface FCMService {
    void sendToTopic(String topic, String title, String body, String type);
    void sendToToken(String token, String title, String body, String type);
}
