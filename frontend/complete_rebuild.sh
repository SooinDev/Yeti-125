#!/bin/bash

echo "🔥 완전 초기화 및 실행 시작..."
echo ""

echo "1️⃣ Flutter clean"
flutter clean

echo ""
echo "2️⃣ iOS Pods 삭제"
cd ios
rm -rf Pods Podfile.lock
cd ..

echo ""
echo "3️⃣ Flutter pub get"
flutter pub get

echo ""
echo "4️⃣ Pod install"
cd ios
pod install
cd ..

echo ""
echo "5️⃣ 시뮬레이터에서 기존 앱 삭제"
xcrun simctl list devices | grep "Booted" | awk -F'[()]' '{print $2}' | while read device_id; do
    echo "  - 디바이스에서 앱 삭제: $device_id"
    xcrun simctl uninstall "$device_id" com.example.forIrionFlutter 2>/dev/null || true
done

echo ""
echo "✅ 완료! 이제 flutter run 실행..."
echo ""
flutter run
