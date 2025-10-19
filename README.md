# For-Irion 프로젝트

이리온 스트리머를 위한 팬 앱 (Flutter + Spring + MyBatis)

## 주요 기능

- 📺 실시간 방송 상태 확인 (치지직 API 연동)
- 🔔 방송 시작/종료 알림 (FCM)
- 🎬 다시보기 목록
- 🌓 다크모드 지원
- ⚙️ 알림 설정

## 프로젝트 구조

```
For-Irion/
├── frontend/          # Flutter 앱
│   ├── lib/
│   │   ├── pages/    # UI 페이지
│   │   ├── services/ # API & FCM 서비스
│   │   ├── providers/# 상태 관리
│   │   └── main.dart
│   └── pubspec.yaml
│
└── backend/           # Spring API
    ├── src/main/java/com/foririon/project/
    │   ├── controller/
    │   ├── service/
    │   ├── vo/
    │   └── config/
    └── pom.xml
```

## 개발 환경 설정

### 1. Backend (Spring + MyBatis)

#### 필요 조건
- Java 8+
- Maven
- Firebase Admin SDK 서비스 계정 키

#### 설정 방법

1. `application.properties` 파일 생성:
   ```bash
   cd backend/src/main/resources
   cp application.properties.example application.properties
   ```

2. `application.properties` 수정:
   - `chzzk.channel.id`: 치지직 채널 ID 입력

3. Firebase 설정:
   - [FIREBASE_SETUP.md](backend/FIREBASE_SETUP.md) 참고
   - 서비스 계정 키를 `src/main/resources/firebase-service-account.json`에 저장

4. 서버 실행:
   ```bash
   cd backend
   mvn clean install
   mvn tomcat7:run
   # 또는 WAR 파일을 생성하여 톰캣에 배포
   ```

### 2. Frontend (Flutter)

#### 필요 조건
- Flutter SDK 3.0+
- Dart 3.0+

#### 설정 방법

1. 의존성 설치:
   ```bash
   cd frontend
   flutter pub get
   ```

2. Firebase 설정:
   - [FIREBASE_SETUP.md](backend/FIREBASE_SETUP.md) 참고
   - `google-services.json` (Android)
   - `GoogleService-Info.plist` (iOS)

3. 로컬 설정 파일 생성 (선택사항):
   ```bash
   cd lib/config
   cp local_config.example.dart local_config.dart
   ```

4. 앱 실행:
   ```bash
   flutter run
   ```

## API 엔드포인트

### 방송 상태
- `GET /api/stream/status` - 현재 방송 상태 조회

### 다시보기
- `GET /api/replays` - 다시보기 목록 조회

### 알림
- `POST /api/notifications/token` - FCM 토큰 등록
- `POST /api/notifications/send` - 토픽으로 알림 전송
- `POST /api/notifications/send-to-device` - 개별 기기로 알림 전송

## 알림 시스템

### 주제(Topic) 종류
- `live_start` - 방송 시작
- `live_end` - 방송 종료
- `new_replay` - 새 다시보기
- `schedule` - 일정 알림

### 자동 알림
- 방송 상태를 1분마다 자동 확인
- 방송 시작/종료 시 자동으로 알림 전송

## 보안 주의사항

다음 파일들은 **절대 Git에 커밋하지 마세요**:

### Backend
- `src/main/resources/application.properties`
- `src/main/resources/firebase-service-account.json`

### Frontend
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `lib/config/local_config.dart`

이 파일들은 이미 `.gitignore`에 포함되어 있습니다.

## 기술 스택

### Frontend
- Flutter 3.x
- Provider (상태 관리)
- Firebase Messaging
- Shared Preferences

### Backend
- Spring Framework
- MyBatis
- Firebase Admin SDK
- RestTemplate (치지직 API 호출)

## 라이선스

MIT License

## 기여

이슈 및 PR은 언제나 환영합니다!
