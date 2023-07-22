import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:pocket_ai/src/globals.dart';
import 'package:pocket_ai/src/modules/chat/screens/chat_screen.dart';
import 'package:pocket_ai/src/utils/common.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const routeName = '/splash';

  @override
  State<SplashScreen> createState() => _SplashScreen();
}

class _SplashScreen extends State<SplashScreen> {
  Future<String> init() async {
    String? deviceId = await getDeviceId();
    Globals.deviceId = deviceId;
    Globals.appSettings = await getAppSettingsFromSharedPrefs();

    if (deviceId != null) {
      FirebaseCrashlytics.instance.setUserIdentifier(deviceId);
      FirebaseAnalytics.instance.setUserId(id: deviceId);
      debugPrint(Globals.deviceId);
    }

    return ChatScreen.routeName;
  }

  @override
  void initState() {
    super.initState();
    init().then((redirectRoute) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        resetToScreen(context, redirectRoute);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
