-- 기기 정보 테이블
CREATE TABLE devices (
                         id INT AUTO_INCREMENT PRIMARY KEY,
                         fcm_token VARCHAR(255) NOT NULL UNIQUE COMMENT 'FCM에서 발급하는 기기 고유 토큰',
                         is_active BOOLEAN DEFAULT TRUE COMMENT '알림 수신 활성 여부',
                         created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '토큰 등록일',
                         updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '마지막 업데이트일'
) COMMENT '알림을 수신할 기기 목록';

-- 방송 기록 테이블
CREATE TABLE streams (
                         id BIGINT AUTO_INCREMENT PRIMARY KEY,
                         live_id VARCHAR(255) NOT NULL UNIQUE COMMENT '치지직 API가 제공하는 방송 고유 ID',
                         title VARCHAR(255) COMMENT '방송 제목',
                         start_time DATETIME NOT NULL COMMENT '방송 시작 시간',
                         end_time DATETIME COMMENT '방송 종료 시간',
                         notification_sent BOOLEAN DEFAULT FALSE COMMENT '방송 시작 알림을 보냈는지 여부',
                         created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) COMMENT '방송 기록';

-- 방송 일정 테이블
CREATE TABLE stream_schedules (
                                  id INT AUTO_INCREMENT PRIMARY KEY,
                                  title VARCHAR(255) NOT NULL COMMENT '방송 예정 제목',
                                  scheduled_start_time DATETIME NOT NULL COMMENT '방송 예정 시작 시간',
                                  description TEXT COMMENT '방송 관련 상세 설명',
                                  is_cancelled BOOLEAN DEFAULT FALSE COMMENT '방송 취소 여부',
                                  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) COMMENT '방송 일정';