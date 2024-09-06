import 'package:dart_openai/dart_openai.dart';
import 'package:x_video_ai/gateway/open_ai_gateway.dart';
import 'package:x_video_ai/models/chronical_prompt_model.dart';

class ChronicalService {
  Future<String> createChronical(
    ChronicalPromptModel chronicalPromptModel,
  ) async {
    OpenAIGateway openAIGateway = OpenAIGateway<String>(
      chronicalPromptModel.apiKey,
    );

    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          chronicalPromptModel.prompt,
        ),
      ],
      role: OpenAIChatMessageRole.system,
    );

    final userMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          chronicalPromptModel.content,
        ),
      ],
      role: OpenAIChatMessageRole.user,
    );

    final String chronique = await openAIGateway.callOpenAI(
      messages: [
        systemMessage,
        userMessage,
      ],
      model: chronicalPromptModel.model,
    );

    return chronique;
  }
}
