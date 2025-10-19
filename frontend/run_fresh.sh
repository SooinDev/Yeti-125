#!/bin/bash

# For Irion 앱을 완전히 새로 빌드하는 스크립트

echo "🧹 Flutter 정리 중..."
flutter clean

echo "📦 의존성 설치 중..."
flutter pub get

echo "🗑️  모든 시뮬레이터에서 앱 삭제 중..."
# 모든 부팅된 시뮬레이터에서 앱 삭제
xcrun simctl list devices | grep "Booted" | while read line; do
    device_id=$(echo "$line" | sed 's/.*(\([^)]*\)).*/\1/')
    echo "  - 삭제 중: $device_id"
    xcrun simctl uninstall "$device_id" com.example.forIrionFlutter 2>/dev/null || true
done

echo "✅ 준비 완료!"
echo ""
echo "이제 다음 명령어로 앱을 실행하세요:"
echo "  flutter run"
echo ""
echo "또는 특정 기기에서 실행:"
echo "  flutter run -d [device-id]"
