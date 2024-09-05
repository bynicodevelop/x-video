import 'dart:io';

import 'package:x_video_ai/gateway/open_ai_gateway.dart';
import 'package:x_video_ai/models/open_ai_config_model.dart';
import 'package:x_video_ai/models/srt_sentence_model.dart';
import 'package:x_video_ai/models/srt_word_model.dart';
import 'package:x_video_ai/utils/sentence.dart';

class AudioService {
  final OpenAIGateway openAIGateway;

  AudioService(this.openAIGateway);

  Future<File> convertTextToSpeech(
    String chronical,
    OpentAiConfigModel config,
  ) async {
    return openAIGateway.convertTextToSpeech(
      model: config.model,
      input: chronical,
      voice: config.voice,
      outputDirectory: Directory(config.path),
      outputFileName: config.audioFileName,
    );
  }

  Future<Map<String, dynamic>> transcribeAudioToText(
    final String pathFile,
  ) async {
    return openAIGateway.transcribeAudioToText(
      pathFile: pathFile,
    );
  }

  List<SrtSentenceModel> generateSRT(
    Map<String, dynamic> srtJson,
  ) {
    final Sentence sentence = Sentence();

    final List<String> sentences = sentence.splitSentences(srtJson['text']);

    final List<SrtWordModel> words = List.from(srtJson['words'])
        .map((word) {
          return SrtWordModel.fromJson(word);
        })
        .where((element) => element.word.isNotEmpty)
        .toList();

    return sentences
        .map((e) => sentence.findSentenceTiming(
              SrtSentenceModel(
                sentence: e,
                normalized: sentence.normalizeSequence(e),
              ),
              words,
            ))
        .whereType<SrtSentenceModel>()
        .toList();
  }
}
