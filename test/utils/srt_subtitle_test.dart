import 'package:flutter_test/flutter_test.dart';
import 'package:x_video_ai/models/srt_sentence_model.dart';
import 'package:x_video_ai/models/srt_word_model.dart';
import 'package:x_video_ai/utils/srt_subtitle.dart';

void main() {
  final SrtSubtitle srtSubtitle = SrtSubtitle();

  group('createSubtitles', () {
    test('should divide words into subtitles with default 3 words per line',
        () {
      // Arrange
      final srtData = [
        SrtSentenceModel(
          sentence: "Le CAC 40 trébuche.",
          normalized: "le cac 40 trebuche",
          words: [
            SrtWordModel(word: "Le", start: 0.0, end: 0.3, duration: 0.3),
            SrtWordModel(word: "CAC", start: 0.3, end: 0.4, duration: 0.1),
            SrtWordModel(word: "40", start: 0.4, end: 0.8, duration: 0.4),
            SrtWordModel(word: "trébuche", start: 0.8, end: 1.4, duration: 0.6),
          ],
          group: [
            SrtWordModel(word: "Le", start: 0.0, end: 0.3, duration: 0.3),
            SrtWordModel(word: "CAC", start: 0.3, end: 0.4, duration: 0.1),
            SrtWordModel(word: "40", start: 0.4, end: 0.8, duration: 0.4),
            SrtWordModel(
                word: "trébuche.", start: 0.8, end: 1.4, duration: 0.6),
          ],
          start: 0.0,
          end: 1.4,
          duration: 1.4,
        ),
      ];

      // Act
      final result = srtSubtitle.createSubtitles(srtData);

      // Assert
      expect(result.length,
          equals(2)); // Par défaut 3 mots par ligne, donc deux sous-titres
      expect(result[0].map((e) => e.word).join(' '), equals("Le CAC 40"));
      expect(result[1].map((e) => e.word).join(' '), equals("trébuche."));
    });

    test('should divide words into subtitles with custom 2 words per line', () {
      // Arrange
      final srtData = [
        SrtSentenceModel(
          sentence: "Le CAC 40 trébuche.",
          normalized: "le cac 40 trebuche",
          words: [
            SrtWordModel(word: "Le", start: 0.0, end: 0.3, duration: 0.3),
            SrtWordModel(word: "CAC", start: 0.3, end: 0.4, duration: 0.1),
            SrtWordModel(word: "40", start: 0.4, end: 0.8, duration: 0.4),
            SrtWordModel(word: "trébuche", start: 0.8, end: 1.4, duration: 0.6),
          ],
          group: [
            SrtWordModel(word: "Le", start: 0.0, end: 0.3, duration: 0.3),
            SrtWordModel(word: "CAC", start: 0.3, end: 0.4, duration: 0.1),
            SrtWordModel(word: "40", start: 0.4, end: 0.8, duration: 0.4),
            SrtWordModel(
                word: "trébuche.", start: 0.8, end: 1.4, duration: 0.6),
          ],
          start: 0.0,
          end: 1.4,
          duration: 1.4,
        ),
      ];

      // Act
      final result = srtSubtitle.createSubtitles(srtData, wordPerLine: 2);

      // Assert
      expect(result.length, equals(2)); // Divisé en 2 mots par ligne
      expect(result[0].map((e) => e.word).join(' '), equals("Le CAC"));
      expect(result[1].map((e) => e.word).join(' '), equals("40 trébuche."));
    });

    test('should handle case where words fit perfectly into lines', () {
      // Arrange
      final srtData = [
        SrtSentenceModel(
          sentence: "This is a test sentence.",
          normalized: "this is a test sentence",
          words: [
            SrtWordModel(word: "This", start: 0.0, end: 0.3, duration: 0.3),
            SrtWordModel(word: "is", start: 0.3, end: 0.5, duration: 0.2),
            SrtWordModel(word: "a", start: 0.5, end: 0.6, duration: 0.1),
            SrtWordModel(word: "test", start: 0.6, end: 1.0, duration: 0.4),
            SrtWordModel(
                word: "sentence.", start: 1.0, end: 1.4, duration: 0.4),
          ],
          group: [
            SrtWordModel(word: "This", start: 0.0, end: 0.3, duration: 0.3),
            SrtWordModel(word: "is", start: 0.3, end: 0.5, duration: 0.2),
            SrtWordModel(word: "a", start: 0.5, end: 0.6, duration: 0.1),
            SrtWordModel(word: "test", start: 0.6, end: 1.0, duration: 0.4),
            SrtWordModel(
                word: "sentence.", start: 1.0, end: 1.4, duration: 0.4),
          ],
          start: 0.0,
          end: 1.4,
          duration: 1.4,
        ),
      ];

      // Act
      final result = srtSubtitle.createSubtitles(srtData, wordPerLine: 5);

      // Assert
      expect(result.length, equals(1)); // Tout tient dans une seule ligne
      expect(result[0].map((e) => e.word).join(' '),
          equals("This is a test sentence."));
    });

    test('should handle case where fewer words than wordPerLine', () {
      // Arrange
      final srtData = [
        SrtSentenceModel(
          sentence: "Only two words",
          normalized: "only two words",
          words: [
            SrtWordModel(word: "Only", start: 0.0, end: 0.4, duration: 0.4),
            SrtWordModel(word: "two", start: 0.4, end: 0.8, duration: 0.4),
          ],
          group: [
            SrtWordModel(word: "Only", start: 0.0, end: 0.4, duration: 0.4),
            SrtWordModel(word: "two", start: 0.4, end: 0.8, duration: 0.4),
          ],
          start: 0.0,
          end: 0.8,
          duration: 0.8,
        ),
      ];

      // Act
      final result = srtSubtitle.createSubtitles(srtData, wordPerLine: 3);

      // Assert
      expect(result.length,
          equals(1)); // Moins de mots que wordPerLine, donc une seule ligne
      expect(result[0].map((e) => e.word).join(' '), equals("Only two"));
    });

    test('should handle empty group gracefully', () {
      // Arrange
      final srtData = [
        SrtSentenceModel(
          sentence: "Empty group test.",
          normalized: "empty group test",
          words: [
            SrtWordModel(word: "Empty", start: 0.0, end: 0.3, duration: 0.3),
            SrtWordModel(word: "group", start: 0.3, end: 0.6, duration: 0.3),
          ],
          group: [],
          start: 0.0,
          end: 0.6,
          duration: 0.6,
        ),
      ];

      // Act
      final result = srtSubtitle.createSubtitles(srtData);

      // Assert
      expect(result.length,
          equals(0)); // Aucune donnée dans group, donc pas de sous-titre
    });
  });

  group('generateAssFile', () {
    test('should generate correct ASS file format with single subtitle', () {
      // Arrange
      final subtitles = [
        [
          SrtWordModel(word: 'Hello', start: 0.0, end: 0.5, duration: 0.5),
          SrtWordModel(word: 'world', start: 0.5, end: 1.0, duration: 0.5),
        ],
      ];

      // Act
      final assContent = srtSubtitle.generateAssFile(subtitles);

      // Assert
      expect(assContent.contains('[Script Info]'), isTrue);
      expect(assContent.contains('[V4+ Styles]'), isTrue);
      expect(
          assContent.contains(
              'Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text'),
          isTrue);
      expect(
          assContent.contains(
              'Dialogue: 0,0:00:00.00,0:00:01.00,Default,,0,0,0,,Hello world'),
          isTrue);
    });

    test('should generate multiple lines of subtitles in ASS format', () {
      // Arrange
      final subtitles = [
        [
          SrtWordModel(word: 'Hello', start: 0.0, end: 0.5, duration: 0.5),
          SrtWordModel(word: 'world', start: 0.5, end: 1.0, duration: 0.5),
        ],
        [
          SrtWordModel(word: 'This', start: 1.0, end: 1.5, duration: 0.5),
          SrtWordModel(word: 'is', start: 1.5, end: 2.0, duration: 0.5),
          SrtWordModel(word: 'Dart', start: 2.0, end: 2.5, duration: 0.5),
        ],
      ];

      // Act
      final assContent = srtSubtitle.generateAssFile(subtitles);

      // Assert
      expect(
          assContent.contains(
              'Dialogue: 0,0:00:00.00,0:00:01.00,Default,,0,0,0,,Hello world'),
          isTrue);
      expect(
          assContent.contains(
              'Dialogue: 0,0:00:01.00,0:00:02.50,Default,,0,0,0,,This is Dart'),
          isTrue);
    });

    test('should handle empty list of subtitles', () {
      // Arrange
      final subtitles = <List<SrtWordModel>>[];

      // Act
      final assContent = srtSubtitle.generateAssFile(subtitles);

      // Assert
      expect(assContent.contains('Dialogue'), isFalse);
    });

    test('should correctly format time for subtitles in ASS format', () {
      // Arrange
      final subtitles = [
        [
          SrtWordModel(word: 'Timing', start: 0.0, end: 1.5, duration: 1.5),
        ],
      ];

      // Act
      final assContent = srtSubtitle.generateAssFile(subtitles);

      // Assert
      expect(
          assContent.contains(
              'Dialogue: 0,0:00:00.00,0:00:01.50,Default,,0,0,0,,Timing'),
          isTrue);
    });

    test('should handle special characters in subtitles', () {
      // Arrange
      final subtitles = [
        [
          SrtWordModel(word: 'Café', start: 0.0, end: 0.5, duration: 0.5),
          SrtWordModel(word: 'Déjà vu', start: 0.5, end: 1.5, duration: 1.0),
        ],
      ];

      // Act
      final assContent = srtSubtitle.generateAssFile(subtitles);

      // Assert
      expect(
          assContent.contains(
              'Dialogue: 0,0:00:00.00,0:00:01.50,Default,,0,0,0,,Café Déjà vu'),
          isTrue);
    });

    test('should generate ASS file without karaoke effect', () {
      // Arrange
      final subtitles = [
        [
          SrtWordModel(word: 'Hello', start: 0.0, end: 0.5, duration: 0.5),
          SrtWordModel(word: 'world', start: 0.5, end: 1.0, duration: 0.5),
        ],
      ];

      // Act
      final assContent = srtSubtitle.generateAssFile(subtitles);

      // Assert
      expect(
          assContent.contains(
              'Dialogue: 0,0:00:00.00,0:00:01.00,Default,,0,0,0,,Hello world'),
          isTrue);
    });

    test('should generate ASS file with karaoke STYLE_1 effect', () {
      // Arrange
      final subtitles = [
        [
          SrtWordModel(word: 'Hello', start: 0.0, end: 0.5, duration: 0.5),
          SrtWordModel(word: 'world', start: 0.5, end: 1.0, duration: 0.5),
        ],
      ];

      // Act
      final assContent = srtSubtitle.generateAssFile(
        subtitles,
        karaokeEffect: 'STYLE_1',
      );

      // Assert
      expect(
          assContent.contains(
              'Dialogue: 0,0:00:00.00,0:00:01.00,Default,,0,0,0,,{\\k50}{\\c&H00FF00&}Hello {\\k50}{\\c&H00FF00&}world'),
          isTrue);
    });

    test('should generate ASS file with custom highlight color', () {
      // Arrange
      final subtitles = [
        [
          SrtWordModel(word: 'This', start: 1.0, end: 1.5, duration: 0.5),
          SrtWordModel(word: 'is', start: 1.5, end: 2.0, duration: 0.5),
        ],
      ];

      // Act
      final assContent = srtSubtitle.generateAssFile(
        subtitles,
        karaokeEffect: 'STYLE_1',
        highlightColor: '&H00FF00FF&',
      );

      // Assert
      expect(
          assContent.contains(
              'Dialogue: 0,0:00:01.00,0:00:02.00,Default,,0,0,0,,{\\k50}{\\c&H00FF00FF&}This {\\k50}{\\c&H00FF00FF&}is'),
          isTrue);
    });

    test('should generate ASS file without karaoke when karaokeEffect is null',
        () {
      // Arrange
      final subtitles = [
        [
          SrtWordModel(word: 'No', start: 0.0, end: 0.5, duration: 0.5),
          SrtWordModel(word: 'karaoke', start: 0.5, end: 1.0, duration: 0.5),
        ],
      ];

      // Act
      final assContent = srtSubtitle.generateAssFile(
        subtitles,
        karaokeEffect: null, // Pas d'effet karaoké
      );

      // Assert
      expect(
          assContent.contains(
              'Dialogue: 0,0:00:00.00,0:00:01.00,Default,,0,0,0,,No karaoke'),
          isTrue);
    });

    test('should handle single word karaoke effect', () {
      // Arrange
      final subtitles = [
        [
          SrtWordModel(word: 'Test', start: 0.0, end: 1.0, duration: 1.0),
        ],
      ];

      // Act
      final assContent = srtSubtitle.generateAssFile(
        subtitles,
        karaokeEffect: 'STYLE_1',
      );

      // Assert
      expect(
          assContent.contains(
              'Dialogue: 0,0:00:00.00,0:00:01.00,Default,,0,0,0,,{\\k100}{\\c&H00FF00&}Test'),
          isTrue);
    });
  });
}
