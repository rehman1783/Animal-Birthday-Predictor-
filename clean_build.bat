@echo off
echo Terminating lingering Dart and Flutter processes...
taskkill /F /IM dart.exe >nul 2>&1
taskkill /F /IM flutter.bat >nul 2>&1

echo Removing locked build directories...
rmdir /s /q build >nul 2>&1
rmdir /s /q .dart_tool >nul 2>&1
rmdir /s /q windows\flutter\ephemeral >nul 2>&1

echo Fetching dependencies...
call flutter pub get

echo Done! You can now run "flutter run -d chrome" or launch from your IDE.
