package com.foririon.project.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class HealthController {

  @GetMapping("/health")
  public Map<String, String> health() {
    Map<String, String> status = new HashMap<>();
    status.put("status", "UP");
    status.put("timestamp", String.valueOf(System.currentTimeMillis()));
    return status;
  }
}