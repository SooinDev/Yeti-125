package com.foririon.project.mapper;

import com.foririon.project.vo.StreamScheduleVO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface StreamScheduleMapper {
  List<StreamScheduleVO> findAllSchedules();
}