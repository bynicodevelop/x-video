import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:x_video_ai/gateway/file_getaway.dart';
import 'package:x_video_ai/services/content_extractor_service.dart';

import 'content_service_test.mocks.dart';

@GenerateMocks([FileGateway, FileWrapper])
void main() {
  late MockFileGateway mockFileGateway;
  late MockFileWrapper mockFileWrapper;
  late ContentExtractorService contentExtractorService;

  setUp(() {
    mockFileGateway = MockFileGateway();
    mockFileWrapper = MockFileWrapper();
    contentExtractorService = ContentExtractorService(mockFileGateway);
  });

  group('ContentExtractorService', () {
    test('getContent returns empty list if file does not exist', () {
      when(mockFileGateway.getFile(any)).thenReturn(mockFileWrapper);
      when(mockFileWrapper.existsSync()).thenReturn(false);

      final content = contentExtractorService.getContent('/test/path');

      expect(content, isEmpty);
    });

    test('getContent returns parsed content if file exists', () {
      final fileContent = jsonEncode([
        {'title': 'Test Title', 'content': 'Test Content', 'link': 'Test Link'}
      ]);

      when(mockFileGateway.getFile(any)).thenReturn(mockFileWrapper);
      when(mockFileWrapper.existsSync()).thenReturn(true);
      when(mockFileWrapper.readAsStringSync()).thenReturn(fileContent);

      final content = contentExtractorService.getContent('/test/path');

      expect(content, hasLength(1));
      expect(content.first['title'], equals('Test Title'));
      expect(content.first['content'], equals('Test Content'));
      expect(content.first['link'], equals('Test Link'));
    });

    test('extractContent adds content if link does not exist', () async {
      final existingContentJson = jsonEncode([
        {
          'title': 'Existing Title',
          'content': 'Existing Content',
          'link': 'Existing Link'
        }
      ]);
      final newContent = {
        'title': 'New Title',
        'content': 'New Content',
        'link': 'New Link',
      };

      when(mockFileGateway.getFile(any)).thenReturn(mockFileWrapper);
      when(mockFileWrapper.existsSync()).thenReturn(true);
      when(mockFileWrapper.readAsStringSync()).thenReturn(existingContentJson);

      await contentExtractorService.extractContent(newContent, '/test/path');

      // Vérifier que le contenu a bien été ajouté au fichier
      final updatedContentJson = jsonEncode([
        {
          'title': 'Existing Title',
          'content': 'Existing Content',
          'link': 'Existing Link'
        },
        newContent,
      ]);

      verify(mockFileWrapper.writeAsStringSync(updatedContentJson)).called(1);
    });

    test('extractContent does not add content if link already exists',
        () async {
      final existingContentJson = jsonEncode([
        {
          'title': 'Existing Title',
          'content': 'Existing Content',
          'link': 'Existing Link'
        }
      ]);
      final duplicateContent = {
        'title': 'Existing Title',
        'content': 'Existing Content',
        'link': 'Existing Link',
      };

      when(mockFileGateway.getFile(any)).thenReturn(mockFileWrapper);
      when(mockFileWrapper.existsSync()).thenReturn(true);
      when(mockFileWrapper.readAsStringSync()).thenReturn(existingContentJson);

      await contentExtractorService.extractContent(
          duplicateContent, '/test/path');

      // Vérifier que writeAsStringSync n'a pas été appelé car le lien existe déjà
      verifyNever(mockFileWrapper.writeAsStringSync(any));
    });
  });
}
