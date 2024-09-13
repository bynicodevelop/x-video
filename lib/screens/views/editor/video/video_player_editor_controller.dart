import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:x_video_ai/controllers/content_controller.dart';
import 'package:x_video_ai/models/video_section_model.dart';
import 'package:x_video_ai/utils/constants.dart';

class VideoPlayerData {
  final String? path;
  final VideoSectionModel section;
  final double duration;
  final bool isPlaying;

  VideoPlayerData({
    required this.path,
    required this.duration,
    required this.section,
    this.isPlaying = false,
  });

  VideoPlayerData mergeWith({
    String? path,
    double? duration,
    VideoSectionModel? section,
    bool? isPlaying,
  }) {
    return VideoPlayerData(
      path: path ?? this.path,
      duration: duration ?? this.duration,
      section: section ?? this.section,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}

class VideoPlayerEditorController extends StateNotifier<Map<String, dynamic>> {
  final ContentController _contentController;
  VideoPlayerController? videoPlayerController;
  VideoPlayerController? _nextVideoPlayerController;
  int _currentVideoIndex = 0;
  bool _isTransitioning = false;

  VideoPlayerEditorController(
    ContentController contentController,
  )   : _contentController = contentController,
        super({
          'videos': [],
          'isPlaying': false,
          'index': 0,
        });

  bool get isPlayingState => state['isPlaying'];

  int get currentVideoIndex => state['index'];

  void initVideoPlayerEditor(
    List<VideoSectionModel> sections,
  ) {
    final String projectPath = _contentController.state.path;

    final List<VideoPlayerData> videoPlayerData = sections.map(
      (section) {
        return VideoPlayerData(
          path: "$projectPath/videos/${section.fileName}.$kVideoExtension",
          duration: section.duration,
          section: section,
          isPlaying: false,
        );
      },
    ).toList();

    _currentVideoIndex = 0;

    state = {
      'videos': videoPlayerData,
      'isPlaying': true,
      'index': _currentVideoIndex,
    };

    if (videoPlayerData.isNotEmpty) {
      _initializeAndPlayVideo(videoPlayerData.first);
      _updateIsPlayingState(true, videoPlayerData.first);
    }
  }

  void _updateIsPlayingState(
    bool isPlaying,
    VideoPlayerData videoPlayerData,
  ) {
    state = {
      'videos': List<VideoPlayerData>.from(state['videos']).map((videoData) {
        if (videoData.path == videoPlayerData.path) {
          return videoData.mergeWith(
            isPlaying: isPlaying,
          );
        }

        return videoData;
      }).toList(),
      'isPlaying': isPlaying,
      'index': _currentVideoIndex,
    };
  }

  Future<void> _initializeAndPlayVideo(
    VideoPlayerData videoPlayerData,
  ) async {
    if (_isTransitioning) return;
    _isTransitioning = true;

    if (_nextVideoPlayerController != null) {
      videoPlayerController = _nextVideoPlayerController;
    } else {
      if (videoPlayerController != null) {
        await videoPlayerController!.dispose();
      }

      videoPlayerController =
          VideoPlayerController.file(File(videoPlayerData.path!));

      await videoPlayerController!.initialize();
    }

    videoPlayerController!.addListener(() {
      listener(videoPlayerController!, videoPlayerData);
    });

    playVideo();
    _isTransitioning = false;

    // Précharger la prochaine vidéo après avoir démarré la lecture
    _preloadNextVideo();
  }

  Future<void> _preloadNextVideo() async {
    final int nextIndex = _currentVideoIndex + 1;
    if (nextIndex < state['videos'].length) {
      final nextVideoData = state['videos'][nextIndex];
      _nextVideoPlayerController =
          VideoPlayerController.file(File(nextVideoData.path!));

      await _nextVideoPlayerController!.initialize();
    }
  }

  void listener(
    VideoPlayerController controller,
    VideoPlayerData videoPlayerData,
  ) async {
    final isEndOfVideo = controller.value.position == controller.value.duration;

    final isMaxDurationReached = controller.value.position >=
        Duration(milliseconds: (videoPlayerData.duration * 1000).round());

    if ((isEndOfVideo || isMaxDurationReached) && !_isTransitioning) {
      await nextVideo();
    }
  }

  Future<void> nextVideo() async {
    if (_currentVideoIndex < state['videos'].length - 1) {
      _currentVideoIndex++;

      // Utiliser le contrôleur vidéo préchargé pour la prochaine vidéo
      await _initializeAndPlayVideo(state['videos'][_currentVideoIndex]);
      _updateIsPlayingState(true, state['videos'][_currentVideoIndex]);
    }
  }

  void playVideo() {
    state = {
      ...state,
      'isPlaying': true,
    };

    videoPlayerController?.play();
  }

  void pauseVideo() {
    state = {
      ...state,
      'isPlaying': false,
    };
    videoPlayerController?.pause();
  }

  @override
  void dispose() {
    videoPlayerController?.dispose();
    _nextVideoPlayerController?.dispose(); // Libérer le contrôleur préchargé
    super.dispose();
  }
}

final videoPlayerEditorControllerProvider =
    StateNotifierProvider<VideoPlayerEditorController, Map<String, dynamic>>(
  (ref) => VideoPlayerEditorController(
    ref.read(contentControllerProvider.notifier),
  ),
);
