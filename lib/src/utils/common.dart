import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pocket_ai/src/utils/analytics.dart';
import 'package:pocket_ai/src/utils/api_exception.dart';
import 'package:pocket_ai/src/widgets/custom_text.dart';

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
    showSnackBar(context, message: message);
  } else {
    if (kDebugMode) {
      print(exception);
    }
    showSnackBar(context, message: 'Something went wrong');
    /*FirebaseCrashlytics.instance.recordError(
        exception, StackTrace.fromString('logApiErrorAndShowMessage'));*/
  }
}

void logGenericError(error) {
  debugPrint('logGenericError: $error');
  /*FirebaseCrashlytics.instance
      .recordError(error, StackTrace.fromString('logGenericError'));*/
}

Future<String?> getDeviceId() async {
  var deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    var iosDeviceInfo = await deviceInfo.iosInfo;
    return iosDeviceInfo.identifierForVendor; // unique ID on iOS
  } else if (Platform.isAndroid) {
    var androidDeviceInfo = await deviceInfo.androidInfo;
    return androidDeviceInfo.id; // unique ID on Android
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
