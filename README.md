# pocket_ai

OpenAI GPT-3 powered Free Chat Bot

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Useful commands

Flutter setup: https://docs.flutter.dev/get-started/install/macos

1. To create a new flutter app `flutter create my_app`
2. To check missing dependencies `flutter doctor -v`
3. List emulators `$ANDROID_HOME/emulator/emulator -list-avds`
4. Start an emulator `$ANDROID_HOME/emulator/emulator @1536_1024_device`
5. Check if devices are runnning `flutter devices`
6. Run app `flutter run`
7. To install any package `flutter pub add <package_name>` or `flutter pub add -d change_app_package_name`
8. Run in release mode `flutter run --release`
9. Build release apk `flutter build apk`
10. Generate upload key in android/app `keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload -storetype JKS`
11. Check fingerprint `keytool -list -v -keystore ./android/app/upload-keystore.jks -alias upload`
12. Change package name `flutter pub run change_app_package_name:main in.giftwallet.business`
13. Update launcher icon `flutter pub run flutter_launcher_icons:main`
14. Build releas bundle `flutter build appbundle`