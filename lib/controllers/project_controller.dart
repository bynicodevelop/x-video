import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/config_controller.dart';
import 'package:x_video_ai/models/project_model.dart';

class ProjectController extends StateNotifier<ProjectModel> {
  final ConfigController _configController;

  ProjectController(ConfigController configController)
      : _configController = configController,
        super(ProjectModel(
          name: '',
          path: '',
        ));

  void setName(String name) {
    state = state.mergeWith({
      'name': name,
    });
  }

  void setPath(String path) {
    state = state.mergeWith({
      'path': path,
    });
  }

  Future<void> save() async {
    _configController.initConfiguration(
      path: '${state.path}/${state.name}',
      name: 'config.json',
      model: state,
    );

    await _configController.create();
  }
}

final createProjectControllerProvider =
    StateNotifierProvider<ProjectController, ProjectModel>(
  (ref) => ProjectController(
    ref.read(configControllerProvider.notifier),
  ),
);
