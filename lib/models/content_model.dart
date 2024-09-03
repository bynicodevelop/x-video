import 'package:x_video_ai/services/abstracts/json_deserializable.dart';

class ContentModel implements JsonDeserializable {
  final String path;
  final String id;
  final String name;
  final Map<String, dynamic>? content;
  final Map<String, dynamic>? chronical;

  ContentModel({
    required this.path,
    this.id = '',
    this.name = '',
    this.content,
    this.chronical,
  });

  @override
  void fromJson(Map<String, dynamic> json) => ContentModel(
        path: json['path'] ?? path,
        id: json['id'] ?? id,
        name: json['name'] ?? name,
        content: json['content'] ?? content,
        chronical: json['chronical'] ?? chronical,
      );

  @override
  Map<String, dynamic> toJson() => {
        'path': path,
        'id': id,
        'name': name,
        'content': content,
        'chronical': chronical,
      };

  @override
  ContentModel mergeWith(Map<String, dynamic> json) {
    return ContentModel(
      path: json['path'] ?? path,
      id: json['id'] ?? id,
      name: json['name'] ?? name,
      content: json['content'] ?? content,
      chronical: json['chronical'] ?? chronical,
    );
  }

  factory ContentModel.factory(Map<String, dynamic> json) => ContentModel(
        path: '',
      ).mergeWith(json);
}
