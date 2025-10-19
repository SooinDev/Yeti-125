package com.foririon.project.controller;

import com.foririon.project.service.StreamScheduleService;
import com.foririon.project.vo.StreamScheduleVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/schedules")
public class StreamScheduleController {

  @Autowired
  private StreamScheduleService streamScheduleService;

  @GetMapping
  public List<StreamScheduleVO> getAllSchedules() {
    return streamScheduleService.getSchedules();
  }
}