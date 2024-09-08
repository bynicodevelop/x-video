// ignore: depend_on_referenced_packages
import 'package:cross_file/cross_file.dart';
import 'package:x_video_ai/models/abstracts/json_deserializable.dart';
import 'package:x_video_ai/models/abstracts/timming_model.dart';
import 'package:x_video_ai/models/upload_state_model.dart';

class VideoDataModel extends TimmingModel implements JsonDeserializable {
  final String name;
  final bool selected;
  final XFile? file;
  final FileUploadState? fileState;

  VideoDataModel({
    required this.name,
    required super.start,
    required super.end,
    required super.duration,
    this.file,
    this.fileState,
    this.selected = false,
  });

  @override
  fromJson(Map<String, dynamic> json) => VideoDataModel(
        name: json['name'],
        start: json['start'],
        end: json['end'],
        duration: json['duration'],
      );

  @override
  mergeWith(Map<String, dynamic> json) => VideoDataModel(
        name: json['name'] ?? name,
        start: json['start'] ?? start,
        end: json['end'] ?? end,
        duration: json['duration'] ?? duration,
        file: json['file'] ?? file,
        fileState: json['fileState'] ?? fileState,
        selected: json['selected'] ?? selected,
      );

  @override
  Map<String, dynamic> toJson() => {
        'name': name,
        'start': start,
        'end': end,
        'duration': duration,
      };

  static VideoDataModel getDefault() => VideoDataModel(
        name: '',
        start: 0,
        end: 0,
        duration: 0,
      );
}
