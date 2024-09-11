import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:x_video_ai/gateway/open_ai_gateway.dart';
import 'package:x_video_ai/models/srt_word_model.dart';
import 'package:x_video_ai/models/video_section_model.dart';
import 'package:x_video_ai/services/section_service.dart';

import 'section_service_test.mocks.dart';

@GenerateMocks([OpenAIGateway])
void main() {
  SectionService sectionService = SectionService();

  group('createSections', () {
    test('should split words into sections based on maxDuration', () async {
      // Arrange
      final srtWithGroup = [
        SrtWordModel(word: 'Le', start: 0.0, end: 0.3, duration: 0.3),
        SrtWordModel(word: 'CAC', start: 0.3, end: 0.5, duration: 0.2),
        SrtWordModel(word: '40', start: 0.5, end: 1.0, duration: 0.5),
        SrtWordModel(word: 'trébuche', start: 1.0, end: 2.0, duration: 1.0),
        SrtWordModel(word: 'TotalEnergie', start: 2.0, end: 3.0, duration: 1.0),
        SrtWordModel(word: 'poids', start: 3.0, end: 3.5, duration: 0.5),
        SrtWordModel(word: 'lourd', start: 3.5, end: 4.0, duration: 0.5),
      ];

      // Act
      final sections =
          sectionService.createSections(srtWithGroup, maxDuration: 2.0);

      // Assert
      final actualSections = await sections;
      expect(actualSections.length,
          equals(2)); // Correction ici, 2 sections au total
      expect(actualSections[0].sentence, equals('Le CAC 40 trébuche'));
      expect(actualSections[0].start, equals(0.0));
      expect(actualSections[0].end, equals(2.0));
      expect(actualSections[0].duration, equals(2.0));

      expect(actualSections[1].sentence, equals('TotalEnergie poids lourd'));
      expect(actualSections[1].start, equals(2.0));
      expect(actualSections[1].end, equals(4.0));
      expect(actualSections[1].duration, equals(2.0));
    });

    test('should create a single section if words fit within maxDuration',
        () async {
      // Arrange
      final srtWithGroup = [
        SrtWordModel(word: 'Hello', start: 0.0, end: 1.0, duration: 1.0),
        SrtWordModel(word: 'world', start: 1.0, end: 2.0, duration: 1.0),
      ];

      // Act
      final sections =
          sectionService.createSections(srtWithGroup, maxDuration: 10.0);

      // Assert
      final actualSections = await sections;
      expect(actualSections.length, equals(1));
      expect(actualSections[0].sentence, equals('Hello world'));
      expect(actualSections[0].start, equals(0.0));
      expect(actualSections[0].end, equals(2.0));
      expect(actualSections[0].duration, equals(2.0));
    });

    test('should handle empty input list', () async {
      // Arrange
      final srtWithGroup = <SrtWordModel>[];

      // Act
      final sections =
          sectionService.createSections(srtWithGroup, maxDuration: 5.0);

      // Assert
      final actualSections = await sections;
      expect(actualSections.length, equals(0));
    });

    test('should split words even if maxDuration is exceeded by one word',
        () async {
      // Arrange
      final srtWithGroup = [
        SrtWordModel(word: 'Le', start: 0.0, end: 0.3, duration: 0.3),
        SrtWordModel(word: 'CAC', start: 0.3, end: 0.5, duration: 0.2),
        SrtWordModel(word: '40', start: 0.5, end: 1.0, duration: 0.5),
        SrtWordModel(word: 'trébuche', start: 1.0, end: 3.5, duration: 2.5),
      ];

      // Act
      final sections =
          sectionService.createSections(srtWithGroup, maxDuration: 2.0);

      // Assert
      final actualSections = await sections;
      expect(actualSections.length, equals(2));
      expect(actualSections[0].sentence, equals('Le CAC 40'));
      expect(actualSections[0].start, equals(0.0));
      expect(actualSections[0].end, equals(1.0));
      expect(actualSections[0].duration, equals(1.0));

      expect(actualSections[1].sentence, equals('trébuche'));
      expect(actualSections[1].start, equals(1.0));
      expect(actualSections[1].end, equals(3.5));
      expect(actualSections[1].duration, equals(2.5));
    });

    test('should handle single word sections if maxDuration is very small',
        () async {
      // Arrange
      final srtWithGroup = [
        SrtWordModel(word: 'Hello', start: 0.0, end: 1.0, duration: 1.0),
        SrtWordModel(word: 'world', start: 1.0, end: 2.0, duration: 1.0),
      ];

      // Act
      final sections =
          sectionService.createSections(srtWithGroup, maxDuration: 0.5);

      // Assert
      final actualSections = await sections;
      expect(actualSections.length, equals(2));
      expect(actualSections[0].sentence, equals('Hello'));
      expect(actualSections[1].sentence, equals('world'));
    });
  });

  group('generateKeywords', () {
    test('should generate keyword for a single section', () async {
      // Arrange
      final mockOpenAIGateway = MockOpenAIGateway<String>();
      final sections = [
        VideoSectionModel(
          id: '1',
          sentence: 'Le CAC 40 trébuche.',
          start: 0.0,
          end: 4.0,
          duration: 4.0,
        ),
      ];

      // Simuler un retour de mot-clé
      when(mockOpenAIGateway.callOpenAI(
              messages: anyNamed('messages'), model: anyNamed('model')))
          .thenAnswer((_) async => 'bourse');

      // Act
      final result = await sectionService.generateKeywords(
        sections,
        mockOpenAIGateway,
        'gpt-3.5-turbo',
      );

      // Assert
      expect(result.length, equals(1));
      expect(result[0].keyword, equals('bourse'));
    });

    test('should generate keywords for multiple sections', () async {
      // Arrange
      final mockOpenAIGateway = MockOpenAIGateway<String>();
      final sections = [
        VideoSectionModel(
          id: '1',
          sentence: 'Le CAC 40 trébuche.',
          start: 0.0,
          end: 4.0,
          duration: 4.0,
        ),
        VideoSectionModel(
          id: '2',
          sentence: 'Les investisseurs sont inquiets.',
          start: 4.0,
          end: 8.0,
          duration: 4.0,
        ),
      ];

      // Simuler un retour de mots-clés
      when(mockOpenAIGateway.callOpenAI(
              messages: anyNamed('messages'), model: anyNamed('model')))
          .thenAnswer((invocation) async {
        final messages = invocation.namedArguments[#messages]
            as List<OpenAIChatCompletionChoiceMessageModel>;
        if (messages.last.content![0].text == 'Le CAC 40 trébuche.') {
          return 'bourse';
        } else {
          return 'investissements';
        }
      });

      // Act
      final result = await sectionService.generateKeywords(
        sections,
        mockOpenAIGateway,
        'gpt-3.5-turbo',
      );

      // Assert
      expect(result.length, equals(2));
      expect(result[0].keyword, equals('bourse'));
      expect(result[1].keyword, equals('investissements'));
    });

    test('should handle empty section sentence', () async {
      // Arrange
      final mockOpenAIGateway = MockOpenAIGateway<String>();
      final sections = [
        VideoSectionModel(
          id: '1',
          sentence: '',
          start: 0.0,
          end: 4.0,
          duration: 4.0,
        ),
      ];

      // Simuler un retour vide de mot-clé
      when(mockOpenAIGateway.callOpenAI(
              messages: anyNamed('messages'), model: anyNamed('model')))
          .thenAnswer((_) async => '');

      // Act
      final result = await sectionService.generateKeywords(
        sections,
        mockOpenAIGateway,
        'gpt-3.5-turbo',
      );

      // Assert
      expect(result.length, equals(1));
      expect(result[0].keyword, equals(''));
    });

    test('should handle null or empty OpenAI response', () async {
      // Arrange
      final mockOpenAIGateway = MockOpenAIGateway<String>();
      final sections = [
        VideoSectionModel(
          id: '1',
          sentence: 'Le CAC 40 trébuche.',
          start: 0.0,
          end: 4.0,
          duration: 4.0,
        ),
      ];

      // Simuler un retour null ou vide de l'API OpenAI
      when(mockOpenAIGateway.callOpenAI(
              messages: anyNamed('messages'), model: anyNamed('model')))
          .thenAnswer((_) async => '');

      // Act
      final result = await sectionService.generateKeywords(
        sections,
        mockOpenAIGateway,
        'gpt-3.5-turbo',
      );

      // Assert
      expect(result.length, equals(1));
      expect(result[0].keyword, equals(''));
    });
  });
}
