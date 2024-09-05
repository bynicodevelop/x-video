class SrtWordModel {
  final String word;
  final double start;
  final double end;
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
