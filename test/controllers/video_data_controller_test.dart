import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:x_video_ai/controllers/content_controller.dart';
import 'package:x_video_ai/models/content_model.dart';
import 'package:x_video_ai/models/video_model.dart';
import 'package:x_video_ai/services/video_config_service.dart';
import 'package:x_video_ai/controllers/video_data_controller.dart';

import 'video_data_controller_test.mocks.dart';

@GenerateMocks([VideoConfigService, ContentController])
void main() {
  late MockVideoConfigService mockVideoConfigService;
  late MockContentController mockContentController;
  late ProviderContainer container;

  setUp(() {
    // Initialiser les mocks
    mockVideoConfigService = MockVideoConfigService();
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
        videoDataControllerProvider.overrideWith(
          (ref) => VideoDataControllerProvider(
            mockVideoConfigService,
            mockContentController,
          ),
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('should load videos from the service', () {
    // Simuler les vidéos à retourner par le service
    final List<VideoDataModel> mockVideos = [
      VideoDataModel(name: 'Video1', duration: 60, start: 0, end: 60),
      VideoDataModel(name: 'Video2', duration: 120, start: 0, end: 120),
    ];

    when(mockVideoConfigService.loadVideos(any)).thenReturn(mockVideos);

    // Appeler la méthode loadVideos
    container.read(videoDataControllerProvider.notifier).loadVideos();

    // Vérifier que les vidéos sont chargées dans le state
    final List<VideoDataModel> videos =
        container.read(videoDataControllerProvider);
    expect(videos.length, equals(2));
    expect(videos[0].name, equals('Video1'));
    expect(videos[1].name, equals('Video2'));

    // Vérifier que le service a été appelé avec le bon chemin de projet
    verify(mockVideoConfigService.loadVideos('/testProjectPath')).called(1);
  });

  test('should add a new video and save it', () {
    final newVideo =
        VideoDataModel(name: 'NewVideo', duration: 90, start: 0, end: 90);

    // Simuler l'ajout de la vidéo
    when(mockVideoConfigService.saveVideos(any, any))
        .thenAnswer((_) async => {});

    // Appeler la méthode addVideo
    container.read(videoDataControllerProvider.notifier).addVideo(newVideo);

    // Vérifier que la vidéo a été ajoutée dans le state
    final List<VideoDataModel> videos =
        container.read(videoDataControllerProvider);
    expect(videos.length, equals(1));
    expect(videos[0].name, equals('NewVideo'));

    // Vérifier que le service a sauvegardé la vidéo
    verify(mockVideoConfigService.saveVideos(newVideo, '/testProjectPath'))
        .called(1);
  });
}
