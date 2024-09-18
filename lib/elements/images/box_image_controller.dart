import 'dart:typed_data';

// ignore: depend_on_referenced_packages
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/content_controller.dart';
import 'package:x_video_ai/gateway/ffmpeg.dart';
import 'package:x_video_ai/gateway/file_getaway.dart';
import 'package:x_video_ai/services/video_service.dart';
import 'package:x_video_ai/utils/constants.dart';

enum ImageState {
  idle,
  loading,
  loaded,
  error,
}

class ImageModel {
  final Key key;
  final String? videoId;
  final Uint8List? thumbnail;
  final ImageState state;

  ImageModel({
    required this.key,
    required this.thumbnail,
    this.videoId,
    this.state = ImageState.idle,
  });

  factory ImageModel.empty(Key key) {
    return ImageModel(
      key: key,
      thumbnail: null,
      videoId: null,
      state: ImageState.idle,
    );
  }

  bool isEmpty() {
    return thumbnail == null || state == ImageState.idle;
  }

  ImageModel mergeWith({
    Key? key,
    String? videoId,
    Uint8List? thumbnail,
    ImageState? state,
  }) {
    return ImageModel(
      key: key ?? this.key,
      videoId: videoId ?? this.videoId,
      thumbnail: thumbnail ?? this.thumbnail,
      state: state ?? this.state,
    );
  }

  toJson() {
    return {
      'key': key.toString(),
      'videoId': videoId,
      'thumbnail': thumbnail,
      'state': state.toString(),
    };
  }
}

class BoxImageController extends StateNotifier<List<ImageModel>> {
  final VideoService _videoService;
  final ContentController _contentController;

  BoxImageController(
    VideoService videoService,
    ContentController contentController,
  )   : _videoService = videoService,
        _contentController = contentController,
        super([]);

  ImageModel getThumbnailModel(Key key) {
    return state.firstWhere(
      (element) => element.key == key,
      orElse: () => ImageModel(
        key: key,
        thumbnail: null,
        state: ImageState.idle,
        videoId: null,
      ),
    );
  }

  Uint8List? getThumbnail(Key key) {
    final ImageModel thumbnailModel = getThumbnailModel(key);

    if (thumbnailModel.thumbnail == null) {
      return null;
    }

    return thumbnailModel.thumbnail;
  }

  Future<void> generateThumbnailFromVideoId(
    String? videoId,
    Key key,
  ) async {
    ImageModel imageModel = getThumbnailModel(key);

    if (imageModel.isEmpty()) {
      imageModel = imageModel.mergeWith(
        key: key,
        state: videoId != null ? ImageState.loading : ImageState.loaded,
        videoId: videoId,
      );
    }

    state = [
      ...state,
      imageModel,
    ];

    final String projectPath = _contentController.state.path;
    final XFile file = XFile('$projectPath/videos/$videoId.$kVideoExtension');
    Uint8List? thumbnail;

    try {
      thumbnail = await _videoService.generateThumbnail(
        file: file,
        outputPath: projectPath,
        fileName: videoId,
      );

      imageModel = imageModel.mergeWith(
        thumbnail: thumbnail,
        state: ImageState.loaded,
      );

      state = state.map((element) {
        if (element.key == key) {
          return imageModel;
        }

        return element;
      }).toList();
    } catch (e) {
      imageModel = imageModel.mergeWith(
        state: ImageState.error,
      );

      state = state.map((element) {
        if (element.key == key) {
          return imageModel;
        }

        return element;
      }).toList();
    }
  }
}

final boxImageControllerProvider =
    StateNotifierProvider<BoxImageController, List<ImageModel>>(
  (ref) => BoxImageController(
    VideoService(
      FileGateway(),
      FFMpeg(),
    ),
    ref.read(contentControllerProvider.notifier),
  ),
);
