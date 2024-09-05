import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/config_controller.dart';
import 'package:x_video_ai/controllers/content_controller.dart';
import 'package:x_video_ai/controllers/loading_controller.dart';
import 'package:x_video_ai/gateway/open_ai_gateway.dart';
import 'package:x_video_ai/models/open_ai_config_model.dart';
import 'package:x_video_ai/models/progress_state_model.dart';
import 'package:x_video_ai/models/srt_sentence_model.dart';
import 'package:x_video_ai/services/audio_service.dart';
import 'package:x_video_ai/utils/constants.dart';

class VideoDataGeneratorController extends StateNotifier<ProgressStateModel> {
  final AudioService _audioService;
  final ContentController _contentController;
  final ConfigController _configController;
  final LoadingController _loadingController;

  VideoDataGeneratorController(
    AudioService audioService,
    ContentController contentController,
    ConfigController configController,
    LoadingController loadingController,
  )   : _audioService = audioService,
        _configController = configController,
        _contentController = contentController,
        _loadingController = loadingController,
        super(ProgressStateModel(
          currentStep: 0,
          totalSteps: 0,
          message: '',
          progressPercentage: 0.0,
        ));

  Future<void> startWorkflow() async {
    _loadingController.startLoading(
      kLoadingMain,
      progressState: state,
    );

    // await _convertTextToAudio();
    // await _extractSRT();
    // await _generateSRT();
    await _createSubtitles();

    _loadingController.stopLoading(kLoadingMain);
  }

  Future<void> _convertTextToAudio() async {
    _updateProgress(
      1,
      "Conversion du texte en audio...",
    );

    await _audioService.convertTextToSpeech(
      _contentController.content.chronical?['content'],
      OpentAiConfigModel(
        apiKey: _configController.configService?.model?.apiKeyOpenAi ?? '',
        model: _configController.configService?.model?.modelOpenAi ?? '',
        voice: _configController.configService?.model?.voiceOpenAi ?? '',
        path:
            "${_configController.configService?.model?.path}/${_configController.configService?.model?.name}/contents",
        audioFileName: _contentController.content.id,
      ),
    );

    _contentController.setAudio(
      "${_contentController.content.id}.mp3",
    );

    _contentController.save();
  }

  Future<void> _extractSRT() async {
    _updateProgress(
      2,
      "Extraction des sous-titres (SRT)...",
    );

    final Map<String, dynamic> transcriptionContent =
        await _audioService.transcribeAudioToText(
      "${_configController.configService?.model?.path}/${_configController.configService?.model?.name}/contents/${_contentController.content.id}.mp3",
    );

    _contentController.setSrt(
      transcriptionContent,
    );

    _contentController.save();
  }

  Future<void> _generateSRT() async {
    _updateProgress(
      3,
      "Génération des sous-titres (SRT)...",
    );

    List<SrtSentenceModel> srtWithGroup = _audioService.generateSRT(
      _contentController.content.srt?['content'],
    );

    _contentController.setSrtWithGroup(
      srtWithGroup.map((e) => e.toJson()).toList(),
    );

    _contentController.save();
  }

  Future<void> _createSubtitles() async {
    _updateProgress(
      4,
      "Création des sous-titres...",
    );

    String assContent = _audioService.createSubtitles(
      _contentController.content.srtWithGroup?['content']
          .map((e) => SrtSentenceModel.fromJson(e))
          .whereType<SrtSentenceModel>()
          .toList(),
    );

    _contentController.setAss(
      assContent,
    );

    _contentController.save();
  }

  void _updateProgress(
    int step,
    String message,
  ) {
    state = state.copyWith(
      currentStep: step,
      message: message,
      progressPercentage: step / state.totalSteps,
    );

    _loadingController.updateLoadingState(
      kLoadingMain,
      progressState: state,
    );
  }
}

final videoDataGeneratorControllerProvider =
    StateNotifierProvider<VideoDataGeneratorController, ProgressStateModel>(
  (ref) {
    final ConfigController configController =
        ref.read(configControllerProvider.notifier);

    OpenAIGateway openAIGateway = OpenAIGateway<String>(
      configController.configService?.model?.apiKeyOpenAi ?? '',
    );

    return VideoDataGeneratorController(
      AudioService(openAIGateway),
      ref.read(contentControllerProvider.notifier),
      ref.read(configControllerProvider.notifier),
      ref.read(loadingControllerProvider.notifier),
    );
  },
);
