# For Irion - Backend API Server

버츄얼 유튜버 이리온을 응원하기 위한 비상업적 팬 프로젝트 백엔드 서버입니다.

## 🛠️ 기술 스택

- **Framework**: Spring Framework + MyBatis
- **Database**: MySQL
- **API**: Chzzk Unofficial API
- **Build Tool**: Maven

## 🚀 시작하기

### 1. 프로젝트 클론

```bash
git clone https://github.com/YOUR_USERNAME/for-irion.git
cd for-irion
```

### 2. 설정 파일 생성

`src/main/resources/application.properties.example` 파일을 복사하여 `application.properties` 파일을 생성합니다.

```bash
cp src/main/resources/application.properties.example src/main/resources/application.properties
```

### 3. 채널 ID 설정

`application.properties` 파일을 열어서 치지직 채널 ID를 입력합니다.

```properties
chzzk.channel.id=YOUR_CHANNEL_ID_HERE
```

**채널 ID 찾는 방법:**
1. 치지직 채널 페이지 접속 (예: `https://chzzk.naver.com/live/XXXXXXXX`)
2. URL에서 `/live/` 또는 `/` 뒤의 문자열이 채널 ID입니다

### 4. 서버 실행

**IntelliJ IDEA / Eclipse:**
- Tomcat 서버 설정 후 실행

**Maven:**
```bash
mvn clean install
mvn tomcat7:run
```

## 📡 API 엔드포인트

### 방송 상태 확인
```
GET /api/stream/live-status
```

**응답 예시:**
```json
{
  "status": "OPEN",
  "liveImageUrl": "https://...",
  "channelId": "...",
  "concurrentUserCount": 1234
}
```

### 최근 30일 다시보기
```
GET /api/stream/hot-clips
```

**응답 예시:**
```json
[
  {
    "clipId": "...",
    "title": "방송 제목",
    "thumbnailUrl": "https://...",
    "videoUrl": "https://chzzk.naver.com/video/12345",
    "viewCount": 1000,
    "createdAt": "2024-01-01 12:00:00"
  }
]
```

### 방송 일정
```
GET /api/schedules
```

**응답 예시:**
```json
[
  {
    "title": "정기 방송",
    "scheduledStartTime": "2024-01-15T19:00:00",
    "description": "방송 설명"
  }
]
```

## ⚠️ 중요 사항

### GitHub에 올리면 안 되는 파일들

다음 파일들은 **절대 GitHub에 올리면 안 됩니다**:

- `src/main/resources/application.properties` (채널 ID 포함)
- `src/main/resources/jdbc.properties` (데이터베이스 정보)
- `.env` 파일들
- 로그 파일 (*.log)

이 파일들은 이미 `.gitignore`에 추가되어 있습니다.

### Git 커밋 전 확인

```bash
# 현재 추적되는 파일 확인
git status

# application.properties가 나타나면 안 됩니다!
# 만약 나타난다면:
git rm --cached src/main/resources/application.properties
```

## 🔒 보안

- 이 프로젝트는 치지직 비공식 API를 사용합니다
- 상업적 목적으로 사용하지 마세요
- API 사용량이 과도하면 차단될 수 있습니다
- 개인정보는 수집하지 않습니다

## 📝 라이선스

비상업적 팬 프로젝트입니다. 상업적 사용을 금지합니다.

## 👨‍💻 개발자

**SooinDev** - [alwayswithsound@gmail.com](mailto:alwayswithsound@gmail.com)

---

Made with ❄️ & 🌸 for Irion
