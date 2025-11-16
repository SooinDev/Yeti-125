package com.foririon.project.controller;

import com.foririon.project.service.ReplayService;
import com.foririon.project.vo.ReplayVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/stream")
public class ReplayController {

    @Autowired
    private ReplayService replayService;

    @GetMapping("/replays")
    public List<ReplayVO> getReplays() {
        return replayService.getReplays();
    }
}
