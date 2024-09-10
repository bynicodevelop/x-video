import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/content_controller.dart';
import 'package:x_video_ai/models/video_model.dart';
import 'package:x_video_ai/services/video_config_service.dart';

class VideoDataControllerProvider extends StateNotifier<List<VideoDataModel>> {
  final VideoConfigService _videoConfigService;
  final ContentController _contentController;

  VideoDataControllerProvider(
    VideoConfigService videoConfigService,
    ContentController contentController,
  )   : _videoConfigService = videoConfigService,
        _contentController = contentController,
        super([]);

  List<VideoDataModel> get videos => state;

  void loadVideos() {
    state = _videoConfigService.loadVideos(
      _contentController.state.path,
    );
  }

  void addVideo(
    VideoDataModel video,
  ) {
    state = [...state, video];

    _videoConfigService.saveVideos(
      video,
      _contentController.state.path,
    );
  }
}

final videoDataControllerProvider =
    StateNotifierProvider<VideoDataControllerProvider, List<VideoDataModel>>(
  (ref) => VideoDataControllerProvider(
    VideoConfigService(),
    ref.read(contentControllerProvider.notifier),
  ),
);
