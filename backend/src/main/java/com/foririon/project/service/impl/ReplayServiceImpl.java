package com.foririon.project.service.impl;

import com.foririon.project.service.ReplayService;
import com.foririon.project.vo.ChzzkApiResponseVO;
import com.foririon.project.vo.ReplayContentVO;
import com.foririon.project.vo.ReplayVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.List;

@Service
public class ReplayServiceImpl implements ReplayService {

  @Autowired
  private RestTemplate restTemplate;

  @Value("${chzzk.channel.id}")
  private String channelId;

  @Override
  public List<ReplayVO> getReplays() {
    try {
      // Chzzk VOD API 호출
      String videoUrl = "https://api.chzzk.naver.com/service/v1/channels/" + channelId + "/videos?sortType=LATEST";

      // User-Agent 헤더 추가
      HttpHeaders headers = new HttpHeaders();
      headers.set("User-Agent", "Mozilla/5.0");
      HttpEntity<?> entity = new HttpEntity<>(headers);

      ParameterizedTypeReference<ChzzkApiResponseVO<ReplayContentVO>> responseType =
              new ParameterizedTypeReference<ChzzkApiResponseVO<ReplayContentVO>>() {};

      ResponseEntity<ChzzkApiResponseVO<ReplayContentVO>> responseEntity =
              restTemplate.exchange(videoUrl, HttpMethod.GET, entity, responseType);

      ChzzkApiResponseVO<ReplayContentVO> response = responseEntity.getBody();

      if (response != null && response.getContent() != null) {
        ReplayContentVO content = response.getContent();
        if (content.getData() != null) {
          return content.getData();
        }
      }

      return new ArrayList<>();
    } catch (Exception e) {
      // Silent fail
      return new ArrayList<>();
    }
  }
}
