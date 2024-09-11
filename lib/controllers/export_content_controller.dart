import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/config_controller.dart';
import 'package:x_video_ai/controllers/loading_controller.dart';
import 'package:x_video_ai/gateway/file_getaway.dart';
import 'package:x_video_ai/services/content_extractor_service.dart';

class ExportContentController extends StateNotifier {
  final ConfigController _configController;
  final LoadingController _loadingController;
  final ContentExtractorService _contentExtractorService;

  ExportContentController(
    ConfigController configController,
    LoadingController loadingController,
    ContentExtractorService contentExtractorService,
  )   : _configController = configController,
        _loadingController = loadingController,
        _contentExtractorService = contentExtractorService,
        super(null);

  void exportContent(
    Map<String, dynamic> content,
  ) {
    _loadingController.isLoading('export_content');

    _contentExtractorService.extractContent(
      {
        'title': content['title'],
        'content': content['content'],
        'link': content['model'].link,
      },
      "${_configController.configService!.model!.path}/${_configController.configService!.model!.name}",
    );

    _loadingController.isLoading('export_content');
  }
}

final exportContentControllerProvider =
    StateNotifierProvider<ExportContentController, void>((ref) {
  return ExportContentController(
    ref.read(configControllerProvider.notifier),
    ref.read(loadingControllerProvider.notifier),
    ContentExtractorService(
      FileGateway(),
    ),
  );
});
