package com.foririon.project.vo;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@JsonIgnoreProperties(ignoreUnknown = true)
public class ChzzkApiResponseVO<T> {
  private T content;

  public T getContent() { return content; }
  public void setContent(T content) { this.content = content; }
}