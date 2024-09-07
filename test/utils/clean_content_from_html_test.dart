import 'package:flutter_test/flutter_test.dart';
import 'package:x_video_ai/utils/clean_content_from_html.dart';

void main() {
  group('cleanContentFromHtml', () {
    test('should remove iframes', () {
      const String content =
          'This is a content with an iframe. <iframe src="https://example.com"></iframe>';
      final String result = cleanContentFromHtml(content);

      expect(result, 'This is a content with an iframe.');
    });

    test('should replace tabs with a single space', () {
      const String content = 'This is\ta content\twith\ttabs.';
      final String result = cleanContentFromHtml(content);

      expect(result, 'This is a content with tabs.');
    });

    test('should replace multiple spaces with a single space', () {
      const String content =
          'This  is   a   content    with  multiple  spaces.';
      final String result = cleanContentFromHtml(content);

      expect(result, 'This is a content with multiple spaces.');
    });

    test('should return trimmed content', () {
      const String content =
          '   This is a content with leading and trailing spaces.   ';
      final String result = cleanContentFromHtml(content);

      expect(result, 'This is a content with leading and trailing spaces.');
    });
  });
}
