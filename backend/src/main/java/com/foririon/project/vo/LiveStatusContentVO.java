package com.foririon.project.vo;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

@JsonIgnoreProperties(ignoreUnknown = true)
public class LiveStatusContentVO {
  private String liveId;
  private String liveTitle;
  private String status;
  private int concurrentUserCount;
  private String openDate;
  private String liveImageUrl;

  @JsonProperty(access = JsonProperty.Access.READ_ONLY)
  private String channelId;

  public String getLiveId() {
    return liveId;
  }

  public void setLiveId(String liveId) {
    this.liveId = liveId;
  }

  public String getLiveTitle() {
    return liveTitle;
  }

  public void setLiveTitle(String liveTitle) {
    this.liveTitle = liveTitle;
  }

  public String getStatus() {
    return status;
  }

  public void setStatus(String status) {
    this.status = status;
  }

  public int getConcurrentUserCount() {
    return concurrentUserCount;
  }

  public void setConcurrentUserCount(int concurrentUserCount) {
    this.concurrentUserCount = concurrentUserCount;
  }

  public String getOpenDate() {
    return openDate;
  }

  public void setOpenDate(String openDate) {
    this.openDate = openDate;
  }

  @JsonProperty("liveImageUrl")
  public String getLiveImageUrl() {
    // API에서 liveImageUrl이 없으면 channelId로 썸네일 URL 생성
    if (liveImageUrl != null && !liveImageUrl.isEmpty()) {
      return liveImageUrl;
    }
    if (channelId != null && !channelId.isEmpty()) {
      return "https://livecloud-thumb.akamaized.net/chzzk/" + channelId + "_720.jpg";
    }
    return null;
  }

  public void setLiveImageUrl(String liveImageUrl) {
    this.liveImageUrl = liveImageUrl;
  }

  public String getChannelId() {
    return channelId;
  }

  public void setChannelId(String channelId) {
    this.channelId = channelId;
  }
}