import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:pocket_ai/firebase_options.dart';
import 'package:pocket_ai/src/constants.dart';
import 'package:pocket_ai/src/globals.dart';
import 'package:pocket_ai/src/modules/ai_forum/screens/ai_forum_screen.dart';
import 'package:pocket_ai/src/modules/chat/screens/chat_screen.dart';
import 'package:pocket_ai/src/modules/faqs/screens/faqs_screen.dart';
import 'package:pocket_ai/src/modules/content_generator/screens/content_generator_screen.dart';
import 'package:pocket_ai/src/modules/settings/screens/settings_screen.dart';
import 'package:pocket_ai/src/modules/splash/screens/splash_screen.dart';
import 'package:pocket_ai/src/modules/todos_manager/todos_manager_screen.dart';
import 'package:pocket_ai/src/widgets/custom_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  /*PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };*/

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyApp();
}

class _MyApp extends State<MyApp> with WidgetsBindingObserver {
  // This widget is the root of your application.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    FirebaseFirestore db = FirebaseFirestore.instance;
    if (state == AppLifecycleState.resumed) {
      // user can be marked online (populating Globals field here instead of splash screen would be required)
      // currently being taken care in chat_screen
    } else {
      // mark user as offline
      DocumentReference<Map<String, dynamic>> documentRef = db
          .collection(FirestoreCollectionsConst.userSessionsCount)
          .doc(Globals.deviceId);
      documentRef
          .update({'lastSeen': FieldValue.serverTimestamp(), 'online': false});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pocket AI',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: CustomColors.primary,
          secondary: CustomColors.secondary,
        ),
      ),
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (context) => const SplashScreen(),
        ChatScreen.routeName: (context) => const ChatScreen(),
        FaqsScreen.routeName: (context) => const FaqsScreen(),
        SettingsScreen.routeName: (context) => const SettingsScreen(),
        ContentGeneratorScreen.routeName: (context) =>
            const ContentGeneratorScreen(),
        TodosManagerScreen.routeName: (context) => const TodosManagerScreen(),
        AiForumScreen.routeName: (context) => const AiForumScreen(),
      },
    );
  }
}
