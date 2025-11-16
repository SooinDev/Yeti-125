package com.foririon.project.service.impl;

import com.foririon.project.mapper.StreamMapper;
import com.foririon.project.service.StreamService;
import com.foririon.project.service.FCMService;
import com.foririon.project.vo.ChzzkApiResponseVO;
import com.foririon.project.vo.LiveStatusContentVO;
import com.foririon.project.vo.StreamVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.Date;

@Service
public class StreamServiceImpl implements StreamService {

    @Autowired
    private StreamMapper streamMapper;

    @Autowired
    private RestTemplate restTemplate;

    @Autowired
    private FCMService fcmService;

    @Value("${chzzk.channel.id}")
    private String channelId;

    private String lastLiveStatus = "CLOSE"; // 이전 방송 상태 저장

    @Override
    public LiveStatusContentVO getLiveStatus() {
        // 1. 라이브 상태 확인
        String statusUrl = "https://api.chzzk.naver.com/polling/v2/channels/" + channelId + "/live-status";

        try {
            ParameterizedTypeReference<ChzzkApiResponseVO<LiveStatusContentVO>> responseType =
                    new ParameterizedTypeReference<ChzzkApiResponseVO<LiveStatusContentVO>>() {};

            ResponseEntity<ChzzkApiResponseVO<LiveStatusContentVO>> responseEntity =
                    restTemplate.exchange(statusUrl, HttpMethod.GET, null, responseType);

            ChzzkApiResponseVO<LiveStatusContentVO> response = responseEntity.getBody();
            LiveStatusContentVO content = (response != null) ? response.getContent() : null;

            if (content != null) {
                content.setChannelId(channelId);

                // 방송 상태 변경 감지 및 알림 전송
                String currentStatus = content.getStatus();
                if (!currentStatus.equals(lastLiveStatus)) {
                    if ("OPEN".equals(currentStatus)) {
                        fcmService.sendToTopic("live_start", "이리온 방송 시작!", "지금 방송 중입니다 ❄️🌸", "live_start");
                    } else if ("CLOSE".equals(currentStatus) && "OPEN".equals(lastLiveStatus)) {
                        fcmService.sendToTopic("live_end", "방송이 종료되었습니다", "오늘도 함께해주셔서 감사합니다! 💙", "live_end");
                    }
                    lastLiveStatus = currentStatus;
                }

                // 2. OPEN 상태일 때만 썸네일 조회
                if ("OPEN".equals(content.getStatus())) {
                    try {
                        String liveDetailUrl = "https://api.chzzk.naver.com/service/v2/channels/" + channelId + "/live-detail";

                        // User-Agent 헤더 추가
                        org.springframework.http.HttpHeaders headers = new org.springframework.http.HttpHeaders();
                        headers.set("User-Agent", "Mozilla/5.0");
                        org.springframework.http.HttpEntity<?> entity = new org.springframework.http.HttpEntity<>(headers);

                        ResponseEntity<ChzzkApiResponseVO<LiveStatusContentVO>> detailResponse =
                                restTemplate.exchange(liveDetailUrl, HttpMethod.GET, entity, responseType);

                        ChzzkApiResponseVO<LiveStatusContentVO> detailData = detailResponse.getBody();
                        if (detailData != null && detailData.getContent() != null) {
                            String thumbnailUrl = detailData.getContent().getLiveImageUrl();
                            if (thumbnailUrl != null && !thumbnailUrl.isEmpty()) {
                                thumbnailUrl = thumbnailUrl.replace("{type}", "720");
                                content.setLiveImageUrl(thumbnailUrl);
                            }
                        }
                    } catch (Exception e) {
                        // Silent fail
                    }
                }
            }

            return content;
        } catch (Exception e) {
            return null;
        }
    }

    @Override
    public boolean isCurrentlyLive() {
        LiveStatusContentVO liveStatus = getLiveStatus();
        // liveStatus 객체 자체와 status 필드가 null인지 확인합니다.
        if (liveStatus == null || liveStatus.getStatus() == null) {
            return false;
        }
        return "OPEN".equals(liveStatus.getStatus());
    }

    @Override
    public boolean shouldSendNotification(String liveId) {
        StreamVO stream = streamMapper.findByLiveId(liveId);
        return stream == null || !stream.isNotificationSent();
    }

    @Override
    public void recordStreamStart(LiveStatusContentVO content) {
        if (content == null) return;
        StreamVO stream = new StreamVO();
        stream.setLiveId(content.getLiveId());
        stream.setTitle(content.getLiveTitle());
        stream.setStartTime(new Date());
        stream.setNotificationSent(false);
        streamMapper.insertStream(stream);
    }

    @Override
    public void markNotificationAsSent(String liveId) {
        streamMapper.updateNotificationSent(liveId);
    }
}