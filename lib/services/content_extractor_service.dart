import 'dart:convert';
import 'dart:io';

class ContentExtractorService {
  final String fileName = 'rss_content.json';

  Future<void> extractContent(
    Map<String, String> content,
    String path,
  ) async {
    final File file = _getFile(path);
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
    final File file = _getFile(path);

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

  File _getFile(String path) {
    final Directory directory = Directory(path);
    final File file = File('${directory.path}/$fileName');

    return file;
  }
}
