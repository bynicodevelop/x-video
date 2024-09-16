import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:x_video_ai/gateway/file_getaway.dart';
import 'package:x_video_ai/models/project_model.dart';
import 'package:x_video_ai/services/config_service.dart';

import '../services/content_extractor_service_test.mocks.dart';

// Générer les mocks pour ConfigService
@GenerateMocks([ConfigService, FileGateway])
void main() {
  late MockFileGateway mockFileGateway;
  late ConfigService<ProjectModel> configService;
  final projectModel = ProjectModel(name: 'Test Project', path: '/test/path');

  setUp(() {
    mockFileGateway = MockFileGateway();
    configService = ConfigService<ProjectModel>(
      fileGateway: mockFileGateway,
      path: projectModel.path,
      name: 'config.json',
      model: projectModel,
    );
  });

  test('createConfiguration should create configuration file if not exists',
      () async {
    // Arrange
    final mockFileWrapper = MockFileWrapper();
    when(mockFileGateway.createDirectory(any)).thenAnswer((_) async {});
    when(mockFileGateway.getFile(any)).thenReturn(mockFileWrapper);
    when(mockFileWrapper.existsSync()).thenReturn(false);

    // Act
    await configService.createConfiguration();

    // Assert
    verify(mockFileGateway.createDirectory('/test/path')).called(1);
    verify(mockFileWrapper.writeAsStringSync(jsonEncode(projectModel.toJson())))
        .called(1);
  });

  test('createConfiguration should throw if path or name is null', () async {
    // Arrange
    configService = ConfigService<ProjectModel>(
      fileGateway: mockFileGateway,
      model: projectModel,
    );

    // Act & Assert
    expect(() => configService.createConfiguration(), throwsException);
  });

  test('loadConfiguration should load configuration from file', () {
    // Arrange
    final mockFileWrapper = MockFileWrapper();
    when(mockFileGateway.getFile(any)).thenReturn(mockFileWrapper);
    when(mockFileWrapper.existsSync()).thenReturn(true);
    when(mockFileWrapper.readAsStringSync())
        .thenReturn(jsonEncode(projectModel.toJson()));

    // Act
    configService.loadConfiguration('/test/path', projectModel);

    // Assert
    expect(configService.model!.name, equals('Test Project'));
    expect(configService.model!.path, equals('/test/path'));
  });

  test('loadConfiguration should throw if config file not found', () {
    // Arrange
    final mockFileWrapper = MockFileWrapper();
    when(mockFileGateway.getFile(any)).thenReturn(mockFileWrapper);
    when(mockFileWrapper.existsSync()).thenReturn(false);

    // Act & Assert
    expect(() => configService.loadConfiguration('/test/path', projectModel),
        throwsException);
  });

  test('updateConfiguration should throw if config file does not exist',
      () async {
    // Arrange
    final mockFileWrapper = MockFileWrapper();
    when(mockFileGateway.getFile(any)).thenReturn(mockFileWrapper);
    when(mockFileWrapper.exists()).thenAnswer((_) async => false);

    // Act & Assert
    expect(() => configService.updateConfiguration('name', 'Updated Project'),
        throwsException);
  });

  test('copyWith should return a new instance with updated parameters', () {
    // Act
    final newConfigService = configService.copyWith(
      path: '/new/path',
      name: 'new_config.json',
    );

    // Assert
    expect(newConfigService.model, equals(configService.model));
    expect(newConfigService.isLoaded, equals(false));
    expect(newConfigService.model!.name, equals('Test Project'));
  });
}
