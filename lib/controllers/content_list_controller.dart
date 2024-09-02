import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/config_controller.dart';
import 'package:x_video_ai/controllers/loading_controller.dart';
import 'package:x_video_ai/models/content_model.dart';
import 'package:x_video_ai/services/content_service.dart';
import 'package:x_video_ai/utils/constants.dart';

class ContentListController extends StateNotifier<List<ContentModel>> {
  final ContentService _contentService;
  final LoadingController _loadingController;

  ContentListController(
    ContentService contentService,
    LoadingController loadingController,
  )   : _contentService = contentService,
        _loadingController = loadingController,
        super([]);

  List<ContentModel> get contentList => state;

  void loadContents() {
    _loadingController.startLoading(kLoadingContent);

    state = _contentService.loadContents();

    _loadingController.stopLoading(kLoadingContent);
  }
}

final contentListControllerProvider =
    StateNotifierProvider<ContentListController, List<ContentModel>>((ref) {
  final ConfigController configController =
      ref.read(configControllerProvider.notifier);
  final String path =
      "${configController.configService?.model?.path}/${configController.configService?.model?.name}";

  return ContentListController(
    ContentService(path),
    ref.read(loadingControllerProvider.notifier),
  );
});
