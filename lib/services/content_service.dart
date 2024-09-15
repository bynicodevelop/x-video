import 'dart:convert';
import 'dart:io';

import 'package:x_video_ai/gateway/file_getaway.dart';
import 'package:x_video_ai/models/content_model.dart';

class ContentService {
  final FileGateway _fileGateway;

  const ContentService(
    this._fileGateway,
  );

  void saveContent(ContentModel contentModel) {
    if (contentModel.path.isEmpty) {
      throw Exception("Path is required");
    }

    final String fileName = contentModel.id.isNotEmpty
        ? contentModel.id
        : DateTime.now().millisecondsSinceEpoch.toString();

    final String path = contentModel.path;

    final FileWrapper file =
        _fileGateway.getFile("$path/contents/$fileName.json");
    final Map<String, dynamic> jsonContent = getContent(file.path);
    final Map<String, dynamic> mergedContent = contentModel.toJson();

    jsonContent.addAll(mergedContent);

    file.writeAsStringSync(jsonEncode(jsonContent));
  }

  List<ContentModel> loadContents(final String path) {
    if (path.isEmpty) {
      throw Exception("Path is required");
    }

    _fileGateway.createDirectory("$path/contents");

    final DirectoryWrapper directory =
        _fileGateway.getDirectory("$path/contents");
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
        final ContentModel contentModel = ContentModel(
          path: directory.path,
        );

        contentList.add(contentModel.mergeWith({
          'id': _getFileNameWithoutExtension(file.path),
          ...json,
        }));
      } else {
        // Gérer le cas où le JSON n'est ni un Map ni une List (si applicable)
        throw Exception('Unexpected JSON format in file: ${file.path}');
      }
    }

    return contentList;
  }

  Map<String, dynamic> getContent(String path) {
    final FileWrapper file = _fileGateway.getFile(path);

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
}
