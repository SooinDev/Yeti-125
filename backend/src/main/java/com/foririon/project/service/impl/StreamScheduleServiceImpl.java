package com.foririon.project.service.impl;

import com.foririon.project.mapper.StreamScheduleMapper;
import com.foririon.project.service.StreamScheduleService;
import com.foririon.project.vo.StreamScheduleVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class StreamScheduleServiceImpl implements StreamScheduleService {

  @Autowired
  private StreamScheduleMapper streamScheduleMapper;

  @Override
  public List<StreamScheduleVO> getSchedules() {
    return streamScheduleMapper.findAllSchedules();
  }
}