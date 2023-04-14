class AppSettings {
  int maxTokensCount;
  String? openAiApiKey;
  String? generatedContentSignature;

  AppSettings(
      {required this.maxTokensCount,
      required this.openAiApiKey,
      required this.generatedContentSignature});
}
