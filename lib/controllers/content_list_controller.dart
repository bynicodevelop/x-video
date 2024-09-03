import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  void loadContents(String path) {
    _loadingController.startLoading(kLoadingContent);
    state = _contentService.loadContents(
      path,
    );
    _loadingController.stopLoading(kLoadingContent);
  }
}

final contentListControllerProvider =
    StateNotifierProvider<ContentListController, List<ContentModel>>((ref) {
  return ContentListController(
    const ContentService(),
    ref.read(loadingControllerProvider.notifier),
  );
});
