import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:x_video_ai/controllers/loading_controller.dart';
import 'package:x_video_ai/controllers/reader_content_controller.dart';
import 'package:x_video_ai/models/feed_model.dart';
import 'package:x_video_ai/services/parse_service.dart';

import 'reader_content_controller_test.mocks.dart';

@GenerateMocks([ParseService, LoadingController])
void main() {
  late MockParseService mockParseService;
  late MockLoadingController mockLoadingController;
  late ReaderContentController readerContentController;

  setUp(() {
    mockParseService = MockParseService();
    mockLoadingController = MockLoadingController();
    readerContentController = ReaderContentController(
      mockLoadingController,
      mockParseService,
    );
  });

  test('should load content and update state correctly', () async {
    // Arrange
    final feedModel = FeedModel(
        link: 'https://example.com',
        title: 'Mock Title',
        description: 'Mock Content',
        domain: 'example.com',
        date: DateTime.now());
    final mockContent = {'title': 'Mock Title', 'content': 'Mock Content'};

    // Mocking parseUrl to return a Future with mockContent
    when(mockParseService.parseUrl(feedModel.link))
        .thenAnswer((_) async => mockContent);

    // Act
    await readerContentController.loadContent(feedModel);

    // Assert
    expect(readerContentController.content, {
      'title': 'Mock Title',
      'content': 'Mock Content',
      'model': feedModel,
    });

    verify(mockLoadingController.startLoading('reader')).called(1);
    verify(mockLoadingController.stopLoading('reader')).called(1);
  });

  test('should call startLoading and stopLoading correctly', () async {
    // Arrange
    final feedModel = FeedModel(
        link: 'https://example.com',
        title: 'Mock Title',
        description: 'Mock Content',
        domain: 'example.com',
        date: DateTime.now());
    final mockContent = {'title': 'Mock Title', 'content': 'Mock Content'};

    // Mocking parseUrl to return a Future with mockContent
    when(mockParseService.parseUrl(feedModel.link))
        .thenAnswer((_) async => mockContent);

    // Act
    await readerContentController.loadContent(feedModel);

    // Assert
    verify(mockLoadingController.startLoading('reader')).called(1);
    verify(mockLoadingController.stopLoading('reader')).called(1);
  });

  test('should handle parse service failure', () async {
    // Arrange
    final feedModel = FeedModel(
        link: 'https://example.com',
        title: 'Mock Title',
        description: 'Mock Content',
        domain: 'example.com',
        date: DateTime.now());

    // Mocking parseUrl to throw an exception
    when(mockParseService.parseUrl(feedModel.link))
        .thenThrow(Exception('Failed to parse'));

    // Act
    try {
      await readerContentController.loadContent(feedModel);
    } catch (e) {
      // Handle the exception
    }

    // Assert
    expect(readerContentController.content, isNull);

    // Verify that startLoading and stopLoading were both called
    verify(mockLoadingController.startLoading('reader')).called(1);
    verify(mockLoadingController.stopLoading('reader')).called(1);
  });
}
