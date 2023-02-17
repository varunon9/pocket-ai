class AiBotConstants {
  static String introMessage =
      'Hi, I am pocket AI bot. How can I help you today?';
  static List<String> gptModels = [
    'text-davinci-003',
    'text-curie-001',
    'text-babbage-001',
    'text-ada-001',
  ];
}

class FirestoreCollectionsConst {
  static String faqs = 'faqs';
  static String userMessagesToBot = 'userMessagesToBot';
  static String messages = 'messages';
  static String openAiApiKeys = 'openAiApiKeys';
  static String userSessionsCount = 'userSessionsCount';
}

String androidPackageName = 'me.varunon9.pocket_ai';
