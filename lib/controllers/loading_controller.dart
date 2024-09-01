import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoadingController extends StateNotifier<Map<String, bool>> {
  LoadingController() : super({});

  bool isLoading(String key) => state[key] ?? false;

  void startLoading(String key) {
    state = {...state, key: true};
  }

  void stopLoading(String key) {
    state = {...state, key: false};
  }
}

final loadingControllerProvider =
    StateNotifierProvider<LoadingController, Map<String, bool>>(
  (ref) => LoadingController(),
);
