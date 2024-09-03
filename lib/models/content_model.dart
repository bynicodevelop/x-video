import 'package:x_video_ai/services/abstracts/json_deserializable.dart';

class ContentModel implements JsonDeserializable {
  final String path;
  final String id;
  final String name;
  final Map<String, dynamic>? content;

  ContentModel({
    required this.path,
    this.id = '',
    this.name = '',
    this.content,
  });

  @override
  void fromJson(Map<String, dynamic> json) => ContentModel(
        path: json['path'] ?? path,
        id: json['id'] ?? id,
        name: json['name'] ?? name,
        content: json['content'] ?? content,
      );

  @override
  Map<String, dynamic> toJson() => {
        'path': path,
        'id': id,
        'name': name,
        'content': content,
      };

  @override
  ContentModel mergeWith(Map<String, dynamic> json) {
    return ContentModel(
      path: json['path'] ?? path,
      id: json['id'] ?? id,
      name: json['name'] ?? name,
      content: json['content'] ?? content,
    );
  }

  factory ContentModel.factory(Map<String, dynamic> json) => ContentModel(
        path: '',
      ).mergeWith(json);
}
