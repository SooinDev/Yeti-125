package com.foririon.project.vo;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

@JsonIgnoreProperties(ignoreUnknown = true)
public class ReplayVO {
  private String videoId;
  private Integer videoNo; // 실제 영상 번호
  private String videoTitle;

  private String thumbnailImageUrl; // API에서 받는 필드명
  private int readCount; // API에서 받는 필드명

  private ChannelVO channel;

  @JsonProperty("publishDate")
  private String publishDateAt; // API에서 받은 날짜

  // Flutter에서 필요한 필드 (계산해서 제공)
  @JsonProperty("clipId")
  public String getClipId() {
    return videoId;
  }

  @JsonProperty("title")
  public String getTitle() {
    return videoTitle;
  }

  @JsonProperty("videoUrl")
  public String getVideoUrl() {
    // videoNo가 있으면 videoNo 사용, 없으면 videoId 사용
    if (videoNo != null) {
      return "https://chzzk.naver.com/video/" + videoNo;
    }
    return "https://chzzk.naver.com/video/" + videoId;
  }

  @JsonProperty("createdAt")
  public String getCreatedAt() {
    return publishDateAt;
  }

  public String getVideoId() {
    return videoId;
  }

  public void setVideoId(String videoId) {
    this.videoId = videoId;
  }

  public String getVideoTitle() {
    return videoTitle;
  }

  public void setVideoTitle(String videoTitle) {
    this.videoTitle = videoTitle;
  }

  // Flutter에서 필요한 thumbnailUrl 필드
  @JsonProperty("thumbnailUrl")
  public String getThumbnailUrl() {
    return thumbnailImageUrl;
  }

  public void setThumbnailImageUrl(String thumbnailImageUrl) {
    this.thumbnailImageUrl = thumbnailImageUrl;
  }

  public String getThumbnailImageUrl() {
    return thumbnailImageUrl;
  }

  // Flutter에서 필요한 viewCount 필드
  @JsonProperty("viewCount")
  public int getViewCount() {
    return readCount;
  }

  public void setReadCount(int readCount) {
    this.readCount = readCount;
  }

  public int getReadCount() {
    return readCount;
  }

  public ChannelVO getChannel() {
    return channel;
  }

  public void setChannel(ChannelVO channel) {
    this.channel = channel;
  }

  public String getPublishDateAt() {
    return publishDateAt;
  }

  public void setPublishDateAt(String publishDateAt) {
    this.publishDateAt = publishDateAt;
  }

  public Integer getVideoNo() {
    return videoNo;
  }

  public void setVideoNo(Integer videoNo) {
    this.videoNo = videoNo;
  }
}