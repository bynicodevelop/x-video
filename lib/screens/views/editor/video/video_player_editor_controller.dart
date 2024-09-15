import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:x_video_ai/controllers/content_controller.dart';
import 'package:x_video_ai/models/video_section_model.dart';
import 'package:x_video_ai/utils/constants.dart';
import 'package:just_audio/just_audio.dart';

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
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ContentController _contentController;
  VideoPlayerController? _videoPlayerController;
  VideoPlayerController? _nextVideoPlayerController;
  int _currentVideoIndex = 0;
  bool _isTransitioning = false;

  VideoPlayerEditorController(
    ContentController contentController,
  )   : _contentController = contentController,
        super({
          'videos': [],
          'isPlaying': false, // Défini à false ici
          'index': 0,
          'isPlayable': false,
        });

  bool get isPlayingState => state['isPlaying'];

  bool get isPlayable => state['isPlayable'];

  int get currentVideoIndex => state['index'];

  VideoPlayerController? get videoPlayerController => _videoPlayerController;

  Future<void> initVideoPlayerEditor(
    List<VideoSectionModel> sections,
  ) async {
    final String projectPath = _contentController.state.path;
    final String projectId = _contentController.state.id;

    final isPlayable = sections.every((section) {
      return section.fileName != null;
    });

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
      'isPlaying': false, // Défini à false ici
      'index': _currentVideoIndex,
      'isPlayable': isPlayable,
    };

    if (!isPlayable) return;

    await _audioPlayer
        .setFilePath("$projectPath/contents/$projectId.$kAudioExtension");
    await _audioPlayer.seek(Duration.zero); // Positionner l'audio à zéro

    if (videoPlayerData.isNotEmpty) {
      await _initializeAndPlayVideo(videoPlayerData.first);
      _updateIsPlayingState(false, videoPlayerData.first); // isPlaying à false
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
      'isPlayable': true,
    };
  }

  Future<void> _initializeAndPlayVideo(
    VideoPlayerData videoPlayerData,
  ) async {
    if (_isTransitioning) return;
    _isTransitioning = true;

    if (_nextVideoPlayerController != null) {
      _videoPlayerController = _nextVideoPlayerController;
    } else {
      if (_videoPlayerController != null) {
        await _videoPlayerController!.dispose();
      }

      _videoPlayerController =
          VideoPlayerController.file(File(videoPlayerData.path!));

      await _videoPlayerController!.initialize();
      await _videoPlayerController!
          .seekTo(Duration.zero); // Positionner la vidéo à zéro
    }

    _videoPlayerController!.addListener(() {
      listener(_videoPlayerController!, videoPlayerData);
    });

    _isTransitioning = false;
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

      await _initializeAndPlayVideo(state['videos'][_currentVideoIndex]);

      // Démarrer la lecture si elle est en cours
      if (isPlayingState) {
        playVideo();
      }

      _updateIsPlayingState(
          isPlayingState, state['videos'][_currentVideoIndex]);
    }
  }

  void playVideo() {
    if (_videoPlayerController?.value.isInitialized == true &&
        _audioPlayer.playerState.processingState == ProcessingState.ready) {
      _videoPlayerController!.play();
      _audioPlayer.play();
      _updateIsPlayingState(true, state['videos'][_currentVideoIndex]);
    }
  }

  void pauseVideo() {
    _updateIsPlayingState(false, state['videos'][_currentVideoIndex]);

    _videoPlayerController?.pause();
    _audioPlayer.pause();
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _nextVideoPlayerController?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}

final videoPlayerEditorControllerProvider =
    StateNotifierProvider<VideoPlayerEditorController, Map<String, dynamic>>(
  (ref) => VideoPlayerEditorController(
    ref.read(contentControllerProvider.notifier),
  ),
);
