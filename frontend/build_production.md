# 프로덕션 빌드 가이드

## 앱스토어 배포 전 체크리스트

### 1. EC2 백엔드 서버 설정 확인

```bash
# 서버 접속 가능 여부 확인
curl http://3.107.86.196:8080/api/health

# 또는 HTTPS 설정 후
curl https://yourdomain.com/api/health
```

**필수 사항:**
- [ ] EC2 보안 그룹에서 포트 8080 (또는 443) 오픈
- [ ] 백엔드 서버 실행 중
- [ ] HTTPS 설정 완료 (권장)

### 2. 프론트엔드 환경 설정

`lib/main.dart` 파일에서 프로덕션 환경으로 변경:

```dart
// 프로덕션 환경 설정
AppConfig.setEnvironment(Environment.production);
```

`lib/config/app_config.dart`에서 프로덕션 URL 확인:

```dart
case Environment.production:
  return 'https://yourdomain.com';  // 또는 http://3.107.86.196:8080
```

### 3. iOS 프로덕션 빌드

```bash
# 빌드 전 클린
flutter clean
flutter pub get

# iOS 프로덕션 빌드
flutter build ios --release

# Xcode에서 아카이브
open ios/Runner.xcworkspace
```

**Xcode에서:**
1. Product → Scheme → Edit Scheme → Run → Release 선택
2. Product → Archive
3. Window → Organizer → Distribute App

### 4. 앱스토어 제출 전 확인사항

- [ ] Bundle ID 설정 (`ios/Runner.xcodeproj`)
- [ ] 앱 아이콘 설정 완료
- [ ] 프라이버시 정책 URL (필요시)
- [ ] 앱 설명 및 스크린샷 준비
- [ ] TestFlight 베타 테스트 (권장)

### 5. HTTPS 미설정 시 주의사항

HTTP를 사용하는 경우 `Info.plist`에 다음이 있어야 함:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

⚠️ **주의:** 앱스토어 심사에서 HTTP 사용 이유를 물어볼 수 있습니다.

## 트러블슈팅

### 백엔드 연결 안 됨
1. EC2 보안 그룹 확인
2. 서버 실행 상태 확인
3. 네트워크 방화벽 확인

### 빌드 에러
```bash
flutter clean
rm -rf ios/Pods ios/Podfile.lock
cd ios && pod install && cd ..
flutter build ios --release
```

### FCM 푸시 알림 설정
- APNs 인증서 설정 필요
- Firebase Console에서 APNs 키 등록
