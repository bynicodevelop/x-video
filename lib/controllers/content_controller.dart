import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/config_controller.dart';
import 'package:x_video_ai/controllers/loading_controller.dart';
import 'package:x_video_ai/models/content_model.dart';
import 'package:x_video_ai/services/content_service.dart';
import 'package:x_video_ai/utils/constants.dart';

class ContentController extends StateNotifier<ContentModel> {
  final ContentService _contentService;
  final LoadingController _loadingController;

  ContentController(
    ContentService contentService,
    LoadingController loadingController,
  )   : _contentService = contentService,
        _loadingController = loadingController,
        super(ContentModel());

  bool get isInitialized => state.id.isNotEmpty;

  void initContent(ContentModel contentModel) {
    state = contentModel;
  }

  void setContent(
    String title,
    String content,
  ) {
    state = state.mergeWith({
      "content": {
        "title": title,
        "content": content,
      },
    });
  }

  void save() {
    _loadingController.startLoading(kLoadingContent);

    _contentService.saveContent(
      state,
      contentName: "1725218992775",
    );

    _loadingController.startLoading(kLoadingContent);
  }
}

final contentControllerProvider =
    StateNotifierProvider<ContentController, ContentModel>((ref) {
  final ConfigController configController =
      ref.read(configControllerProvider.notifier);
  final String path =
      "${configController.configService?.model?.path}/${configController.configService?.model?.name}";

  return ContentController(
    ContentService(path),
    ref.read(loadingControllerProvider.notifier),
  );
});
