import 'dart:typed_data';

// ignore: depend_on_referenced_packages
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/content_controller.dart';
import 'package:x_video_ai/gateway/ffmpeg.dart';
import 'package:x_video_ai/services/video_service.dart';
import 'package:x_video_ai/utils/constants.dart';

class ThumbnailModel {
  final Key key;
  final Uint8List? thumbnail;

  ThumbnailModel({
    required this.key,
    required this.thumbnail,
  });
}

class BoxImageController extends StateNotifier<List<ThumbnailModel>> {
  final VideoService _videoService;
  final ContentController _contentController;

  BoxImageController(
    VideoService videoService,
    ContentController contentController,
  )   : _videoService = videoService,
        _contentController = contentController,
        super([]);

  ThumbnailModel getThumbnailModel(Key key) {
    return state.firstWhere((element) => element.key == key,
        orElse: () =>
            ThumbnailModel(key: const Key('default'), thumbnail: null));
  }

  Uint8List? getThumbnail(Key key) {
    final ThumbnailModel thumbnailModel = getThumbnailModel(key);

    if (thumbnailModel.thumbnail == null) {
      return null;
    }

    return thumbnailModel.thumbnail;
  }

  Future<void> generateThumbnailFromFile(
    XFile file,
    Key key,
  ) async {
    final ThumbnailModel thumbnailModel = getThumbnailModel(key);

    if (thumbnailModel.thumbnail != null) {
      return;
    }

    final String projectPath = _contentController.state.path;
    final Uint8List? thumbnail = await _videoService.generateThumbnail(
      file: file,
      outputPath: projectPath,
    );

    state = [
      ...state,
      ThumbnailModel(
        key: key,
        thumbnail: thumbnail,
      ),
    ];
  }

  Future<void> generateThumbnailFromVideoId(
    String? videoId,
    Key key,
  ) async {
    if (videoId == null) {
      return;
    }

    final ThumbnailModel thumbnailModel = getThumbnailModel(key);

    if (thumbnailModel.thumbnail != null) {
      return;
    }

    final String projectPath = _contentController.state.path;
    final XFile file = XFile('$projectPath/videos/$videoId.$kVideoExtension');

    final Uint8List? thumbnail = await _videoService.generateThumbnail(
      file: file,
      outputPath: projectPath,
      fileName: videoId,
    );

    state = [
      ...state,
      ThumbnailModel(
        key: key,
        thumbnail: thumbnail,
      ),
    ];
  }
}

final boxImageControllerProvider =
    StateNotifierProvider<BoxImageController, List<ThumbnailModel>>(
  (ref) => BoxImageController(
    VideoService(
      FFMpeg(),
    ),
    ref.read(contentControllerProvider.notifier),
  ),
);
