import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/loading_controller.dart';
import 'package:x_video_ai/models/link_model.dart';
import 'package:x_video_ai/services/parse_service.dart';
import 'package:x_video_ai/utils/constants.dart';

class ReaderContentController extends StateNotifier<Map<String, dynamic>?> {
  final ParseService _parseService;
  final LoadingController _loadingController;

  ReaderContentController(
    LoadingController loadingController,
    ParseService parseService,
  )   : _loadingController = loadingController,
        _parseService = parseService,
        super(null);

  Map<String, dynamic>? get content => state;

  Future<void> loadContent(
    LinkModel feedModel,
  ) async {
    _loadingController.startLoading(kLoadingReader);

    try {
      final Map<String, String> content = await _parseService.parseUrl(
        feedModel.link,
      );

      state = {
        ...content,
        'model': feedModel,
      };
    } catch (e) {
      state = null;
    } finally {
      _loadingController.stopLoading(kLoadingReader);
    }
  }
}

final readerContentControllerProvider =
    StateNotifierProvider<ReaderContentController, Map<String, dynamic>?>(
  (ref) => ReaderContentController(
    ref.read(loadingControllerProvider.notifier),
    ParseService(),
  ),
);
