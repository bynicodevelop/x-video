import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_video_ai/models/video_model.dart';
import 'package:x_video_ai/controllers/video_data_controller.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('VideoDataControllerProvider', () {
    test('should initialize with an empty list of videos', () {
      final videos = container.read(videoDataControllerProvider);

      expect(videos, isEmpty);
    });

    test('should add a video to the list', () {
      final video = VideoDataModel(
        name: 'test_video.mp4',
        file: null,
        start: 0,
        end: 10,
        duration: 10,
      );

      // Ajouter la vidéo
      container.read(videoDataControllerProvider.notifier).addVideo(video);

      final videos = container.read(videoDataControllerProvider);

      expect(videos.length, equals(1));
      expect(videos.first.name, equals('test_video.mp4'));
    });

    test('should remove a video from the list', () {
      final video = VideoDataModel(
        name: 'test_video.mp4',
        file: null,
        start: 0,
        end: 10,
        duration: 10,
      );

      // Ajouter la vidéo
      container.read(videoDataControllerProvider.notifier).addVideo(video);

      // Supprimer la vidéo
      container.read(videoDataControllerProvider.notifier).removeVideo(video);

      final videos = container.read(videoDataControllerProvider);

      expect(videos, isEmpty);
    });

    test('should update an existing video in the list', () {
      final originalVideo = VideoDataModel(
        name: 'test_video.mp4',
        file: null,
        start: 0,
        end: 10,
        duration: 10,
      );

      final updatedVideo = VideoDataModel(
        name: 'test_video.mp4',
        file: null,
        start: 0,
        end: 20,
        duration: 20,
      );

      // Ajouter la vidéo
      container
          .read(videoDataControllerProvider.notifier)
          .addVideo(originalVideo);

      // Mettre à jour la vidéo
      container
          .read(videoDataControllerProvider.notifier)
          .updateVideo(updatedVideo);

      final videos = container.read(videoDataControllerProvider);

      expect(videos.length, equals(1));
      expect(videos.first.duration, equals(20));
    });

    test('should return the selected video', () {
      final video1 = VideoDataModel(
        name: 'video1.mp4',
        file: null,
        start: 0,
        end: 10,
        duration: 10,
      );

      final video2 = VideoDataModel(
        name: 'video2.mp4',
        file: null,
        start: 0,
        end: 15,
        duration: 15,
        selected: true,
      );

      // Ajouter les vidéos
      container.read(videoDataControllerProvider.notifier).addVideo(video1);
      container.read(videoDataControllerProvider.notifier).addVideo(video2);

      final selectedVideo =
          container.read(videoDataControllerProvider.notifier).selectedVideo;

      expect(selectedVideo.name, equals('video2.mp4'));
    });

    test('should return the default video when no video is selected', () {
      final video = VideoDataModel(
        name: 'video1.mp4',
        file: null,
        start: 0,
        end: 10,
        duration: 10,
      );

      // Ajouter la vidéo
      container.read(videoDataControllerProvider.notifier).addVideo(video);

      final selectedVideo =
          container.read(videoDataControllerProvider.notifier).selectedVideo;

      expect(selectedVideo.name, equals(''));
    });
  });
}
