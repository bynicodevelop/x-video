import 'package:x_video_ai/models/abstracts/json_deserializable.dart';

class ContentModel implements JsonDeserializable {
  final String path;
  final String id;
  final String name;
  final Map<String, dynamic>? content;
  final Map<String, dynamic>? chronical;
  final Map<String, dynamic>? audio;
  final Map<String, dynamic>? srt;
  final Map<String, dynamic>? srtWithGroup;
  final Map<String, dynamic>? assContent;
  final Map<String, dynamic>? sections;

  ContentModel({
    required this.path,
    this.id = '',
    this.name = '',
    this.content,
    this.chronical,
    this.audio,
    this.srt,
    this.srtWithGroup,
    this.assContent,
    this.sections,
  });

  @override
  void fromJson(Map<String, dynamic> json) => ContentModel(
        path: json['path'] ?? path,
        id: json['id'] ?? id,
        name: json['name'] ?? name,
        content: json['content'] ?? content,
        chronical: json['chronical'] ?? chronical,
        audio: json['audio'] ?? audio,
        srt: json['srt'] ?? srt,
        srtWithGroup: json['srtWithGroup'] ?? srtWithGroup,
        assContent: json['assContent'] ?? assContent,
        sections: json['sections'] ?? sections,
      );

  @override
  Map<String, dynamic> toJson() => {
        'path': path,
        'id': id,
        'name': name,
        'content': content,
        'chronical': chronical,
        'audio': audio,
        'srt': srt,
        'srtWithGroup': srtWithGroup,
        'assContent': assContent,
        'sections': sections,
      };

  @override
  ContentModel mergeWith(Map<String, dynamic> json) {
    return ContentModel(
      path: json['path'] ?? path,
      id: json['id'] ?? id,
      name: json['name'] ?? name,
      content: json['content'] ?? content,
      chronical: json['chronical'] ?? chronical,
      audio: json['audio'] ?? audio,
      srt: json['srt'] ?? srt,
      srtWithGroup: json['srtWithGroup'] ?? srtWithGroup,
      assContent: json['assContent'] ?? assContent,
      sections: json['sections'] ?? sections,
    );
  }

  factory ContentModel.factory(Map<String, dynamic> json) => ContentModel(
        path: '',
      ).mergeWith(json);

  factory ContentModel.empty() => ContentModel(path: '');
}
