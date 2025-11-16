package com.foririon.project.controller;

import com.foririon.project.service.NotificationService;
import com.foririon.project.service.FCMService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/notifications")
public class NotificationController {

    @Autowired
    private NotificationService notificationService;

    @Autowired
    private FCMService fcmService;

    @PostMapping("/register")
    public ResponseEntity<Void> registerToken(@RequestBody Map<String, String> payload) {
        String token = payload.get("token");
        if (token != null && !token.isEmpty()) {
            notificationService.registerToken(token);
        }
        return ResponseEntity.ok().build();
    }

    @PostMapping("/token")
    public ResponseEntity<Map<String, String>> saveFCMToken(@RequestBody Map<String, String> payload) {
        String fcmToken = payload.get("fcmToken");

        if (fcmToken != null && !fcmToken.isEmpty()) {
            notificationService.registerToken(fcmToken);
        }

        Map<String, String> response = new HashMap<>();
        response.put("status", "success");
        response.put("message", "토큰이 저장되었습니다");
        return ResponseEntity.ok(response);
    }
}