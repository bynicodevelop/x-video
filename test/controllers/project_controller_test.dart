import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:x_video_ai/controllers/config_controller.dart';
import 'package:x_video_ai/controllers/project_controller.dart';

import 'project_controller_test.mocks.dart';

// Générer les mocks pour ConfigController
@GenerateMocks([ConfigController])
void main() {
  late MockConfigController mockConfigController;
  late ProjectController projectController;
  late ProviderContainer container;

  setUp(() {
    mockConfigController = MockConfigController();
    container = ProviderContainer(overrides: [
      configControllerProvider.overrideWith((ref) => mockConfigController),
    ]);
    projectController = ProjectController(mockConfigController);
  });

  tearDown(() {
    container.dispose();
  });

  test('should set name', () {
    // Act
    projectController.setName('Test Project');

    // Assert
    expect(projectController.state.name, equals('Test Project'));
  });

  test('should set path', () {
    // Act
    projectController.setPath('/test/path');

    // Assert
    expect(projectController.state.path, equals('/test/path'));
  });

  test('should save project and call configController methods', () async {
    // Arrange
    projectController.setName('Test Project');
    projectController.setPath('/test/path');

    // Act
    await projectController.save();

    // Assert
    verify(mockConfigController.initConfiguration(
      path: '/test/path/Test Project',
      name: 'config.json',
      model: projectController.state,
    )).called(1);
    verify(mockConfigController.create()).called(1);
  });
}
