import 'dart:typed_data';

// ignore: depend_on_referenced_packages
import 'package:cross_file/cross_file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:x_video_ai/gateway/ffmpeg.dart';
import 'package:x_video_ai/gateway/file_getaway.dart';
import 'package:x_video_ai/models/video_model.dart';
import 'package:x_video_ai/services/video_service.dart';

import 'video_service_test.mocks.dart';

class FakeXFile extends XFile {
  final Uint8List _bytes;
  final String _path;
  String?
      savedToPath; // Ajoutez cette variable pour enregistrer le chemin de sauvegarde

  FakeXFile(this._bytes, [this._path = ''])
      : super.fromData(_bytes, name: _path);

  @override
  String get path => _path;

  @override
  Future<Uint8List> readAsBytes() async {
    return _bytes;
  }

  @override
  Future<void> saveTo(String path) async {
    savedToPath = path; // Enregistrez le chemin de sauvegarde
  }
}

@GenerateMocks([FileGateway, FFMpeg])
void main() {
  late MockFileGateway mockFileGateway;
  late MockFFMpeg mockFFMpeg;
  late FakeXFile mockXFile;
  late VideoService videoService;

  setUp(() {
    mockFileGateway = MockFileGateway();
    mockFFMpeg = MockFFMpeg();
    mockXFile = FakeXFile(Uint8List.fromList([]), '/test/path/test.mp4');
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

      // Stub creating directory
      when(mockFileGateway.createDirectory(any)).thenAnswer((_) async {});

      final result =
          await videoService.uploadToTmpFolder(videoDataModel, projectPath);

      // Vérifiez que le répertoire a été créé
      verify(mockFileGateway.createDirectory('$projectPath/tmp')).called(1);

      // Vérifiez que le fichier a été sauvegardé au bon endroit
      expect(mockXFile.savedToPath, equals('$projectPath/tmp/testVideo.mp4'));

      // Vérifiez que le chemin du fichier dans le résultat est correct
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

    test('finalVideoIsReady returns true', () async {
      const projectPath = '/test/project';
      const projectId = 'testProject';
      const tmpFolder = 'tmp'; // Assurez-vous que cela correspond à $_tmpFolder
      const videoExtension =
          'mp4'; // Assurez-vous que cela correspond à kVideoExtension

      // Stub file gateway to return true
      when(mockFileGateway.exists(any)).thenAnswer((_) => true);

      final result = videoService.finalVideoIsReady(projectPath, projectId);

      // Vérifiez que le chemin complet du fichier est utilisé
      const expectedPath =
          '$projectPath/$tmpFolder/$projectId/final.$videoExtension';
      verify(mockFileGateway.exists(expectedPath)).called(1);

      expect(result, isTrue);
    });
  });
}
