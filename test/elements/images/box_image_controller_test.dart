import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:x_video_ai/controllers/content_controller.dart';
import 'package:x_video_ai/elements/images/box_image_controller.dart';
import 'package:x_video_ai/models/content_model.dart';
import 'package:x_video_ai/services/video_service.dart';

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
