import 'package:x_video_ai/models/srt_word_model.dart';

class SrtSentenceModel {
  final String sentence;
  final String normalized;
  final List<SrtWordModel>? words;
  final List<SrtWordModel>? group;
  final double? start;
  final double? end;
  final double? duration;

  SrtSentenceModel({
    required this.sentence,
    required this.normalized,
    this.words,
    this.group,
    this.start,
    this.end,
    this.duration,
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
