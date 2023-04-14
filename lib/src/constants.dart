class AiBotConstants {
  static String introMessage =
      'Hi, I am pocket AI bot. How can I help you today?';
  static String introMessageForContentGenerator =
      'Generate quote/poem/thoughts or any content and share with world. Copy and paste below example prompt to get started.';
  static String contentGeneratorSamplePrompt =
      "Generate a quote in Hindi based on following emotions- love, life, dream. Translation is not required.";
}

class FirestoreCollectionsConst {
  static String faqs = 'faqs';
  static String userMessagesToBot = 'userMessagesToBot';
  static String messages = 'messages';
  static String openAiApiKeys = 'openAiApiKeys';
  static String userSessionsCount = 'userSessionsCount';
  static String contentGeneratorPrompts = 'contentGeneratorPrompts';
  static String prompts = 'prompts';
}

String androidPackageName = 'me.varunon9.pocket_ai';

class SharedPrefsKeys {
  static String maxTokensCount = 'maxTokensCount';
  static String openAiApiKey = 'openAiApiKey';
  static String generatedContentSignature = 'generatedContentSignature';
}
