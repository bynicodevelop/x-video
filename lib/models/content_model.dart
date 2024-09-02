import 'package:x_video_ai/services/abstracts/json_deserializable.dart';

class ContentModel implements JsonDeserializable {
  final String id;
  final Map<String, dynamic>? content;

  ContentModel({
    this.id = '',
    this.content,
  });

  @override
  void fromJson(Map<String, dynamic> json) => ContentModel(
        id: json['id'],
        content: json['content'],
      );

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
      };

  @override
  ContentModel mergeWith(Map<String, dynamic> json) {
    return ContentModel(
      id: json['id'] ?? id,
      content: json['content'] ?? content,
    );
  }
}
