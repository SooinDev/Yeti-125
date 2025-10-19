# For Irion - Flutter 앱

이리온 팬을 위한 Flutter 앱입니다.

## 개발 환경 설정

### 1. 프로젝트 클론

```bash
git clone <repository-url>
cd frontend
```

### 2. Flutter 패키지 설치

```bash
flutter pub get
```

### 3. 로컬 개발 설정

iOS 시뮬레이터에서 개발할 때는 로컬 서버 IP 설정이 필요합니다.

```bash
# local_config.dart.example을 복사
cp lib/config/local_config.dart.example lib/config/local_config.dart
```

`lib/config/local_config.dart` 파일을 열고 맥의 IP 주소로 수정:

```dart
static const String localServerIp = '192.168.x.x'; // 여기에 자신의 IP 입력
```

**맥 IP 주소 확인 방법:**

```bash
ipconfig getifaddr en0
```

### 4. 백엔드 서버 실행

로컬 개발을 위해서는 백엔드 서버가 8080 포트에서 실행 중이어야 합니다.

### 5. 앱 실행

```bash
flutter run
```

## 프로덕션 빌드

프로덕션 환경으로 빌드하려면 `lib/main.dart`에서 환경을 변경:

```dart
AppConfig.setEnvironment(Environment.production);
```

## 파일 구조

```
lib/
├── config/
│   ├── app_config.dart           # 앱 환경 설정
│   ├── local_config.dart         # 로컬 개발 설정 (gitignore)
│   └── local_config.dart.example # 로컬 설정 예제
├── services/
│   ├── fcm_service.dart          # Firebase Cloud Messaging
│   └── ...
├── pages/                         # 화면들
├── widgets/                       # 위젯들
└── main.dart                      # 앱 진입점
```

## 주의사항

- `lib/config/local_config.dart`는 GitHub에 올라가지 않습니다 (.gitignore에 포함)
- Firebase 설정은 `lib/firebase_options.dart`에 있으며 공개 키만 포함합니다
- 민감한 정보는 절대 커밋하지 마세요

## 기술 스택

- Flutter
- Firebase (FCM)
- Provider (상태 관리)
- HTTP 통신

## 라이센스

MIT
