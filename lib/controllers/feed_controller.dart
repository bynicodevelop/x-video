import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/config_controller.dart';
import 'package:x_video_ai/controllers/loading_controller.dart';
import 'package:x_video_ai/models/feed_model.dart';
import 'package:x_video_ai/services/feed_service.dart';
import 'package:x_video_ai/utils/constants.dart';

class FeedController extends StateNotifier<List<FeedModel>> {
  final ConfigController _configController;
  final LoadingController _loadingController;

  FeedController(
    ConfigController configController,
    LoadingController loadingController,
  )   : _configController = configController,
        _loadingController = loadingController,
        super([]);

  List<FeedModel> get feeds => state;

  Future<void> fetch() async {
    _loadingController.startLoading(kLoadingFeeds);

    final FeedService feedService = FeedService(
      feeds: _configController.model?.feeds ?? [],
    );

    state = await feedService.fetch();

    _loadingController.stopLoading(kLoadingFeeds);
  }
}

final feedControllerProvider =
    StateNotifierProvider<FeedController, List<FeedModel>>(
  (ref) => FeedController(
    ref.read(configControllerProvider.notifier),
    ref.read(loadingControllerProvider.notifier),
  ),
);
