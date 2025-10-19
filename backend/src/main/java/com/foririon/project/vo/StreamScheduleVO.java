package com.foririon.project.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import java.util.Date;

public class StreamScheduleVO {

  private int id;
  private String title;

  @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX", timezone = "Asia/Seoul")
  private Date scheduledStartTime;

  private String description;
  private boolean isCancelled;

  @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX", timezone = "Asia/Seoul")
  private Date createdAt;

  public int getId() { return id; }
  public void setId(int id) { this.id = id; }
  public String getTitle() { return title; }
  public void setTitle(String title) { this.title = title; }
  public Date getScheduledStartTime() { return scheduledStartTime; }
  public void setScheduledStartTime(Date scheduledStartTime) { this.scheduledStartTime = scheduledStartTime; }
  public String getDescription() { return description; }
  public void setDescription(String description) { this.description = description; }
  public boolean isCancelled() { return isCancelled; }
  public void setCancelled(boolean cancelled) { this.isCancelled = cancelled; } // isCancelled의 Setter 수정
  public Date getCreatedAt() { return createdAt; }
  public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
}