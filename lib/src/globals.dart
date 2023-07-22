import 'package:pocket_ai/src/modules/settings/models/app_settings.dart';

class Globals {
  static String? deviceId;

  // from Firestore when user has less than maxFreeSessions sessions
  static String? freeOpenAiApiKey;

  // this will be overridden in splash screen init
  static AppSettings appSettings = AppSettings(
      maxTokensCount: 1500, openAiApiKey: null, aiForumUsername: '- Pocket AI');

  static int maxFreeSessions = 10;
}
