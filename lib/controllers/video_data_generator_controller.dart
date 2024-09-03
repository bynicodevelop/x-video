import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/loading_controller.dart';
import 'package:x_video_ai/models/progress_state_model.dart';
import 'package:x_video_ai/utils/constants.dart';

class VideoDataGeneratorController extends StateNotifier<ProgressStateModel> {
  final LoadingController _loadingController;

  VideoDataGeneratorController(
    LoadingController loadingController,
  )   : _loadingController = loadingController,
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

    await _convertTextToAudio();
    await _extractSRT();

    _loadingController.stopLoading(kLoadingMain);
  }

  Future<void> _convertTextToAudio() async {
    _updateProgress(
      1,
      "Conversion du texte en audio...",
    );
    await Future.delayed(const Duration(
      seconds: 5,
    ));
  }

  Future<void> _extractSRT() async {
    _updateProgress(
      2,
      "Extraction des sous-titres (SRT)...",
    );
    await Future.delayed(const Duration(seconds: 2));
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
  (ref) => VideoDataGeneratorController(
    ref.read(loadingControllerProvider.notifier),
  ),
);
