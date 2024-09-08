import 'package:x_video_ai/models/abstracts/duration_model.dart';

abstract class TimmingModel extends DurationModel {
  final double start;
  final double end;

  TimmingModel({
    required this.start,
    required this.end,
    required super.duration,
  });
}
