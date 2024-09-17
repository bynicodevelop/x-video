import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/config_controller.dart';
import 'package:x_video_ai/controllers/content_controller.dart';
import 'package:x_video_ai/controllers/loading_controller.dart';
import 'package:x_video_ai/controllers/notification_controller.dart';
import 'package:x_video_ai/gateway/file_getaway.dart';
import 'package:x_video_ai/gateway/open_ai_gateway.dart';
import 'package:x_video_ai/models/open_ai_config_model.dart';
import 'package:x_video_ai/models/progress_state_model.dart';
import 'package:x_video_ai/models/srt_sentence_model.dart';
import 'package:x_video_ai/models/srt_word_model.dart';
import 'package:x_video_ai/models/state_notification_model.dart';
import 'package:x_video_ai/models/video_section_model.dart';
import 'package:x_video_ai/services/audio_service.dart';
import 'package:x_video_ai/services/section_service.dart';
import 'package:x_video_ai/utils/constants.dart';

class VideoDataGeneratorController extends StateNotifier<ProgressStateModel> {
  final OpenAIGateway<String> _openAIGateway;
  final AudioService _audioService;
  final SectionService _sectionService;
  final ContentController _contentController;
  final ConfigController _configController;
  final LoadingController _loadingController;
  final NotificationControllerProvider _notificationController;

  VideoDataGeneratorController(
    OpenAIGateway<String> openAIGateway,
    AudioService audioService,
    SectionService sectionService,
    ContentController contentController,
    ConfigController configController,
    LoadingController loadingController,
    NotificationControllerProvider notificationController,
  )   : _openAIGateway = openAIGateway,
        _audioService = audioService,
        _sectionService = sectionService,
        _configController = configController,
        _contentController = contentController,
        _loadingController = loadingController,
        _notificationController = notificationController,
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

    try {
      await _convertTextToAudio();
    } catch (e) {
      // TODO: Add translation
      _notificationController.showNotification(
        "Erreur lors de la conversion du texte en audio",
        const Duration(seconds: 5),
        NotificationType.error,
      );

      _loadingController.stopLoading(kLoadingMain);
      return;
    }

    try {
      await _extractSRT();
    } catch (e) {
      // TODO: Add translation
      _notificationController.showNotification(
        "Erreur lors de l'extraction des sous-titres",
        const Duration(seconds: 5),
        NotificationType.error,
      );

      _loadingController.stopLoading(kLoadingMain);
      return;
    }

    try {
      await _generateSRT();
    } catch (e) {
      // TODO: Add translation
      _notificationController.showNotification(
        "Erreur lors de la génération des sous-titres",
        const Duration(seconds: 5),
        NotificationType.error,
      );

      _loadingController.stopLoading(kLoadingMain);
      return;
    }

    try {
      await _createSubtitles();
    } catch (e) {
      // TODO: Add translation
      _notificationController.showNotification(
        "Erreur lors de la création des sous-titres",
        const Duration(seconds: 5),
        NotificationType.error,
      );

      _loadingController.stopLoading(kLoadingMain);
      return;
    }

    try {
      await _generateSections();
    } catch (e) {
      // TODO: Add translation
      _notificationController.showNotification(
        "Erreur lors de la génération des sections",
        const Duration(seconds: 5),
        NotificationType.error,
      );

      _loadingController.stopLoading(kLoadingMain);
      return;
    }

    try {
      await _generateKeywords();
    } catch (e) {
      // TODO: Add translation
      _notificationController.showNotification(
        "Erreur lors de la génération des mots-clés",
        const Duration(seconds: 5),
        NotificationType.error,
      );

      _loadingController.stopLoading(kLoadingMain);
      return;
    }

    _loadingController.stopLoading(kLoadingMain);
  }

  Future<void> _convertTextToAudio() async {
    _updateProgress(
      1,
      // TODO: Add translation
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
      "${_contentController.content.id}.$kAudioExtension",
    );

    _contentController.save();
  }

  Future<void> _extractSRT() async {
    _updateProgress(
      2,
      // TODO: Add translation
      "Extraction des sous-titres (SRT)...",
    );

    if (_contentController.content.srt != null) {
      return;
    }

    final Map<String, dynamic> transcriptionContent =
        await _audioService.transcribeAudioToText(
      "${_configController.configService?.model?.path}/${_configController.configService?.model?.name}/contents/${_contentController.content.id}.$kAudioExtension",
    );

    _contentController.setSrt(transcriptionContent);
    _contentController.save();
  }

  Future<void> _generateSRT() async {
    _updateProgress(
      3,
      // TODO: Add translation
      "Génération des sous-titres (SRT)...",
    );

    if (_contentController.content.srtWithGroup != null) {
      return;
    }

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
      // TODO: Add translation
      "Création des sous-titres...",
    );

    if (_contentController.content.assContent != null) {
      return;
    }

    String assContent = _audioService.createSubtitles(
      _contentController.content.srtWithGroup?['content']
          .map((e) => SrtSentenceModel.fromJson(e))
          .whereType<SrtSentenceModel>()
          .toList(),
    );

    _contentController.setAss(assContent);
    _contentController.save();
  }

  Future<void> _generateSections() async {
    _updateProgress(
      5,
      // TODO: Add translation
      "Génération des sections...",
    );

    if (_contentController.content.sections != null) {
      return;
    }

    List<SrtWordModel> words = _contentController
        .content.srt?['content']['words']
        .map((e) => SrtWordModel.fromJson(e))
        .whereType<SrtWordModel>()
        .toList();

    final List<VideoSectionModel> sections =
        await _sectionService.createSections(
      words,
      maxDuration: 3,
    );

    _contentController.setSections(
      sections.map((e) => e.toJson()).toList(),
    );

    _contentController.save();
  }

  Future<void> _generateKeywords() async {
    _updateProgress(
      6,
      // TODO: Add translation
      "Génération des mots-clés...",
    );

    bool hasKeywords = _contentController.content.sections?['content']
        .map((e) => VideoSectionModel.fromJson(e))
        .whereType<VideoSectionModel>()
        .every((element) =>
            element.keyword != null && element.keyword!.isNotEmpty);

    if (hasKeywords) {
      print("full mots clés");
      return;
    }

    List<VideoSectionModel> sections = _contentController
        .content.sections?['content']
        .map((e) => VideoSectionModel.fromJson(e))
        .whereType<VideoSectionModel>()
        .toList();

    final List<VideoSectionModel> sectionsWithKeywords =
        await _sectionService.generateKeywords(
      sections,
      _openAIGateway,
      _configController.configService?.model?.modelOpenAi ?? '',
    );

    _contentController.setSections(
      sectionsWithKeywords.map((e) => e.toJson()).toList(),
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

    OpenAIGateway<String> openAIGateway = OpenAIGateway<String>(
      FileGateway(),
      configController.configService?.model?.apiKeyOpenAi ?? '',
    );

    return VideoDataGeneratorController(
      openAIGateway,
      AudioService(
        FileGateway(),
        openAIGateway,
      ),
      SectionService(),
      ref.read(contentControllerProvider.notifier),
      ref.read(configControllerProvider.notifier),
      ref.read(loadingControllerProvider.notifier),
      ref.read(notificationControllerProvider.notifier),
    );
  },
);
