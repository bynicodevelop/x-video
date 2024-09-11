import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:x_video_ai/gateway/file_getaway.dart';
import 'package:x_video_ai/models/content_model.dart';
import 'package:x_video_ai/services/content_service.dart';

import 'content_service_test.mocks.dart';

class MockFileSystemEntity extends Mock implements FileSystemEntity {}

@GenerateMocks([FileGateway, FileWrapper, DirectoryWrapper])
void main() {
  late MockFileGateway mockFileGateway;
  late ContentService contentService;

  setUp(() {
    mockFileGateway = MockFileGateway();
    contentService = ContentService(mockFileGateway);
  });

  group('ContentService', () {
    test('saveContent throws an exception if the path is empty', () {
      final contentModel = ContentModel(
        id: 'test_id',
        path: '',
      );

      expect(
          () => contentService.saveContent(contentModel),
          throwsA(isA<Exception>().having(
              (e) => e.toString(), 'message', contains('Path is required'))));
    });

    test('saveContent writes merged content to a file', () {
      final contentModel = ContentModel(
        id: 'test_id',
        path: '/test/path',
      );
      final mockFile = MockFileWrapper();

      // Configurer les comportements des mocks
      when(mockFileGateway.getFile(any)).thenReturn(mockFile);
      when(mockFile.path).thenReturn('/test/path/contents/test_id.json');
      when(mockFile.existsSync()).thenReturn(true);
      when(mockFile.readAsStringSync()).thenReturn('{}');

      // Appeler la méthode saveContent
      contentService.saveContent(contentModel);

      // Vérifier que le fichier est écrit avec le contenu attendu
      verify(mockFile.writeAsStringSync(any)).called(1);
    });

    test('loadContents throws an exception if the path is empty', () {
      expect(
          () => contentService.loadContents(''),
          throwsA(isA<Exception>().having(
              (e) => e.toString(), 'message', contains('Path is required'))));
    });

    test('getContent returns an empty map if file does not exist', () {
      final mockFile = MockFileWrapper();

      when(mockFileGateway.getFile(any)).thenReturn(mockFile);
      when(mockFile.existsSync()).thenReturn(false);

      final content = contentService.getContent('/test/path/content.json');

      expect(content, equals({}));
    });

    test('getContent returns parsed content if file exists', () {
      final mockFile = MockFileWrapper();

      when(mockFileGateway.getFile(any)).thenReturn(mockFile);
      when(mockFile.existsSync()).thenReturn(true);
      when(mockFile.readAsStringSync()).thenReturn('{"key": "value"}');

      final content = contentService.getContent('/test/path/content.json');

      expect(content, equals({'key': 'value'}));
    });
  });
}
