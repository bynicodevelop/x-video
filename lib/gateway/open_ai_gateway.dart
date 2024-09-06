import 'dart:convert';
import 'dart:io';

import 'package:dart_openai/dart_openai.dart';

const kTypeText = 'text';
const kTypeJsonObject = 'json_object';

class OpenAIGateway<T> {
  OpenAIGateway(String apiKey) {
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

  Future<File> convertTextToSpeech({
    required String model,
    required String input,
    required String voice,
    required Directory outputDirectory,
    String outputFileName = "audio",
    OpenAIAudioSpeechResponseFormat? responseFormat,
  }) async {
    final File audioFile = await OpenAI.instance.audio.createSpeech(
      model: "tts-1",
      input: input,
      voice: voice.isNotEmpty ? voice : 'nova',
      responseFormat: responseFormat ?? OpenAIAudioSpeechResponseFormat.mp3,
      outputFileName: outputFileName,
      outputDirectory: outputDirectory,
    );

    final String newPath = "${outputDirectory.path}/$outputFileName.mp3";
    final File newFile = File(newPath);

    audioFile.renameSync(newPath);

    return newFile;
  }

  Future<Map<String, dynamic>> transcribeAudioToText({
    required String pathFile,
  }) async {
    final File audioFile = File(pathFile);

    final OpenAIAudioModel transcription =
        await OpenAI.instance.audio.createTranscription(
      file: audioFile,
      model: "whisper-1",
      responseFormat: OpenAIAudioResponseFormat.verbose_json,
      timestamp_granularities: [OpenAIAudioTimestampGranularity.word],
    );

    return {
      "text": transcription.text,
      "words": transcription.words
          ?.map((e) => {
                "start": e.start,
                "end": e.end,
                "word": e.word,
              })
          .toList(),
      "duration": transcription.duration,
      "language": transcription.language,
    };
  }
}
