package com.foririon.project.scheduler;

import com.foririon.project.service.NotificationService;
import com.foririon.project.service.StreamService;
import com.foririon.project.vo.LiveStatusContentVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class StreamCheckScheduler {

  private final StreamService streamService;
  private final NotificationService notificationService;

  @Autowired
  public StreamCheckScheduler(StreamService streamService, NotificationService notificationService) {
    this.streamService = streamService;
    this.notificationService = notificationService;
  }

  @Scheduled(cron = "0 * * * * ?")
  public void checkLiveStatus() {
    LiveStatusContentVO status = streamService.getLiveStatus();

    if (status == null) {
      return;
    }

    boolean isLive = "OPEN".equals(status.getStatus());
    String liveId = status.getLiveId();

    if (isLive && liveId != null) {
      if (streamService.shouldSendNotification(liveId)) {
        streamService.recordStreamStart(status);

        String title = "이리온 방송 시작!";
        String body = status.getLiveTitle();
        notificationService.sendNotification(title, body);

        streamService.markNotificationAsSent(liveId);
      }
    }
  }
}