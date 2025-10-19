package com.foririon.project.mapper;

import java.util.List;

public interface NotificationMapper {

  void insertToken(String fcmToken);

  List<String> getAllTokens();
}
