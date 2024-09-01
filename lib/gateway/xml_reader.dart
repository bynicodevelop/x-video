import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:xml2json/xml2json.dart';

class XmlReader {
  Future<List<Map<String, dynamic>>> read(
    List<String> urls,
  ) async {
    final List<List<Map<String, dynamic>>> results =
        await Future.wait(urls.map((url) async {
      final Xml2Json xml2json = Xml2Json();
      final uri = Uri.parse(url);
      final response = await http.get(uri);
      final responseBody = utf8.decode(response.bodyBytes);

      xml2json.parse(responseBody);
      var jsondata = xml2json.toGData();

      final data = json.decode(jsondata);

      return (data['rss']['channel']['item'] as List)
          .map<Map<String, dynamic>>((item) {
        return {
          'title': item['title']?['\$t'] ?? item['title']?['__cdata'],
          'link': item['link']?['\$t'],
          'description':
              item['description']?['\$t'] ?? item['description']?['__cdata'],
          'domain': _extractDomain(item['link']?['\$t']),
          'date': _parseDate(item['pubDate']?['\$t']),
        };
      }).toList();
    }));

    return results.expand((element) => element).toList();
  }

  DateTime? _parseDate(String date) {
    DateTime? parsedDate;

    final List<DateFormat> dateFormats = [
      DateFormat("EEE, dd MMM yyyy HH:mm:ss Z"),
      DateFormat("yyyy-MM-dd HH:mm:ss"),
      DateFormat("yyyy-MM-dd'T'HH:mm:ss"),
      DateFormat("yyyy-MM-dd"),
    ];

    for (final format in dateFormats) {
      try {
        parsedDate = format.parse(date, true).toLocal();
        break;
      } catch (e) {
        // Si le format actuel échoue, on passe au suivant
      }
    }

    return parsedDate;
  }

  String _extractDomain(String url) {
    final uri = Uri.parse(url);
    return uri.host;
  }
}
