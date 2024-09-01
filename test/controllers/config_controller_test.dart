import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/models/project_model.dart';
import 'package:x_video_ai/services/config_service.dart';
import 'package:x_video_ai/controllers/config_controller.dart';

import 'config_controller_test.mocks.dart';

// Générer les mocks pour ConfigService
@GenerateMocks([ConfigService])
void main() {
  late ConfigController configController;
  late MockConfigService<ProjectModel> mockConfigService;
  late ProviderContainer container;

  setUp(() {
    mockConfigService = MockConfigService<ProjectModel>();

    container = ProviderContainer();

    configController = container.read(configControllerProvider.notifier);
  });

  tearDown(() {
    container.dispose();
  });

  test('should initialize configuration', () {
    // Arrange
    final projectModel = ProjectModel(name: 'Test Project', path: '/test/path');

    // Act
    configController.initConfiguration(
      path: projectModel.path,
      name: 'config.json',
      model: projectModel,
    );

    // Assert
    expect(configController.state, isNotNull);
    expect(configController.configService?.model!.name, equals('Test Project'));
    expect(configController.configService?.model!.path, equals('/test/path'));
  });

  test('should expect exception if configuration is not initialized', () {
    // Arrange
    final projectModel = ProjectModel(name: 'Test Project', path: '/test/path');

    configController.initConfiguration(
      path: projectModel.path,
      name: 'config.json',
      model: projectModel,
    );

    configController.state = null;

    expect(configController.create(), throwsException);
  });

  test('should create configuration', () async {
    // Arrange
    final projectModel = ProjectModel(name: 'Test Project', path: '/test/path');

    configController.initConfiguration(
      path: projectModel.path,
      name: 'config.json',
      model: projectModel,
    );

    when(mockConfigService.createConfiguration())
        .thenAnswer((_) async => Future.value(
              ConfigService<ProjectModel>(
                path: projectModel.path,
                name: 'config.json',
                model: projectModel,
              ),
            ));

    configController.state = mockConfigService as ConfigService<ProjectModel>;

    // Act
    await configController.create();

    // Assert
    verify(mockConfigService.createConfiguration()).called(1);
  });
}
