import 'package:pocket_ai/src/globals.dart';
import 'package:pocket_ai/src/modules/chat/models/chat_message.dart';
import 'package:pocket_ai/src/network.dart';

// Intro Docs: https://openai.com/blog/introducing-chatgpt-and-whisper-apis
// API Docs: https://platform.openai.com/docs/guides/chat
// Pricing: https://openai.com/api/pricing/
Future<Map<String, dynamic>> getResponseFromOpenAi(List<ChatMessage> messages) {
  String endpoint = 'https://api.openai.com/v1/chat/completions';
  messages.insert(
      0,
      ChatMessage(
          content:
              'You are a helpful, creative, clever, and very friendly assistant.',
          role: ChatRole.system));

  return Network.postRequest(endpoint, {}, {
    // parameters docs: https://platform.openai.com/docs/api-reference/chat/create
    'model': 'gpt-3.5-turbo',
    'messages': messages,
    // Controls randomness: Lowering results in less random completions.
    // As the temperature approaches zero, the model will become deterministic and repetitive
    'temperature': 0.9,
    // The maximum number of tokens allowed for the generated answer.
    // By default, the number of tokens the model can return will be (4096 - prompt tokens).
    'max_tokens': Globals.appSettings.maxTokensCount,
    // An alternative to sampling with temperature, called nucleus sampling,
    // where the model considers the results of the tokens with top_p probability mass.
    // So 0.1 means only the tokens comprising the top 10% probability mass are considered
    // OpenAI generally recommends altering this or temperature but not both.
    'top_p': 1,
    // Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency in the text so far,
    // decreasing the model's likelihood to repeat the same line verbatim.
    'frequency_penalty': 0.0,
    // Number between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear in the text so far,
    // increasing the model's likelihood to talk about new topics.
    'presence_penalty': 0.6
  });
}
