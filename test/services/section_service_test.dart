import 'package:flutter_test/flutter_test.dart';
import 'package:x_video_ai/models/srt_word_model.dart';
import 'package:x_video_ai/services/section_service.dart';

void main() {
  SectionService sectionService = SectionService();

  group('createSections', () {
    test('should split words into sections based on maxDuration', () {
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
      expect(sections.length, equals(2)); // Correction ici, 2 sections au total
      expect(sections[0].sentence, equals('Le CAC 40 trébuche'));
      expect(sections[0].start, equals(0.0));
      expect(sections[0].end, equals(2.0));
      expect(sections[0].duration, equals(2.0));

      expect(sections[1].sentence, equals('TotalEnergie poids lourd'));
      expect(sections[1].start, equals(2.0));
      expect(sections[1].end, equals(4.0));
      expect(sections[1].duration, equals(2.0));
    });

    test('should create a single section if words fit within maxDuration', () {
      // Arrange
      final srtWithGroup = [
        SrtWordModel(word: 'Hello', start: 0.0, end: 1.0, duration: 1.0),
        SrtWordModel(word: 'world', start: 1.0, end: 2.0, duration: 1.0),
      ];

      // Act
      final sections =
          sectionService.createSections(srtWithGroup, maxDuration: 10.0);

      // Assert
      expect(sections.length, equals(1));
      expect(sections[0].sentence, equals('Hello world'));
      expect(sections[0].start, equals(0.0));
      expect(sections[0].end, equals(2.0));
      expect(sections[0].duration, equals(2.0));
    });

    test('should handle empty input list', () {
      // Arrange
      final srtWithGroup = <SrtWordModel>[];

      // Act
      final sections =
          sectionService.createSections(srtWithGroup, maxDuration: 5.0);

      // Assert
      expect(sections.length, equals(0));
    });

    test('should split words even if maxDuration is exceeded by one word', () {
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
      expect(sections.length, equals(2));
      expect(sections[0].sentence, equals('Le CAC 40'));
      expect(sections[0].start, equals(0.0));
      expect(sections[0].end, equals(1.0));
      expect(sections[0].duration, equals(1.0));

      expect(sections[1].sentence, equals('trébuche'));
      expect(sections[1].start, equals(1.0));
      expect(sections[1].end, equals(3.5));
      expect(sections[1].duration, equals(2.5));
    });

    test('should handle single word sections if maxDuration is very small', () {
      // Arrange
      final srtWithGroup = [
        SrtWordModel(word: 'Hello', start: 0.0, end: 1.0, duration: 1.0),
        SrtWordModel(word: 'world', start: 1.0, end: 2.0, duration: 1.0),
      ];

      // Act
      final sections =
          sectionService.createSections(srtWithGroup, maxDuration: 0.5);

      // Assert
      expect(sections.length, equals(2));
      expect(sections[0].sentence, equals('Hello'));
      expect(sections[1].sentence, equals('world'));
    });
  });
}
