import 'package:x_video_ai/models/abstracts/timming_model.dart';

class SrtWordModel implements TimmingModel {
  final String word;
  @override
  final double start;
  @override
  final double end;
  @override
  final double duration;

  SrtWordModel({
    required this.word,
    required this.start,
    required this.end,
    required this.duration,
  });

  factory SrtWordModel.fromJson(Map<String, dynamic> json) {
    return SrtWordModel(
      word: json['word'],
      start: json['start'] ?? 0,
      end: json['end'] ?? 0,
      duration: json['duration'] ?? json['end'] - json['start'],
    );
  }

  toJson() {
    return {
      'word': word,
      'start': start,
      'end': end,
      'duration': duration,
    };
  }
}
