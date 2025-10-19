package com.foririon.project.controller;

import com.foririon.project.service.StreamService;
import com.foririon.project.vo.LiveStatusContentVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.CacheControl;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/stream")
public class StreamController {

  @Autowired
  private StreamService streamService;

  @GetMapping("/live-status")
  public ResponseEntity<LiveStatusContentVO> liveStatus() {
    return ResponseEntity.ok()
        .cacheControl(CacheControl.noCache().noStore())
        .header("Pragma", "no-cache")
        .body(streamService.getLiveStatus());
  }

  @GetMapping("/is-live")
  public boolean isCurrentlyLive() {
    return streamService.isCurrentlyLive();
  }
}