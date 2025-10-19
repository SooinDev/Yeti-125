#!/bin/bash

echo "🧹 Flutter 프로젝트 완전 초기화 시작..."

# 1. Flutter clean
echo "📦 Flutter clean 실행 중..."
flutter clean

# 2. iOS 캐시 삭제
echo "🍎 iOS 캐시 삭제 중..."
cd ios
rm -rf Pods
rm -rf Podfile.lock
rm -rf .symlinks
rm -rf Flutter/Flutter.framework
rm -rf Flutter/Flutter.podspec
cd ..

# 3. 의존성 재설치
echo "📥 Flutter 의존성 설치 중..."
flutter pub get

# 4. Pod 재설치
echo "🔧 CocoaPods 재설치 중..."
cd ios
pod install
cd ..

echo "✅ 초기화 완료! 이제 flutter run을 실행하세요."
