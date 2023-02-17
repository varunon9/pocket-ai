import 'package:pocket_ai/src/globals.dart';
import 'package:pocket_ai/src/network.dart';

// Intro Docs: https://platform.openai.com/docs/introduction
// API calls: https://platform.openai.com/docs/api-reference/making-requests
// Prompt: https://platform.openai.com/examples/default-chat
// API parameters: https://platform.openai.com/docs/api-reference/completions/create
// Pricing: https://openai.com/api/pricing/
Future<Map<String, dynamic>> getResponseFromOpenAi(
    String context, String userMessage) {
  String endpoint = 'https://api.openai.com/v1/completions';
  String prompt = '''The following is a conversation with an AI assistant. 
The assistant is helpful, creative, clever, and very friendly.
$context
Human: $userMessage
AI:
''';
  return Network.postRequest(endpoint, {}, {
    // ID of the model to use. One can visit https://platform.openai.com/docs/api-reference/models/list
    // to see all the available models, or see https://platform.openai.com/docs/models/overview for descriptions of them.
    'model': Globals.appSettings.gpt3Model,
    // The prompt(s) to generate completions for, encoded as a string, array of strings,
    // array of tokens, or array of token arrays.
    'prompt': prompt,
    // Controls randomness: Lowering results in less random completions.
    // As the temperature approaches zero, the model will become deterministic and repetitive
    'temperature': 0.9,
    // The maximum number of tokens to generate in the completion.
    // The token count of your prompt plus max_tokens cannot exceed the model's context length.
    // Most models have a context length of 2048 tokens (except for the newest models, which support 4096).
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
    'presence_penalty': 0.6,
    // Up to 4 sequences where the API will stop generating further tokens.
    // The returned text will not contain the stop sequence.
    'stop': [' Human:', ' AI:']
  });
}
