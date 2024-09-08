import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:x_video_ai/controllers/content_controller.dart';
import 'package:x_video_ai/elements/images/box_image_controller.dart';
import 'package:x_video_ai/models/box_image_model.dart';
import 'package:x_video_ai/models/content_model.dart';
import 'package:x_video_ai/services/video_service.dart';
// ignore: depend_on_referenced_packages
import 'package:cross_file/cross_file.dart';
import 'box_image_controller_test.mocks.dart';

@GenerateMocks([VideoService, ContentController])
void main() {
  late MockVideoService mockVideoService;
  late MockContentController mockContentController;
  late ProviderContainer container;

  setUp(() {
    // Initialiser les mocks
    mockVideoService = MockVideoService();
    mockContentController = MockContentController();

    // Simuler un chemin de projet dans le ContentController
    when(mockContentController.state).thenReturn(ContentModel(
      path: '/testProjectPath',
      id: '1',
      name: 'TestProject',
      content: null,
      chronical: null,
      audio: null,
      srt: null,
      srtWithGroup: null,
      assContent: null,
      sections: null,
    ));

    // Créer un ProviderContainer pour tester avec les overrides
    container = ProviderContainer(
      overrides: [
        boxImageControllerProvider.overrideWith(
          (ref) => BoxImageController(
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

  test('should generate and store thumbnail for a video file', () async {
    // Simuler la génération d'une miniature sous forme de byte array
    final Uint8List mockThumbnail = Uint8List.fromList([0, 1, 2, 3, 4]);

    when(mockVideoService.generateThumbnail(
            file: anyNamed('file'), outputPath: anyNamed('outputPath')))
        .thenAnswer((_) async => mockThumbnail);

    // Simuler un fichier vidéo
    final XFile videoFile = XFile('/path/to/video.mp4');

    // Appeler la méthode generateBoxImage
    await container
        .read(boxImageControllerProvider.notifier)
        .generateBoxImage(videoFile, const Key('video1'));

    // Vérifier que l'état contient la miniature générée
    final List<ThumbnailModel> thumbnails =
        container.read(boxImageControllerProvider);
    expect(thumbnails.length, equals(1));
    expect(thumbnails.first.key, equals(const Key('video1')));
    expect(thumbnails.first.thumbnail, equals(mockThumbnail));

    // Vérifier que le service a été appelé avec le bon chemin de projet
    verify(mockVideoService.generateThumbnail(
      file: videoFile,
      outputPath: '/testProjectPath',
    )).called(1);
  });

  test('should return the thumbnail for a given key', () async {
    // Simuler la génération d'une miniature sous forme de byte array
    final Uint8List mockThumbnail = Uint8List.fromList([0, 1, 2, 3, 4]);

    when(mockVideoService.generateThumbnail(
            file: anyNamed('file'), outputPath: anyNamed('outputPath')))
        .thenAnswer((_) async => mockThumbnail);

    // Simuler un fichier vidéo
    final XFile videoFile = XFile('/path/to/video.mp4');

    // Appeler la méthode generateBoxImage
    await container
        .read(boxImageControllerProvider.notifier)
        .generateBoxImage(videoFile, const Key('video1'));

    // Récupérer la miniature avec la méthode getThumbnail
    final Uint8List? thumbnail = container
        .read(boxImageControllerProvider.notifier)
        .getThumbnail(const Key('video1'));

    // Vérifier que la miniature correspond à celle générée
    expect(thumbnail, equals(mockThumbnail));
  });

  test('should return null when no thumbnail is found for a given key',
      () async {
    // Simuler une clé inexistante
    final Uint8List? thumbnail = container
        .read(boxImageControllerProvider.notifier)
        .getThumbnail(const Key('unknown'));

    // Vérifier que la méthode retourne null
    expect(thumbnail, isNull);
  });
}
