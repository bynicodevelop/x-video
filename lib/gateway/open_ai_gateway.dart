import 'dart:convert';

import 'package:dart_openai/dart_openai.dart';

const kTypeText = 'text';
const kTypeJsonObject = 'json_object';

class OpenAIGateway<T> {
  OpenAIGateway(
    String apiKey,
  ) {
    OpenAI.apiKey = apiKey;
  }

  Future<T> callOpenAI({
    required List<OpenAIChatCompletionChoiceMessageModel> messages,
    String model = 'gpt-4o',
  }) async {
    final OpenAIChatCompletionModel chat = await OpenAI.instance.chat.create(
      model: model,
      messages: messages,
      responseFormat: {
        'type': T == String ? kTypeText : kTypeJsonObject,
      },
    );

    final content = chat.choices.first.message.content?.first.text ?? '';

    if (T == String) {
      return content as T;
    }

    return content.isNotEmpty ? jsonDecode(content) : {} as T;
  }
}
