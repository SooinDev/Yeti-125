#!/bin/bash
cd "/Users/user/Desktop/Studio/Flutter/For-Irion/frontend/ios/Runner/Assets.xcassets/AppIcon.appiconset"
rm -f Icon-*.png
cp ~/Downloads/AppIcons/appstore.png source.png

sips -z 20 20 source.png --out Icon-App-20x20@1x.png
sips -z 40 40 source.png --out Icon-App-20x20@2x.png
sips -z 60 60 source.png --out Icon-App-20x20@3x.png
sips -z 29 29 source.png --out Icon-App-29x29@1x.png
sips -z 58 58 source.png --out Icon-App-29x29@2x.png
sips -z 87 87 source.png --out Icon-App-29x29@3x.png
sips -z 40 40 source.png --out Icon-App-40x40@1x.png
sips -z 80 80 source.png --out Icon-App-40x40@2x.png
sips -z 120 120 source.png --out Icon-App-40x40@3x.png
sips -z 120 120 source.png --out Icon-App-60x60@2x.png
sips -z 180 180 source.png --out Icon-App-60x60@3x.png
sips -z 76 76 source.png --out Icon-App-76x76@1x.png
sips -z 152 152 source.png --out Icon-App-76x76@2x.png
sips -z 167 167 source.png --out Icon-App-83.5x83.5@2x.png
sips -z 1024 1024 source.png --out Icon-App-1024x1024@1x.png

rm source.png
echo "Icons generated successfully!"
ls -la | grep Icon
