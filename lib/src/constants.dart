class AiBotConstants {
  static String introMessage =
      'Hi, I am Pocket AI bot. How can I help you today?';
  static String introMessageForContentGenerator =
      'Hello, I am Pocket AI bot. I can generate any type of content for you e.g. quote/poem/essay/story etc, which you can share with the world.';
  static String introMessageForTodosManager =
      'Hello, I am Pocket AI bot. I will help you in managing your todos. Tell me about your tasks.';
}

class FirestoreCollectionsConst {
  static String faqs = 'faqs';
  static String userMessagesToBot = 'userMessagesToBot';
  static String messages = 'messages';
  static String openAiApiKeys = 'openAiApiKeys';
  static String userSessionsCount = 'userSessionsCount';
  static String contentGeneratorPrompts = 'contentGeneratorPrompts';
  static String prompts = 'prompts';
  static String todosManagerPrompts = 'todosManagerPrompts';
  static String aiForumMessages = 'aiForumMessages';
  static String pocketAiAds = 'pocketAiAds';
}

String androidPackageName = 'me.varunon9.pocket_ai';

class SharedPrefsKeys {
  static String maxTokensCount = 'maxTokensCount';
  static String openAiApiKey = 'openAiApiKey';
  static String aiForumUsername = 'aiForumUsername';
}
