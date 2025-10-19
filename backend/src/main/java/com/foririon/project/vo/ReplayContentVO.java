package com.foririon.project.vo;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import java.util.List;

@JsonIgnoreProperties(ignoreUnknown = true)
public class ReplayContentVO {
  private List<ReplayVO> data;

  public List<ReplayVO> getData() { return data; }
  public void setData(List<ReplayVO> data) { this.data = data; }
}