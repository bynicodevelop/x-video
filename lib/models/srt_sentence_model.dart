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
}
