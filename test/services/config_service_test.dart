import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:x_video_ai/gateway/file_getaway.dart';
import 'package:x_video_ai/models/abstracts/json_deserializable.dart';
import 'package:x_video_ai/services/config_service.dart';

import 'content_service_test.mocks.dart';

class TestModel extends JsonDeserializable {
  final String key;
  TestModel({required this.key});

  @override
  Map<String, dynamic> toJson() => {'key': key};

  @override
  TestModel fromJson(Map<String, dynamic> json) {
    return TestModel(key: json['key']);
  }

  @override
  mergeWith(Map<String, dynamic> json) {
    // TODO: implement mergeWith
    throw UnimplementedError();
  }
}

@GenerateMocks([FileGateway, FileWrapper])
void main() {
  late MockFileGateway mockFileGateway;
  late MockFileWrapper mockFileWrapper;
  late ConfigService<TestModel> configService;

  setUp(() {
    mockFileGateway = MockFileGateway();
    mockFileWrapper = MockFileWrapper();
    configService = ConfigService<TestModel>(
      fileGateway: mockFileGateway,
      model: TestModel(key: 'defaultKey'),
      path: '/test/path',
      name: 'config.json',
    );
  });

  group('ConfigService', () {
    test('createConfiguration creates a new config file if it does not exist',
        () async {
      // Configurer le mock pour renvoyer un fichier qui n'existe pas
      when(mockFileGateway.getFile(any)).thenReturn(mockFileWrapper);
      when(mockFileWrapper.existsSync()).thenReturn(false);

      // Appeler la méthode createConfiguration
      await configService.createConfiguration();

      // Vérifier que le fichier est écrit avec le contenu attendu
      verify(mockFileWrapper.writeAsStringSync(argThat(contains('defaultKey'))))
          .called(1);
    });

    test('loadConfiguration throws exception if config file not found',
        () async {
      when(mockFileGateway.getFile(any)).thenReturn(mockFileWrapper);
      when(mockFileWrapper.existsSync()).thenReturn(false);

      expect(
        () async => await configService.loadConfiguration(
            '/test/path', TestModel(key: 'defaultKey')),
        throwsA(isA<Exception>().having(
            (e) => e.toString(), 'message', contains('Config file not found'))),
      );
    });

    test('loadConfiguration loads the config from file', () async {
      final configJson = jsonEncode({'key': 'loadedKey'});

      when(mockFileGateway.getFile(any)).thenReturn(mockFileWrapper);
      when(mockFileWrapper.existsSync()).thenReturn(true);
      when(mockFileWrapper.readAsStringSync()).thenReturn(configJson);

      await configService.loadConfiguration(
          '/test/path', TestModel(key: 'defaultKey'));

      // Vérifier que le modèle est mis à jour avec le contenu du fichier
      expect(configService.model!.key, equals('loadedKey'));
    });

    test('updateConfiguration updates the config file with new key-value pair',
        () async {
      final existingConfigJson = jsonEncode({'key': 'existingValue'});

      // Assurez-vous que getFile retourne bien un mock valide
      when(mockFileGateway.getFile(any)).thenReturn(mockFileWrapper);

      // Stub pour l'existence du fichier
      when(mockFileWrapper.exists()).thenAnswer((_) async => true);

      // Stub pour la lecture du fichier
      when(mockFileWrapper.readAsString())
          .thenAnswer((_) async => existingConfigJson);

      // Stub pour l'écriture du fichier
      when(mockFileWrapper.writeAsString(any))
          .thenAnswer((_) async => Future.value(File('dummy')));

      // Appel à la méthode à tester
      await configService.updateConfiguration('newKey', 'newValue');

      // Vérification que le fichier est mis à jour avec la nouvelle clé-valeur
      verify(mockFileWrapper
              .writeAsString(argThat(contains('"newKey":"newValue"'))))
          .called(1);
    });

    test('updateConfiguration throws exception if config file not found',
        () async {
      when(mockFileGateway.getFile(any)).thenReturn(mockFileWrapper);
      when(mockFileWrapper.exists()).thenAnswer((_) async => false);

      expect(
        () async =>
            await configService.updateConfiguration('newKey', 'newValue'),
        throwsA(isA<Exception>().having(
            (e) => e.toString(), 'message', contains('Config file not found'))),
      );
    });
  });
}
