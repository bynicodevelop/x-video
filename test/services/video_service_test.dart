import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:x_video_ai/gateway/ffmpeg.dart';
import 'package:x_video_ai/gateway/file_getaway.dart';
import 'package:x_video_ai/models/video_model.dart';
import 'package:x_video_ai/services/video_service.dart';

import '../utils/generate_md5_name_test.mocks.dart';
import 'video_service_test.mocks.dart';

@GenerateMocks([FileGateway, FFMpeg])
void main() {
  late MockFileGateway mockFileGateway;
  late MockFFMpeg mockFFMpeg;
  late MockXFile mockXFile;
  late VideoService videoService;

  setUp(() {
    mockFileGateway = MockFileGateway();
    mockFFMpeg = MockFFMpeg();
    mockXFile = MockXFile();
    videoService = VideoService(mockFileGateway, mockFFMpeg);
  });

  group('VideoService', () {
    test('uploadToTmpFolder uploads video to temporary folder', () async {
      final videoDataModel = VideoDataModel(
        name: 'testVideo',
        file: mockXFile,
        duration: 120.0,
        start: 0.0,
        end: 120.0,
      );
      const projectPath = '/test/project';

      // Stub the file extension
      when(mockXFile.path).thenReturn('/test/path/test.mp4');

      // Stub creating directory
      when(mockFileGateway.createDirectory(any)).thenAnswer((_) async {});

      // Stub file saving
      when(mockXFile.saveTo(any)).thenAnswer((_) async {});

      final result =
          await videoService.uploadToTmpFolder(videoDataModel, projectPath);

      // Verify that the file is saved to the correct temporary folder
      verify(mockFileGateway.createDirectory('$projectPath/tmp')).called(1);
      verify(mockXFile.saveTo('$projectPath/tmp/testVideo.mp4')).called(1);

      expect(result.file!.path, equals('$projectPath/tmp/testVideo.mp4'));
    });

    test('getInformation retrieves video information from FFMpeg', () async {
      // Stub FFMpeg to return some video information
      when(mockFFMpeg.getVideoInformation(any)).thenAnswer((_) async => {
            'duration': 120.0,
            'width': 1920.0,
            'height': 1080.0,
          });

      final videoInfo = await videoService.getInformation(mockXFile);

      // Verify that getVideoInformation is called with the correct path
      verify(mockFFMpeg.getVideoInformation(mockXFile.path)).called(1);

      expect(videoInfo.duration, equals(120.0));
      expect(videoInfo.width, equals(1920.0));
      expect(videoInfo.height, equals(1080.0));
    });

    test('generateThumbnail generates thumbnail for video', () async {
      const outputPath = '/test/output';
      final Uint8List thumbnailData = Uint8List.fromList([0, 1, 2]);

      // Stub generating thumbnail
      when(mockFFMpeg.generateThumbnail(
        inputFile: anyNamed('inputFile'),
        outputPath: anyNamed('outputPath'),
        filename: anyNamed('filename'),
      )).thenAnswer((_) async => thumbnailData);

      final result = await videoService.generateThumbnail(
        file: mockXFile,
        outputPath: outputPath,
      );

      // Verify that the thumbnail is generated
      verify(mockFFMpeg.generateThumbnail(
        inputFile: mockXFile.path,
        outputPath: '$outputPath/tmp',
        filename: anyNamed('filename'),
      )).called(1);

      expect(result, equals(thumbnailData));
    });
  });
}
