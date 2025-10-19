package com.foririon.project.vo;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@JsonIgnoreProperties(ignoreUnknown = true)
public class ChannelVO {
  private String channelId;
  private String channelName;
  private String channelImageUrl;

  // Getters and Setters
  public String getChannelId() { return channelId; }
  public void setChannelId(String channelId) { this.channelId = channelId; }
  public String getChannelName() { return channelName; }
  public void setChannelName(String channelName) { this.channelName = channelName; }
  public String getChannelImageUrl() { return channelImageUrl; }
  public void setChannelImageUrl(String channelImageUrl) { this.channelImageUrl = channelImageUrl; }
}