import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/config_controller.dart';
import 'package:x_video_ai/controllers/content_controller.dart';
import 'package:x_video_ai/controllers/loading_controller.dart';
import 'package:x_video_ai/gateway/file_getaway.dart';
import 'package:x_video_ai/models/chronical_prompt_model.dart';
import 'package:x_video_ai/services/chronical_service.dart';

class ChronicalController extends StateNotifier<Map<String, dynamic>> {
  final ChronicalService _chronicalService;
  final ContentController _contentController;
  final ConfigController _configController;
  final LoadingController _loadingController;

  ChronicalController(
    ChronicalService chronicalService,
    ContentController contentController,
    ConfigController configController,
    LoadingController loadingController,
  )   : _chronicalService = chronicalService,
        _contentController = contentController,
        _configController = configController,
        _loadingController = loadingController,
        super({});

  Future<void> createChronical() async {
    _loadingController.startLoading('chronical');

    if (_configController.model == null ||
        _configController.model?.apiKeyOpenAi == null ||
        _configController.model?.modelOpenAi == null ||
        _configController.model?.chronicalPrompt == null) {
      _loadingController.stopLoading('chronical');

      throw Exception('Missing configuration');
    }

    if (_contentController.content.content == null) {
      _loadingController.stopLoading('chronical');

      throw Exception('Missing content');
    }

    ChronicalPromptModel chronicalPromptModel = ChronicalPromptModel(
      prompt: _configController.model?.chronicalPrompt ?? '',
      apiKey: _configController.model?.apiKeyOpenAi ?? '',
      model: _configController.model?.modelOpenAi ?? '',
      content: _contentController.content.content!['content'],
    );

    final String chronical = await _chronicalService.createChronical(
      chronicalPromptModel,
    );

    state = {
      'chronical': chronical,
    };

    _loadingController.stopLoading('chronical');
  }
}

final chronicalControllerProvider =
    StateNotifierProvider<ChronicalController, Map<String, dynamic>>(
  (ref) {
    return ChronicalController(
      ChronicalService(
        FileGateway(),
      ),
      ref.read(contentControllerProvider.notifier),
      ref.read(configControllerProvider.notifier),
      ref.read(loadingControllerProvider.notifier),
    );
  },
);
