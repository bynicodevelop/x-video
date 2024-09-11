import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/gateway/file_getaway.dart';
import 'package:x_video_ai/models/project_model.dart';
import 'package:x_video_ai/services/config_service.dart';

class ConfigController extends StateNotifier<ConfigService<ProjectModel>?> {
  final FileGateway _fileGateway;

  ConfigController(
    FileGateway fileGateway,
  )   : _fileGateway = fileGateway,
        super(null);

  ConfigService<ProjectModel>? get configService => state;
  ProjectModel? get model => state!.model;

  Future<void> loadConfiguration({
    required String path,
  }) async {
    final ConfigService configService = ConfigService<ProjectModel>(
      fileGateway: _fileGateway,
    );

    state = await configService.loadConfiguration(
      path,
      ProjectModel(
        name: '',
        path: '',
      ),
    ) as ConfigService<ProjectModel>;
  }

  void initConfiguration({
    required String path,
    required String name,
    required ProjectModel model,
  }) {
    state = ConfigService<ProjectModel>(
      fileGateway: _fileGateway,
      path: path,
      name: name,
      model: model,
    );
  }

  Future<void> create() async {
    if (state == null) {
      throw Exception('ConfigService not initialized');
    }

    await state!.createConfiguration();
  }

  Future<void> update(
    String key,
    dynamic value,
  ) async {
    if (state == null) {
      throw Exception('ConfigService not initialized');
    }

    await state!.updateConfiguration(
      key,
      value,
    );

    state = state!.copyWith();
  }
}

final configControllerProvider =
    StateNotifierProvider<ConfigController, ConfigService<ProjectModel>?>(
  (ref) => ConfigController(
    FileGateway(),
  ),
);
