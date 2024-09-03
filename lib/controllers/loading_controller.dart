import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/models/progress_state_model.dart';

class LoadingController extends StateNotifier<Map<String, dynamic>> {
  LoadingController() : super({});

  bool isLoading(String key) => state[key] ?? false;

  ProgressStateModel? get progressState => state['progressState'];

  void startLoading(
    String key, {
    ProgressStateModel? progressState,
  }) {
    state = {
      ...state,
      key: true,
      'progressState': progressState,
    };
  }

  void stopLoading(String key) {
    state = {
      ...state,
      key: false,
    };
  }

  void updateLoadingState(
    String key, {
    ProgressStateModel? progressState,
  }) {
    state = {
      ...state,
      'progressState': progressState,
    };
  }
}

final loadingControllerProvider =
    StateNotifierProvider<LoadingController, Map<String, dynamic>>(
  (ref) => LoadingController(),
);
