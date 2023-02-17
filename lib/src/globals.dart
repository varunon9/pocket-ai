import 'package:pocket_ai/src/modules/settings/models/app_settings.dart';

class Globals {
  static String? deviceId;

  // this will be overridden in splash screen init
  static AppSettings appSettings = AppSettings(
      maxTokensCount: 150, openAiApiKey: null, gpt3Model: 'text-davinci-003');
}
