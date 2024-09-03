import 'package:x_video_ai/models/open_ai_config_model.dart';

class ChronicalPromptModel extends OpentAiConfigModel {
  final String prompt;
  final String content;

  ChronicalPromptModel({
    required this.prompt,
    required this.content,
    required super.apiKey,
    required super.model,
  });

  Map<String, dynamic> toJson() {
    return {
      'prompt': prompt,
      'content': content,
      'apiKey': apiKey,
      'model': model,
    };
  }
}
