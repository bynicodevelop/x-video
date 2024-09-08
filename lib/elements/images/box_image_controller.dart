import 'dart:typed_data';

// ignore: depend_on_referenced_packages
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/content_controller.dart';
import 'package:x_video_ai/gateway/ffmpeg.dart';
import 'package:x_video_ai/services/video_service.dart';

class BoxImageModel {
  final Key key;
  final Uint8List? thumbnail;

  BoxImageModel({
    required this.key,
    required this.thumbnail,
  });
}

class BoxImageController extends StateNotifier<List<BoxImageModel>> {
  final VideoService _videoService;
  final ContentController _contentController;

  BoxImageController(
    VideoService videoService,
    ContentController contentController,
  )   : _videoService = videoService,
        _contentController = contentController,
        super([]);

  Uint8List? getThumbnail(Key key) {
    final BoxImageModel boxImageModel = state.firstWhere(
        (element) => element.key == key,
        orElse: () =>
            BoxImageModel(key: const Key('default'), thumbnail: null));

    if (boxImageModel.thumbnail == null) {
      return null;
    }

    return boxImageModel.thumbnail;
  }

  Future<void> generateBoxImage(
    XFile file,
    Key key,
  ) async {
    final String projectPath = _contentController.state.path;
    print(projectPath);

    final Uint8List? thumbnail = await _videoService.generateThumbnail(
      file: file,
      outputPath: projectPath,
    );

    state = [
      ...state,
      BoxImageModel(
        key: key,
        thumbnail: thumbnail,
      ),
    ];
  }
}

final boxImageControllerProvider =
    StateNotifierProvider<BoxImageController, List<BoxImageModel>>(
  (ref) => BoxImageController(
    VideoService(
      FFMpeg(),
    ),
    ref.read(contentControllerProvider.notifier),
  ),
);
