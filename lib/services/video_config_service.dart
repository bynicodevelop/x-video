import 'dart:convert';
import 'dart:io';

import 'package:x_video_ai/models/video_model.dart';

class VideoConfigService {
  final String _videoFileName = 'videos.json';
  final String _videoFolderName = 'videos';

  List<VideoDataModel> loadVideos(
    final String path,
  ) {
    if (path.isEmpty) {
      throw Exception("Path is required");
    }

    final File file = File("$path/$_videoFileName");

    if (!file.existsSync()) {
      return [];
    }

    final String fileContent = file.readAsStringSync();

    final dynamic json = jsonDecode(fileContent);

    if (json is List<dynamic>) {
      // Si le JSON est une liste
      final List<VideoDataModel> videoList = [];

      for (final dynamic video in json) {
        if (video is Map<String, dynamic>) {
          videoList.add(VideoDataModel.factory(video));
        } else {
          // Gérer le cas où le JSON n'est ni un Map ni une List (si applicable)
          throw Exception('Unexpected JSON format in file: ${file.path}');
        }
      }

      return videoList;
    } else {
      // Gérer le cas où le JSON n'est ni un Map ni une List (si applicable)
      throw Exception('Unexpected JSON format in file: ${file.path}');
    }
  }

  void saveVideos(
    final VideoDataModel video,
    final String path,
  ) {
    if (path.isEmpty) {
      throw Exception("Path is required");
    }

    final File file = File("$path/$_videoFolderName/$_videoFileName");

    if (!file.existsSync()) {
      file.createSync();
      file.writeAsStringSync(jsonEncode([]));
    }

    final String fileContent = file.readAsStringSync();

    final dynamic json = jsonDecode(fileContent);

    if (json is List<dynamic>) {
      json.add(video.toJson());
    } else {
      throw Exception('Unexpected JSON format in file: ${file.path}');
    }

    file.writeAsStringSync(jsonEncode(json));
  }
}
