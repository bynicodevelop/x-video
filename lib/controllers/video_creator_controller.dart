import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/content_controller.dart';
import 'package:x_video_ai/gateway/ffmpeg.dart';
import 'package:x_video_ai/gateway/file_getaway.dart';
import 'package:x_video_ai/models/video_creator_state.dart';
import 'package:x_video_ai/models/video_section_model.dart';
import 'package:x_video_ai/services/video_service.dart';

class VideoCreatorController extends StateNotifier<VideoCreatorState> {
  final VideoService _videoService;
  final ContentController _contentController;

  VideoCreatorController(
    VideoService videoService,
    ContentController contentController,
  )   : _videoService = videoService,
        _contentController = contentController,
        super(VideoCreatorState());

  bool get hasPrepared => state.hasPrepared;
  double get prepareProgress => state.prepareProgress;
  bool get hasConcatenated => state.hasConcatenated;
  double get concatenateProgress => state.concatenateProgress;
  bool get hasAddedAudios => state.hasAddedAudios;
  double get addAudiosProgress => state.addAudiosProgress;
  bool get hasAddedSubtitles => state.hasAddedSubtitles;
  double get addSubtitlesProgress => state.addSubtitlesProgress;
  bool get isFinished => state.isFinished;

  Future<void> startWorkflow() async {
    final String projectPath = _contentController.state.path;
    final String projectId = _contentController.state.id;
    final String assContent = _contentController.content.assContent!['content'];

    final List<VideoSectionModel> sections = _contentController
        .content.sections?['content']
        .map((e) => VideoSectionModel.fromJson(e))
        .whereType<VideoSectionModel>()
        .toList();

    final bool isReady =
        _videoService.finalVideoIsReady(projectPath, projectId);

    if (isReady) {
      state = state.mergeWith(
        hasPrepared: true,
        prepareProgress: 100.0,
        hasConcatenated: true,
        concatenateProgress: 100.0,
        hasAddedAudios: true,
        addAudiosProgress: 100.0,
        hasAddedSubtitles: true,
        addSubtitlesProgress: 100.0,
        isFinished: true,
      );

      return;
    }

    await _cutVideos(
      sections,
      projectPath,
      projectId,
      (progress) {
        state = state.mergeWith(
          hasPrepared: true,
          prepareProgress: progress / 100,
        );
      },
    );

    await _concatenateVideos(
      sections,
      projectPath,
      projectId,
      (progress) {
        state = state.mergeWith(
          hasConcatenated: true,
          concatenateProgress: progress / 100,
        );
      },
    );

    await _concatenateAudio(
      projectPath,
      projectId,
      (progress) {
        state = state.mergeWith(
          hasAddedAudios: true,
          addAudiosProgress: progress / 100,
        );
      },
    );

    await _addSubtitles(
      projectPath,
      projectId,
      assContent,
      (progress) {
        state = state.mergeWith(
          hasAddedSubtitles: true,
          addSubtitlesProgress: progress / 100,
        );
      },
    );
  }

  String getFinalVideoPath() {
    final String projectPath = _contentController.state.path;
    final String projectId = _contentController.state.id;

    return _videoService.getFinalVideoPath(
      projectPath,
      projectId,
    );
  }

  Future<void> _cutVideos(
    List<VideoSectionModel> sections,
    String projectPath,
    String projectId,
    void Function(double progress) onProgress,
  ) async {
    final int totalSections = sections.length;

    final List<double> segmentProgresses =
        List<double>.filled(totalSections, 0.0);

    double lastOverallProgress = 0.0;

    final List<Future<void> Function()> processes = [];

    for (int index = 0; index < sections.length; index++) {
      final section = sections[index];

      processes.add(() async {
        await _videoService.cutSegment(
          section,
          projectPath,
          projectId,
          (double segmentProgress) {
            segmentProgresses[index] = segmentProgress / 100;

            final double totalProgress =
                (segmentProgresses.reduce((a, b) => a + b) / totalSections) *
                    100;

            if (totalProgress >= lastOverallProgress) {
              lastOverallProgress = totalProgress;
              onProgress(lastOverallProgress.clamp(0.0, 100.0));
            }
          },
        );

        segmentProgresses[index] = 1.0;

        final double totalProgress =
            (segmentProgresses.reduce((a, b) => a + b) / totalSections) * 100;

        if (totalProgress >= lastOverallProgress) {
          lastOverallProgress = totalProgress;
          onProgress(lastOverallProgress.clamp(0.0, 100.0));
        }
      });
    }

    await queueManager(
      processes,
      2,
    );

    if (lastOverallProgress < 100.0) {
      lastOverallProgress = 100.0;
      onProgress(100.0);
    }
  }

  Future<void> _concatenateVideos(
    List<VideoSectionModel> sections,
    String projectPath,
    String projectId,
    void Function(double progress) onProgress,
  ) async {
    await _videoService.concatenateVideos(
      sections,
      projectPath,
      projectId,
      onProgress,
    );
  }

  Future<void> _concatenateAudio(
    String projectPath,
    String projectId,
    void Function(double progress) onProgress,
  ) async {
    await _videoService.concatenateAudios(
      projectPath,
      projectId,
      onProgress,
    );
  }

  Future<void> _addSubtitles(
    String projectPath,
    String projectId,
    String assContent,
    void Function(double progress) onProgress,
  ) async {
    await _videoService.addSubtitles(
      projectPath,
      projectId,
      assContent,
      onProgress,
    );
  }

  Future<void> queueManager(
    List<Future<void> Function()> processes,
    int numberProcess,
  ) async {
    final queue = Queue<Future<void> Function()>();
    queue.addAll(processes);

    final List<Future<void>> activeProcesses = [];

    while (queue.isNotEmpty || activeProcesses.isNotEmpty) {
      while (activeProcesses.length < numberProcess && queue.isNotEmpty) {
        final process = queue.removeFirst();
        final future = process();
        activeProcesses.add(future);

        future.whenComplete(() {
          activeProcesses.remove(future);
        });
      }

      if (activeProcesses.isNotEmpty) {
        await Future.any(activeProcesses);
      }
    }
  }
}

final videoCreatorControllerProvider =
    StateNotifierProvider<VideoCreatorController, VideoCreatorState>(
  (ref) => VideoCreatorController(
    VideoService(
      FileGateway(),
      FFMpeg(),
    ),
    ref.read(contentControllerProvider.notifier),
  ),
);
