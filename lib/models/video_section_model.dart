import 'package:x_video_ai/models/abstracts/timming_model.dart';

class VideoSectionModel implements TimmingModel {
  final String sentence;
  final String? file;
  final String? keyword;

  @override
  final double start;
  @override
  final double end;
  @override
  final double duration;

  VideoSectionModel({
    required this.sentence,
    required this.start,
    required this.end,
    required this.duration,
    this.keyword,
    this.file,
  });

  Map<String, dynamic> toJson() => {
        'sentence': sentence,
        'keyword': keyword,
        'start': start,
        'end': end,
        'duration': duration,
        'file': file,
      };

  factory VideoSectionModel.fromJson(Map<String, dynamic> json) => VideoSectionModel(
      sentence: json['sentence'],
      keyword: json['keyword'],
      start: json['start'],
      end: json['end'],
      duration: json['duration'],
      file: json['file'],
    );

  VideoSectionModel copyWith({
    String? sentence,
    String? keyword,
    double? start,
    double? end,
    double? duration,
    String? file,
  }) =>
      VideoSectionModel(
        sentence: sentence ?? this.sentence,
        keyword: keyword ?? this.keyword,
        start: start ?? this.start,
        end: end ?? this.end,
        duration: duration ?? this.duration,
        file: file ?? this.file,
      );
}
