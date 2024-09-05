import 'package:flutter_test/flutter_test.dart';
import 'package:x_video_ai/models/srt_word_model.dart';
import 'package:x_video_ai/utils/srt_clean.dart';

void main() {
  final SrtClean srtClean = SrtClean();

  group('fillMissingWords', () {
    final srtClean = SrtClean(); // Instancie ta classe si nécessaire

    test('should fill missing character when word is empty', () {
      // Arrange
      String originalText = "1,6% et entraîne";
      List<SrtWordModel> words = [
        SrtWordModel(word: "1", start: 0.0, end: 0.3, duration: 0.3),
        SrtWordModel(word: "6", start: 0.3, end: 0.6, duration: 0.3),
        SrtWordModel(word: "", start: 0.6, end: 0.9, duration: 0.3),
        SrtWordModel(word: "et", start: 0.9, end: 1.2, duration: 0.3),
      ];

      // Act
      List<SrtWordModel> result =
          srtClean.fillMissingWords(originalText, words);

      // Assert
      expect(result[2].word, equals("%"));
    });

    test('should not modify words with no missing character', () {
      // Arrange
      String originalText = "Hello world";
      List<SrtWordModel> words = [
        SrtWordModel(word: "Hello", start: 0.0, end: 0.5, duration: 0.5),
        SrtWordModel(word: "world", start: 0.6, end: 1.0, duration: 0.4),
      ];

      // Act
      List<SrtWordModel> result =
          srtClean.fillMissingWords(originalText, words);

      // Assert
      expect(result[0].word, equals("Hello"));
      expect(result[1].word, equals("world"));
    });

    test('should handle sentence with no empty words', () {
      // Arrange
      String originalText = "Bonjour tout le monde";
      List<SrtWordModel> words = [
        SrtWordModel(word: "Bonjour", start: 0.0, end: 0.5, duration: 0.5),
        SrtWordModel(word: "tout", start: 0.5, end: 0.8, duration: 0.3),
        SrtWordModel(word: "le", start: 0.8, end: 1.0, duration: 0.2),
        SrtWordModel(word: "monde", start: 1.0, end: 1.4, duration: 0.4),
      ];

      // Act
      List<SrtWordModel> result =
          srtClean.fillMissingWords(originalText, words);

      // Assert
      expect(result[0].word, equals("Bonjour"));
      expect(result[1].word, equals("tout"));
      expect(result[2].word, equals("le"));
      expect(result[3].word, equals("monde"));
    });

    test('should handle missing characters with punctuation', () {
      // Arrange
      String originalText = "C'est 100\$ et";
      List<SrtWordModel> words = [
        SrtWordModel(word: "C", start: 0.0, end: 0.2, duration: 0.2),
        SrtWordModel(word: "est", start: 0.2, end: 0.5, duration: 0.3),
        SrtWordModel(word: "100", start: 0.5, end: 1.0, duration: 0.5),
        SrtWordModel(word: "", start: 1.0, end: 1.2, duration: 0.2),
        SrtWordModel(word: "et", start: 1.2, end: 1.4, duration: 0.2),
      ];

      // Act
      List<SrtWordModel> result =
          srtClean.fillMissingWords(originalText, words);

      // Assert
      expect(result[3].word, equals("\$"));
    });

    test('should return an empty list if words list is empty', () {
      // Arrange
      String originalText = "Some text";
      List<SrtWordModel> words = [];

      // Act
      List<SrtWordModel> result =
          srtClean.fillMissingWords(originalText, words);

      // Assert
      expect(result, isEmpty);
    });
  });

  group('findMissingCharacter', () {
    test('should return missing character when word is empty', () {
      // Arrange
      String originalText = "1,6% et entraîne";
      List<SrtWordModel> words = [
        SrtWordModel(word: "1", start: 0.0, end: 0.3, duration: 0.3),
        SrtWordModel(word: "6", start: 0.3, end: 0.6, duration: 0.3),
        SrtWordModel(word: "", start: 0.6, end: 0.9, duration: 0.3),
        SrtWordModel(word: "et", start: 0.9, end: 1.2, duration: 0.3),
      ];

      // Act
      String result = srtClean.findMissingCharacter(originalText, words, 0, 2);

      // Assert
      expect(result, equals("%"));
    });

    test('should return empty string if no missing character is found', () {
      // Arrange
      String originalText = "Hello world";
      List<SrtWordModel> words = [
        SrtWordModel(word: "Hello", start: 0.0, end: 0.5, duration: 0.5),
        SrtWordModel(word: "world", start: 0.6, end: 1.0, duration: 0.4),
      ];

      // Act
      String result = srtClean.findMissingCharacter(originalText, words, 0, 1);

      // Assert
      expect(result, equals(""));
    });
  });
}
