import 'dart:io';

class ContentExtractorService {
  Future<void> extractContent(
    Map<String, String> content,
    String path,
  ) async {
    // Name miliseconds
    final String directoryName =
        DateTime.now().millisecondsSinceEpoch.toString();

    // Create directory
    final Directory directory = Directory('$path/$directoryName');

    if (!await directory.exists()) {
      await directory.create();
    }

    // Create file
    final File file = File('${directory.path}/content.txt');

    // Write content
    await file.writeAsString("${content['title']}\n\n${content['content']}");
  }
}
