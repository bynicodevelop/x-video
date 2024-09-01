import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/config_controller.dart';
import 'package:x_video_ai/controllers/loading_controller.dart';
import 'package:x_video_ai/models/feed_model.dart';
import 'package:x_video_ai/services/feed_service.dart';

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
    _loadingController.startLoading('feeds');

    final FeedService feedService = FeedService(
      feeds: _configController.model?.feeds ?? [],
    );

    state = await feedService.fetch();

    // state = [
    //   FeedModel(
    //     title: "coucou",
    //     date: DateTime.now(),
    //     domain: "coucou",
    //     description: "coucou",
    //     link:
    //         "https://fr.investing.com/news/commodities-news/lor-chute-face-a-la-menace-de-lindice-pce-a-la-fin-dun-solide-mois-daout-2545687",
    //   ),
    // ];
    _loadingController.stopLoading('feeds');
  }
}

final feedControllerProvider =
    StateNotifierProvider<FeedController, List<FeedModel>>(
  (ref) => FeedController(
    ref.read(configControllerProvider.notifier),
    ref.read(loadingControllerProvider.notifier),
  ),
);
