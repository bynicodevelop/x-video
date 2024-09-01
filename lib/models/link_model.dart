import 'package:x_video_ai/services/abstracts/json_deserializable.dart';

class LinkModel implements JsonDeserializable {
  final String link;

  LinkModel({
    required this.link,
  });

  @override
  LinkModel fromJson(Map<String, dynamic> json) => LinkModel(
        link: json['link'],
      );

  @override
  Map<String, dynamic> toJson() => {
        'link': link,
      };

  @override
  LinkModel mergeWith(Map<String, dynamic> json) => LinkModel(
        link: json['link'] ?? link,
      );
}
