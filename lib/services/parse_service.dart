import 'package:html/dom.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:x_video_ai/utils/clean_content_from_html.dart';

class ParseService {
  Future<Map<String, String>> parseUrl(String url) async {
    final Document document = await getDocument(url);
    final String apmLink = _isAmp(document);

    if (apmLink.isNotEmpty) {
      Document ampDocument = await getDocument(apmLink);

      final String title = _extractTitle(ampDocument);
      final String content = _extractContentFromAmp(ampDocument);

      return {
        'title': title,
        'content': content,
      };
    } else {
      final String title = _extractTitle(document);
      final String content = _extractContent(document);

      return {
        'title': title,
        'content': cleanContentFromHtml(content),
      };
    }
  }

  Future<Document> getDocument(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return html_parser.parse(response.body);
    } else {
      throw Exception('Failed to load URL');
    }
  }

  String _extractTitle(Document document) {
    return document.querySelector('h1')?.text ?? '';
  }

  String _isAmp(Document document) {
    Element? ampLink = document.querySelector('link[rel="amphtml"]');
    return ampLink != null ? ampLink.attributes['href']! : '';
  }

  String _extractContentFromAmp(Document document) {
    return document.querySelectorAll('p').map((e) => e.text).join(' ');
  }

  String _extractContent(Document document) {
    final List<String> selectors = [
      'body article',
      'body main',
      'body',
    ];

    for (final selector in selectors) {
      final element = document.querySelector(selector);
      if (element != null) {
        return element.text;
      }
    }

    return '';
  }
}
