cd ./macos
echo "\x1b[34;1m1/3: Flutter build...\x1b[0m"
flutter build macos

echo "\x1b[34;1m2/3: XCode build...\x1b[0m"
cd ./macos
xcodebuild -quiet -workspace Runner.xcworkspace -scheme Runner archive -archivePath "Runner.xcarchive"

echo "\x1b[34;1m3/3: packaging to ./dist ...\x1b[0m"
xcodebuild \
  -archivePath Runner.xcarchive \
  -exportArchive -exportPath '../dist'\
  -exportOptionsPlist exportOptions.plist

echo "\x1b[32;1mDone! opening directory\x1b[0m"
cd ..
open ./dist