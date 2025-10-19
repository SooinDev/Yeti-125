package com.foririon.project.service;

import com.foririon.project.vo.LiveStatusContentVO;
import java.util.List;

public interface StreamService {
  LiveStatusContentVO getLiveStatus(); // LiveStatusContentVO를 반환하도록 수정
  boolean isCurrentlyLive();
  boolean shouldSendNotification(String liveId);
  void recordStreamStart(LiveStatusContentVO content); // LiveStatusContentVO를 받도록 수정
  void markNotificationAsSent(String liveId);
}