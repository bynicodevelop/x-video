// ignore: depend_on_referenced_packages
import 'package:cross_file/cross_file.dart';
import 'package:x_video_ai/models/video_section_model.dart';

class EditorSectionModel {
  final String id;
  final VideoSectionModel section;
  final XFile? file;

  const EditorSectionModel({
    required this.id,
    required this.section,
    this.file,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'section': section.toJson(),
        'file': file,
      };

  EditorSectionModel mergeWith(
    Map<String, dynamic> data,
  ) =>
      EditorSectionModel(
        id: data['id'] ?? id,
        section: data['section'] ?? section,
        file: data['file'] ?? file,
      );

  static EditorSectionModel fromJson(Map<String, dynamic> json) {
    return EditorSectionModel(
      id: json['id'],
      section: VideoSectionModel.fromJson(json['section']),
      file: json['file'],
    );
  }
}
