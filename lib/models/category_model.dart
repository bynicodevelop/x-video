import 'package:x_video_ai/models/abstracts/json_deserializable.dart';

class CategoryModel implements JsonDeserializable {
  final String name;
  final List<String> keywords;
  final List<String> videos;

  CategoryModel({
    required this.name,
    required this.keywords,
    required this.videos,
  });

  factory CategoryModel.factory(Map<String, dynamic> json) => CategoryModel(
        name: json['name'],
        keywords: List<String>.from(json['keywords']),
        videos: List<String>.from(json['videos']),
      );

  @override
  CategoryModel fromJson(Map<String, dynamic> json) => CategoryModel(
        name: json['name'],
        keywords: List<String>.from(json['keywords']),
        videos: List<String>.from(json['videos']),
      );

  @override
  Map<String, dynamic> toJson() => {
        'name': name,
        'keywords': keywords,
        'videos': videos,
      };

  @override
  CategoryModel mergeWith(Map<String, dynamic> json) => CategoryModel(
        name: json['name'] ?? name,
        keywords: json['keywords'] != null
            ? List<String>.from(json['keywords'])
            : keywords,
        videos:
            json['videos'] != null ? List<String>.from(json['videos']) : videos,
      );
}
