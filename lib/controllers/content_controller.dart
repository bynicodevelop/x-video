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
    String path,
  )   : _contentService = contentService,
        _loadingController = loadingController,
        super(ContentModel(
          path: path,
        ));

  bool get isInitialized => state.id.isNotEmpty;
  bool get hasChronical => state.chronical != null && state.chronical!['content'] != null;

  ContentModel get content => state;

  void initContent(
    ContentModel contentModel,
  ) {
    if (contentModel.path.isEmpty) {
      throw Exception("Path is required");
    }

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

  void setChronical(
    String content,
  ) {
    state = state.mergeWith({
      "chronical": {
        "content": content,
      },
    });
  }

  void save() {
    _loadingController.startLoading(kLoadingContent);
    _contentService.saveContent(state);
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
    const ContentService(),
    ref.read(loadingControllerProvider.notifier),
    path,
  );
});
