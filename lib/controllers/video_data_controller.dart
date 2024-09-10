import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/models/video_model.dart';

class VideoDataControllerProvider extends StateNotifier<List<VideoDataModel>> {
  VideoDataControllerProvider() : super([]);

  List<VideoDataModel> get videos => state;

  VideoDataModel getVideoByName(
    String name,
  ) {
    return state.firstWhere(
      (v) => v.name == name,
      orElse: () => VideoDataModel.getDefault(),
    );
  }

  void addVideo(
    VideoDataModel video,
  ) {
    state = [...state, video];
  }

  void removeVideo(
    VideoDataModel video,
  ) {
    state = state.where((v) => v.name != video.name).toList();
  }

  void updateVideo(
    VideoDataModel video,
  ) {
    state = state.map((v) {
      if (v.name == video.name) {
        return video;
      }
      return v;
    }).toList();
  }
}

final videoDataControllerProvider =
    StateNotifierProvider<VideoDataControllerProvider, List<VideoDataModel>>(
  (ref) => VideoDataControllerProvider(),
);
