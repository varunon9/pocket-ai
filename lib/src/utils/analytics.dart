import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class EventNames {
  // Screen view events
  static String faqScreenViewed = 'faqScreenViewed';

  // CTA click events
  static String ctaClicked = 'ctaClicked';

  // API action events
  static String openAiResponseSuccess = 'openAiResponseSuccess';
  static String openAiResponseFailed = 'openAiResponseFailed';

  // Misc events
  static String navigation = 'navigation';
}

class EventParams {
  static String routeName = 'routeName';
  static String ctaName = 'ctaName';
  static String userMessage = 'userMessage';
}

// https://pub.dev/packages/firebase_analytics/example
void logEvent(String eventName, Map<String, Object> params) {
  debugPrint(eventName);
  debugPrint(params.toString());
  if (eventName == EventNames.navigation) {
    FirebaseAnalytics.instance.setCurrentScreen(screenName: eventName);
  }
  FirebaseAnalytics.instance.logEvent(name: eventName, parameters: params);
}
