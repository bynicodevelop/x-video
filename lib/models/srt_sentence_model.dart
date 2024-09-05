import 'package:x_video_ai/models/abstracts/timming_model.dart';
import 'package:x_video_ai/models/srt_word_model.dart';

class SrtSentenceModel implements TimmingModel {
  final String sentence;
  final String normalized;
  final List<SrtWordModel>? words;
  final List<SrtWordModel>? group;
  @override
  final double start;
  @override
  final double end;
  @override
  final double duration;

  SrtSentenceModel({
    required this.sentence,
    required this.normalized,
    this.words,
    this.group,
    this.start = 0,
    this.end = 0,
    this.duration = 0,
  });

  Map<String, dynamic> toJson() => {
        'sentence': sentence,
        'normalized': normalized,
        'words': words?.map((e) => e.toJson()).toList(),
        'group': group?.map((e) => e.toJson()).toList(),
        'start': start,
        'end': end,
        'duration': duration,
      };

  factory SrtSentenceModel.fromJson(Map<String, dynamic> json) =>
      SrtSentenceModel(
        sentence: json['sentence'],
        normalized: json['normalized'],
        words: List.from(json['words'])
            .map((e) => SrtWordModel.fromJson(e))
            .toList(),
        group: List.from(json['group'])
            .map((e) => SrtWordModel.fromJson(e))
            .toList(),
        start: json['start'],
        end: json['end'],
        duration: json['duration'],
      );
}
