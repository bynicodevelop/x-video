import 'dart:io';

import 'package:x_video_ai/gateway/file_getaway.dart';
import 'package:x_video_ai/gateway/open_ai_gateway.dart';
import 'package:x_video_ai/models/open_ai_config_model.dart';
import 'package:x_video_ai/models/srt_sentence_model.dart';
import 'package:x_video_ai/models/srt_word_model.dart';
import 'package:x_video_ai/utils/constants.dart';
import 'package:x_video_ai/utils/sentence.dart';
import 'package:x_video_ai/utils/srt_subtitle.dart';

class AudioService {
  final FileGateway _fileGateway;
  final OpenAIGateway _openAIGateway;

  AudioService(
    FileGateway fileGateway,
    OpenAIGateway openAIGateway,
  )   : _fileGateway = fileGateway,
        _openAIGateway = openAIGateway;

  Future<FileWrapper> convertTextToSpeech(
    String chronical,
    OpentAiConfigModel config,
  ) async {
    final String audioPath =
        "${config.path}/${config.audioFileName}.$kAudioExtension";
        
    if (_fileGateway.exists(audioPath)) {
      return _fileGateway.getFile(audioPath);
    }

    return _openAIGateway.convertTextToSpeech(
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
    return _openAIGateway.transcribeAudioToText(
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

  String createSubtitles(
    List<SrtSentenceModel> srtWithGroup, {
    int wordPerLine = 3,
  }) {
    final SrtSubtitle srtSubtitle = SrtSubtitle();

    List<List<SrtWordModel>> subtitles = srtSubtitle.createSubtitles(
      srtWithGroup,
      wordPerLine: wordPerLine,
    );

    return srtSubtitle.generateAssFile(subtitles);
  }
}
