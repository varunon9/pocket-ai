import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class EventNames {
  // Screen view events
  static String faqScreenViewed = 'faqScreenViewed';
  static String chatScreenViewed = 'chatScreenViewed';
  static String settingsScreenViewed = 'settingsScreenViewed';
  static String contentGeneratorScreenViewed = 'contentGeneratorScreenViewed';
  static String todosManagerScreenViewed = 'todosManagerScreenViewed';
  static String aiForumScreenViewed = 'aiForumScreenViewed';

  // CTA click events
  static String sendMessageClicked = 'sendMessageClicked';
  static String helpIconClicked = 'helpIconClicked';
  static String settingsIconClicked = 'settingsIconClicked';
  static String contentGeneratorIconClicked = 'contentGeneratorIconClicked';
  static String updateSettingsClicked = 'updateSettingsClicked';
  static String faqsClicked = 'faqsClicked';
  static String rateAppClicked = 'rateAppClicked';
  static String generateContentClicked = 'generateContentClicked';
  static String shareGeneratedContentClicked = 'shareGeneratedContentClicked';
  static String todosManagerIconClicked = 'todosManagerIconClicked';
  static String sendButtonInTodosManagerClicked =
      'sendButtonInTodosManagerClicked';
  static String resetChatWithBotClicked = 'resetChatWithBotClicked';
  static String sendAiForumMessageClicked = 'sendAiForumMessageClicked';
  static String pocketAiAdsClicked = 'pocketAiAdsClicked';
  static String freeSessionsInfoKnowMoreClicked =
      'freeSessionsInfoKnowMoreClicked';

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
  static String id = 'id';
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
