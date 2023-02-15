import 'package:pocket_ai/src/network.dart';

// Intro Docs: https://platform.openai.com/docs/introduction
// API calls: https://platform.openai.com/docs/api-reference/making-requests
// Pricing: https://openai.com/api/pricing/
Future<Map<String, dynamic>> getResponseFromOpenAi(String userMessage) {
  String endpoint = 'https://api.openai.com/v1/completions';
  return Network.postRequest(
      endpoint, {}, {'prompt': userMessage, 'model': 'text-davinci-003'});
}
