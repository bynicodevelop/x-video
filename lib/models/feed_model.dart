import 'package:x_video_ai/models/link_model.dart';
import 'package:x_video_ai/services/abstracts/json_deserializable.dart';

class FeedModel extends LinkModel implements JsonDeserializable {
  final String title;
  final String domain;
  final String description;
  final DateTime date;

  FeedModel({
    required super.link,
    required this.title,
    required this.domain,
    required this.description,
    required this.date,
  });

  @override
  FeedModel fromJson(Map<String, dynamic> json) => FeedModel(
        title: json['title'],
        link: json['link'],
        domain: json['domain'],
        description: json['description'],
        date: json['date'],
      );

  @override
  Map<String, dynamic> toJson() => {
        'title': title,
        'link': link,
        'domain': domain,
        'description': description,
        'date': date,
      };

  @override
  FeedModel mergeWith(Map<String, dynamic> json) => FeedModel(
        title: json['title'] ?? title,
        link: json['link'] ?? link,
        domain: json['domain'] ?? domain,
        description: json['description'] ?? description,
        date: json['date'] ?? date,
      );
}
