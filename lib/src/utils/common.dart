import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pocket_ai/src/constants.dart';
import 'package:pocket_ai/src/globals.dart';
import 'package:pocket_ai/src/modules/chat/models/chat_message.dart';
import 'package:pocket_ai/src/modules/settings/models/app_settings.dart';
import 'package:pocket_ai/src/utils/analytics.dart';
import 'package:pocket_ai/src/utils/api_exception.dart';
import 'package:pocket_ai/src/widgets/custom_text.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

void showSnackBar(BuildContext context, {required String message}) {
  final scaffold = ScaffoldMessenger.of(context);
  scaffold.showSnackBar(
    SnackBar(
      content: CustomText(message),
      action: SnackBarAction(
          label: 'X',
          textColor: Colors.white,
          onPressed: scaffold.hideCurrentSnackBar),
    ),
  );
}

void logApiErrorAndShowMessage(BuildContext context,
    {required dynamic exception}) {
  if (exception is ApiException) {
    String message = exception.error.message ?? exception.message;
    if (message.isEmpty) {
      message =
          exception.error.code ?? exception.error.cause ?? 'Request failed';
    }
    showSnackBar(context, message: message);
  } else {
    if (kDebugMode) {
      print(exception);
    }
    showSnackBar(context, message: 'Something went wrong');
    FirebaseCrashlytics.instance.recordError(
        exception, StackTrace.fromString('logApiErrorAndShowMessage'));
  }
}

void logGenericError(error) {
  debugPrint('logGenericError: $error');
  FirebaseCrashlytics.instance
      .recordError(error, StackTrace.fromString('logGenericError'));
}

Future<String?> getDeviceId() async {
  var deviceInfo = DeviceInfoPlugin();
  if (kIsWeb) {
    return null;
  }
  if (Platform.isIOS) {
    var iosDeviceInfo = await deviceInfo.iosInfo;
    return iosDeviceInfo.identifierForVendor; // unique ID on iOS
  } else if (Platform.isAndroid) {
    // this is not unique, using android_id plugin for this
    /*var androidDeviceInfo = await deviceInfo.androidInfo;
    return androidDeviceInfo.id;*/ // unique ID on Android
    return await const AndroidId().getId();
  } else {
    return null;
  }
}

void resetToScreen(BuildContext context, String routeName) {
  Navigator.of(context).popAndPushNamed(routeName);
  logEvent(EventNames.navigation, {EventParams.routeName: routeName});
}

void navigateToScreen(BuildContext context, String routeName) {
  Navigator.pushNamed(context, routeName);
  logEvent(EventNames.navigation, {EventParams.routeName: routeName});
}

bool canGoBack(BuildContext context) {
  return Navigator.canPop(context);
}

void goBack(BuildContext context) {
  Navigator.of(context).pop();
}

String? encodeQueryParameters(Map<String, String> params) {
  return params.entries
      .map((MapEntry<String, String> e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
}

void showToastMessage(String message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM);
}

void saveAppSettingsToSharedPres(AppSettings appSettings) async {
  // Obtain shared preferences.
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(
      SharedPrefsKeys.maxTokensCount, appSettings.maxTokensCount);
  await prefs.setString(
      SharedPrefsKeys.openAiApiKey, appSettings.openAiApiKey ?? '');
  await prefs.setString(
      SharedPrefsKeys.aiForumUsername, appSettings.aiForumUsername ?? '');
}

Future<AppSettings> getAppSettingsFromSharedPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  return AppSettings(
    maxTokensCount: prefs.getInt(SharedPrefsKeys.maxTokensCount) ?? 1500,
    openAiApiKey: prefs.getString(SharedPrefsKeys.openAiApiKey),
    aiForumUsername: prefs.getString(SharedPrefsKeys.aiForumUsername),
  );
}

List<ChatMessage> getLastNMessagesFromChat(List<ChatMessage> chatMessages) {
  int lastMessagesCountForContext = 4;
  List<ChatMessage> lastNMessages = [];
  int messageStartIndex = chatMessages.length - lastMessagesCountForContext >= 0
      ? (chatMessages.length - lastMessagesCountForContext)
      : 0;
  for (int i = messageStartIndex; i < chatMessages.length; i++) {
    lastNMessages.add(chatMessages[i]);
  }
  return lastNMessages;
}

/// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
Color getColorFromHex(String? hexString, Color fallbackColor) {
  if (hexString == null || hexString == '') {
    return fallbackColor;
  }
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
  buffer.write(hexString.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

void savePromptsToFirestoreCollection(String prompt, String collection) {
  // store prompts to Firestore for study & analytics
  String? deviceId = Globals.deviceId;
  if (deviceId != null) {
    FirebaseFirestore.instance
        .collection(collection)
        .doc(deviceId)
        .collection(FirestoreCollectionsConst.prompts)
        .doc()
        .set({'prompt': prompt, 'time': FieldValue.serverTimestamp()});
  }
}

String getFormattedDate(DateTime dateTime) {
  List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  String monthName = months[dateTime.month - 1];
  return '${dateTime.day.toString().padLeft(2, '0')} $monthName, ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
}

String getFormattedTime(DateTime dateTime) {
  String hour = dateTime.hour.toString().padLeft(2, '0');
  String minute = dateTime.minute.toString().padLeft(2, '0');
  String period = dateTime.hour < 12 ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

bool isEmpty(String? value) {
  if (value == null || value == '') {
    return true;
  }
  return false;
}

void onRatePocketAiPressed() async {
  if (Platform.isAndroid || Platform.isIOS) {
    // todo support for ios
    final appId = Platform.isAndroid ? androidPackageName : 'YOUR_IOS_APP_ID';
    final url = Uri.parse(
      Platform.isAndroid
          ? "market://details?id=$appId"
          : "https://apps.apple.com/app/id$appId",
    );
    bool canLaunchIntent = await canLaunchUrl(url);
    if (canLaunchIntent) {
      launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } else {
      launchUrlString(
          'https://play.google.com/store/apps/details?id=$androidPackageName');
    }
  }
}

void onSharePocketAiPressed() async {
  try {
    Share.share(
        'Check out Pocket-AI, a Chat-GPT-3.5 powered AI assistant: https://play.google.com/store/apps/details?id=$androidPackageName');
  } catch (error) {
    logGenericError(error);
  }
}
