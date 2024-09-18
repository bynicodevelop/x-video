import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/content_controller.dart';
import 'package:x_video_ai/gateway/ffmpeg.dart';
import 'package:x_video_ai/gateway/file_getaway.dart';
import 'package:x_video_ai/services/video_service.dart';

class MediaVideoControllerProvider extends StateNotifier<void> {
  final ContentController _contentController;
  final VideoService _videoService;

  MediaVideoControllerProvider(
    ContentController contentController,
    VideoService videoService,
  )   : _contentController = contentController,
        _videoService = videoService,
        super(null);
}

final mediaVideoControllerProvider = StateNotifierProvider.autoDispose(
  (ref) => MediaVideoControllerProvider(
    ref.read(contentControllerProvider.notifier),
    VideoService(
      FileGateway(),
      FFMpeg(),
    ),
  ),
);
