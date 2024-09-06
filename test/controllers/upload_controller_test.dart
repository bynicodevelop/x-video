// ignore: depend_on_referenced_packages
import 'package:cross_file/cross_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:x_video_ai/controllers/content_controller.dart';
import 'package:x_video_ai/controllers/upload_controller.dart';
import 'package:x_video_ai/models/content_model.dart';
import 'package:x_video_ai/models/upload_state_model.dart';
import 'package:x_video_ai/services/video_service.dart';

import 'upload_controller_test.mocks.dart';

@GenerateMocks([VideoService, ContentController])
void main() {
  late MockVideoService mockVideoService;
  late MockContentController mockContentController;
  late ProviderContainer container;

  setUp(() {
    mockVideoService = MockVideoService();

    final contentModel = ContentModel(
      path: "/testPath",
      id: "1",
      name: "TestContent",
      content: null,
      chronical: null,
      audio: null,
      srt: null,
      srtWithGroup: null,
      assContent: null,
      sections: null,
    );

    mockContentController = MockContentController();
    when(mockContentController.state).thenReturn(contentModel);

    container = ProviderContainer(
      overrides: [
        uploadControllerProvider.overrideWith(
          (ref) => UploadControllerProvider(
            mockVideoService,
            mockContentController,
          ),
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('should update state to uploading and then uploaded on success',
      () async {
    final file = XFile('test_video.mp4');
    when(mockVideoService.uploadToTmpFolder(any, any))
        .thenAnswer((_) async => Future.value());

    await container.read(uploadControllerProvider.notifier).upload(file);

    final state = container.read(uploadControllerProvider);
    expect(state.files.length, equals(1));
    expect(state.files.first.status, equals(UploadStatus.uploaded));

    verify(mockVideoService.uploadToTmpFolder(file, "/testPath")).called(1);
  });

  test('should update state to uploading and then uploadFailed on failure',
      () async {
    final file = XFile('test_video.mp4');
    when(mockVideoService.uploadToTmpFolder(any, any))
        .thenThrow(Exception('Upload failed'));

    await container.read(uploadControllerProvider.notifier).upload(file);

    final state = container.read(uploadControllerProvider);
    expect(state.files.length, equals(1));
    expect(state.files.first.status, equals(UploadStatus.uploadFailed));
    expect(state.files.first.message, equals('Exception: Upload failed'));

    verify(mockVideoService.uploadToTmpFolder(file, "/testPath")).called(1);
  });

  test('should add a file with status uploading', () async {
    final file = XFile('test_video.mp4');

    container.read(uploadControllerProvider.notifier).upload(file);

    final state = container.read(uploadControllerProvider);
    expect(state.files.length, equals(1));
    expect(state.files.first.status, equals(UploadStatus.uploading));
  });
}
