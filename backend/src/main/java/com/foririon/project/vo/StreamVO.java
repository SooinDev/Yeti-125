package com.foririon.project.vo;

import java.util.Date;

public class StreamVO {

  private Long id;
  private String liveId;
  private String title;
  private Date startTime;
  private Date endTime;
  private boolean notificationSent;
  private Date createdAt;

  public Long getId() {
    return id;
  }

  public void setId(Long id) {
    this.id = id;
  }

  public String getLiveId() {
    return liveId;
  }

  public void setLiveId(String liveId) {
    this.liveId = liveId;
  }

  public String getTitle() {
    return title;
  }

  public void setTitle(String title) {
    this.title = title;
  }

  public Date getStartTime() {
    return startTime;
  }

  public void setStartTime(Date startTime) {
    this.startTime = startTime;
  }

  public Date getEndTime() {
    return endTime;
  }

  public void setEndTime(Date endTime) {
    this.endTime = endTime;
  }

  public boolean isNotificationSent() {
    return notificationSent;
  }

  public void setNotificationSent(boolean notificationSent) {
    this.notificationSent = notificationSent;
  }

  public Date getCreatedAt() {
    return createdAt;
  }

  public void setCreatedAt(Date createdAt) {
    this.createdAt = createdAt;
  }
}
