# Firebase 설정 가이드

## 1. Firebase 프로젝트 생성

1. [Firebase Console](https://console.firebase.google.com/)에 접속
2. "프로젝트 추가" 클릭
3. 프로젝트 이름 입력 (예: for-irion)
4. Google Analytics 설정 (선택사항)

## 2. Firebase Admin SDK 서비스 계정 키 발급

1. Firebase Console에서 프로젝트 선택
2. 좌측 메뉴에서 **프로젝트 설정** (⚙️) 클릭
3. **서비스 계정** 탭 선택
4. **새 비공개 키 생성** 버튼 클릭
5. JSON 파일 다운로드

## 3. 서비스 계정 키 배치

다운로드한 JSON 파일을 다음 위치에 저장:

```
backend/src/main/resources/firebase-service-account.json
```

**중요:** 이 파일은 절대 Git에 커밋하지 마세요! (.gitignore에 이미 포함되어 있습니다)

## 4. Firebase Cloud Messaging (FCM) 설정

### Android 설정

1. Firebase Console에서 **Android 앱 추가**
2. 패키지 이름 입력: `com.foririon.project`
3. `google-services.json` 파일 다운로드
4. 파일을 `frontend/android/app/` 폴더에 저장

### iOS 설정

1. Firebase Console에서 **iOS 앱 추가**
2. 번들 ID 입력: `com.foririon.project`
3. `GoogleService-Info.plist` 파일 다운로드
4. 파일을 `frontend/ios/Runner/` 폴더에 저장

## 5. 알림 주제(Topic) 설정

앱에서 사용하는 주제:
- `live_start` - 방송 시작 알림
- `live_end` - 방송 종료 알림
- `new_replay` - 새 다시보기 알림
- `schedule` - 일정 알림

주제는 자동으로 생성되므로 별도 설정이 필요 없습니다.

## 6. 테스트

백엔드 서버 실행 후 다음 API로 테스트 가능:

```bash
# 토픽으로 알림 전송
curl -X POST http://localhost:8080/api/notifications/send \
  -H "Content-Type: application/json" \
  -d '{
    "topic": "live_start",
    "title": "테스트 알림",
    "body": "알림 테스트입니다",
    "type": "live_start"
  }'
```

## 문제 해결

### "Failed to initialize Firebase" 에러
- `firebase-service-account.json` 파일 경로 확인
- JSON 파일 형식이 올바른지 확인

### 알림이 오지 않는 경우
- FCM 토큰이 제대로 등록되었는지 확인
- 앱이 주제를 구독했는지 확인
- Firebase Console의 Cloud Messaging 사용 설정 확인
