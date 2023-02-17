class AppSettings {
  int maxTokensCount;
  String? openAiApiKey;
  String gpt3Model;

  AppSettings(
      {required this.maxTokensCount,
      required this.openAiApiKey,
      required this.gpt3Model});
}
