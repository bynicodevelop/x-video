import 'dart:convert';
import 'dart:io';

import 'package:x_video_ai/models/content_model.dart';

class ContentService {
  final String projectPath;

  const ContentService(
    this.projectPath,
  );

  void saveContent(
    ContentModel contentModel, {
    String? contentName,
  }) {
    final String fileName =
        contentName ?? DateTime.now().millisecondsSinceEpoch.toString();
    final File file = _getFile("$projectPath/contents/$fileName.json");
    final Map<String, dynamic> jsonContent = getContent(file.path);
    final Map<String, dynamic> mergedContent = contentModel.toJson();

    jsonContent.addAll(mergedContent);

    file.writeAsStringSync(jsonEncode(jsonContent));
  }

  List<ContentModel> loadContents() {
    final Directory directory = Directory("$projectPath/contents");
    final List<FileSystemEntity> files = directory
        .listSync()
        .where((element) => element.path.endsWith('.json'))
        .toList();
    final List<ContentModel> contentList = [];

    for (final FileSystemEntity file in files) {
      final String fileContent = File(file.path).readAsStringSync();
      final dynamic json = jsonDecode(fileContent);

      if (json is Map<String, dynamic>) {
        // Si le JSON est un objet (Map)
        final ContentModel contentModel = ContentModel();

        contentList.add(contentModel.mergeWith({
          'id': _getFileNameWithoutExtension(file.path),
          ...json,
        }));
      } else {
        // Gérer le cas où le JSON n'est ni un Map ni une List (si applicable)
        print('Unexpected JSON format in file: ${file.path}');
      }
    }

    return contentList;
  }

  Map<String, dynamic> getContent(String path) {
    final File file = _getFile(path);

    if (!file.existsSync()) {
      file.createSync(recursive: true);
      file.writeAsStringSync('{}');

      return {};
    }

    final String fileContent = file.readAsStringSync();
    final dynamic json = jsonDecode(fileContent);

    return json as Map<String, dynamic>;
  }

  String _getFileNameWithoutExtension(String path) {
    final List<String> pathParts = path.split('/');
    final String fileName = pathParts.last;
    final List<String> fileNameParts = fileName.split('.');

    return fileNameParts.first;
  }

  File _getFile(String path) {
    final Directory directory = Directory(path);
    final File file = File(directory.path);

    return file;
  }
}
