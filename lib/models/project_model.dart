import 'package:x_video_ai/services/abstracts/json_deserializable.dart';

class ProjectModel extends JsonDeserializable<ProjectModel> {
  final String name;
  final String path;
  final String? apiKeyOpenAi;
  final String? modelOpenAi;
  final String? voiceOpenAi;
  final List<String> feeds;

  ProjectModel({
    required this.name,
    required this.path,
    this.apiKeyOpenAi,
    this.modelOpenAi,
    this.voiceOpenAi,
    this.feeds = const [],
  });

  @override
  ProjectModel fromJson(Map<String, dynamic> json) => ProjectModel(
        name: json['name'],
        path: json['path'],
        apiKeyOpenAi: json['apiKeyOpenAi'],
        modelOpenAi: json['modelOpenAi'],
        voiceOpenAi: json['voiceOpenAi'],
        feeds: List<String>.from(json['feeds'] ?? []),
      );

  @override
  Map<String, dynamic> toJson() => {
        'name': name,
        'path': path,
        'apiKeyOpenAi': apiKeyOpenAi,
        'modelOpenAi': modelOpenAi,
        'voiceOpenAi': voiceOpenAi,
        'feeds': feeds,
      };

  @override
  ProjectModel mergeWith(Map<String, dynamic> json) => ProjectModel(
        name: json['name'] ?? name,
        path: json['path'] ?? path,
        apiKeyOpenAi: json['apiKeyOpenAi'] ?? apiKeyOpenAi,
        modelOpenAi: json['modelOpenAi'] ?? modelOpenAi,
        voiceOpenAi: json['voiceOpenAi'] ?? voiceOpenAi,
        feeds: List<String>.from(json['feeds'] ?? feeds),
      );
}
