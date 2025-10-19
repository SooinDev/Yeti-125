package com.foririon.project.mapper;

import com.foririon.project.vo.StreamVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface StreamMapper {
  StreamVO findByLiveId(@Param("liveId") String liveId);
  void insertStream(StreamVO stream);
  void updateNotificationSent(@Param("liveId") String liveId);
}