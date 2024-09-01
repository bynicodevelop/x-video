import 'package:x_video_ai/gateway/xml_reader.dart';
import 'package:x_video_ai/models/feed_model.dart';

class FeedService {
  final XmlReader _xmlReader = XmlReader();
  final List<String> feeds;

  FeedService({
    required this.feeds,
  });

  Future<List<FeedModel>> fetch() async {
    final rss = await _xmlReader.read(
      feeds,
    );

    return rss.map((item) {
      return FeedModel(
        title: item['title'] ?? '',
        link: item['link'] ?? '',
        domain: item['domain'] ?? '',
        description: item['description'] ?? '',
        date: item['date'] ?? '',
      );
    }).toList()
    ..sort((a, b) => b.date.compareTo(a.date));
  }
}
