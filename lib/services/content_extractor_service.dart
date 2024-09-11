import 'dart:convert';

import 'package:x_video_ai/gateway/file_getaway.dart';

class ContentExtractorService {
  final FileGateway _fileGateway;
  final String fileName = 'rss_content.json';

  ContentExtractorService(
    FileGateway fileGateway,
  ) : _fileGateway = fileGateway;

  Future<void> extractContent(
    Map<String, String> content,
    String path,
  ) async {
    final FileWrapper file = _fileGateway.getFile("$path/$fileName");
    final List<Map<String, String>> rssContent = getContent(path);
    final int index = rssContent.indexWhere(
      (element) => element['link'] == content['link'],
    );

    if (index == -1) {
      rssContent.add(content);
      file.writeAsStringSync(jsonEncode(rssContent));
    }
  }

  List<Map<String, String>> getContent(String path) {
    final FileWrapper file = _fileGateway.getFile("$path/$fileName");

    if (!file.existsSync()) {
      file.createSync(recursive: true);
      file.writeAsStringSync('[]');

      return [];
    }

    final String fileContent = file.readAsStringSync();
    final List<dynamic> decodedJson = jsonDecode(fileContent);
    final List<Map<String, String>> rssContent = decodedJson.map((item) {
      return {
        'title': item['title'].toString(),
        'content': item['content'].toString(),
        'link': item['link'].toString(),
      };
    }).toList();

    return rssContent;
  }
}
