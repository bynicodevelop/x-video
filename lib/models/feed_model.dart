import 'package:x_video_ai/services/abstracts/json_deserializable.dart';

class FeedModel extends JsonDeserializable<FeedModel> {
  final String title;
  final String link;
  final String domain;
  final String description;
  final DateTime date;

  FeedModel({
    required this.title,
    required this.link,
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
