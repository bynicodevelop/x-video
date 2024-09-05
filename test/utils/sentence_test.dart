import 'package:flutter_test/flutter_test.dart';
import 'package:x_video_ai/models/srt_sentence_model.dart';
import 'package:x_video_ai/models/srt_word_model.dart';
import 'package:x_video_ai/utils/sentence.dart';

void main() {
  late Sentence sentence;

  group('containSpecialChar', () {
    setUp(() {
      sentence = Sentence();
    });

    test('should return true for word containing single quote', () {
      const word = "test's";
      final result = sentence.containSpecialChar(word);
      expect(result, isTrue);
    });

    test('should return true for word containing typographic apostrophe', () {
      const word = "test’s";
      final result = sentence.containSpecialChar(word);
      expect(result, isTrue);
    });

    test('should return true for word containing hyphen', () {
      const word = "test-case";
      final result = sentence.containSpecialChar(word);
      expect(result, isTrue);
    });

    test('should return false for word without special characters', () {
      const word = "test";
      final result = sentence.containSpecialChar(word);
      expect(result, isFalse);
    });

    test('should return false for empty string', () {
      const word = "";
      final result = sentence.containSpecialChar(word);
      expect(result, isFalse);
    });

    test('should return true for word containing multiple special characters',
        () {
      const word = "it's-test’s";
      final result = sentence.containSpecialChar(word);
      expect(result, isTrue);
    });
  });

  group('splitSentences', () {
    setUp(() {
      sentence = Sentence();
    });

    test('should split text into sentences correctly', () {
      const text = "Hello! How are you? This is a test.";
      final expected = ["Hello!", "How are you?", "This is a test."];

      final result = sentence.splitSentences(text);

      expect(result, equals(expected));
    });

    test('should handle text with no punctuation', () {
      const text = "This is just a plain text with no punctuation";
      final expected = ["This is just a plain text with no punctuation"];

      final result = sentence.splitSentences(text);

      expect(result, equals(expected));
    });

    test('should handle multiple spaces between sentences', () {
      const text = "Sentence one.  Sentence two!   Sentence three?";
      final expected = ["Sentence one.", "Sentence two!", "Sentence three?"];

      final result = sentence.splitSentences(text);

      expect(result, equals(expected));
    });

    test('should handle numbers and abbreviations correctly', () {
      const text = "The price is 1,200. Is it correct? Mr. Smith said yes!";
      final expected = [
        "The price is 1,200.",
        "Is it correct?",
        "Mr. Smith said yes!"
      ];

      final result = sentence.splitSentences(text);

      expect(result, equals(expected));
    });

    test('should return empty list for empty input', () {
      const text = "";
      final expected = <String>[];

      final result = sentence.splitSentences(text);

      expect(result, equals(expected));
    });

    test('should remove empty sentences', () {
      const text = "Hello.  . This is a test.";
      final expected = ["Hello.", "This is a test."];

      final result = sentence.splitSentences(text);

      expect(result, equals(expected));
    });

    test('should handle abbreviations at the end of sentences', () {
      const text = "We met Dr. Smith. He is a good person.";
      final expected = ["We met Dr. Smith.", "He is a good person."];

      final result = sentence.splitSentences(text);

      expect(result, equals(expected));
    });

    test('should handle multiple abbreviations in one sentence', () {
      const text = "Mr. and Mrs. Johnson arrived at 5 p.m.";
      final expected = ["Mr. and Mrs.", "Johnson arrived at 5 p.m."];

      final result = sentence.splitSentences(text);

      expect(result, equals(expected));
    });

    test('should handle newlines between sentences', () {
      const text = "First sentence.\nSecond sentence!\nThird sentence?";
      final expected = [
        "First sentence.",
        "Second sentence!",
        "Third sentence?"
      ];

      final result = sentence.splitSentences(text);

      expect(result, equals(expected));
    });

    test('should handle sentences with only numbers and punctuation', () {
      const text = "The result is 3.14. Is it correct?";
      final expected = ["The result is 3.14.", "Is it correct?"];

      final result = sentence.splitSentences(text);

      expect(result, equals(expected));
    });

    test(
        'should not split on exclamation or question marks in the middle of a sentence',
        () {
      const text = "This is amazing! Isn't it? Let's continue.";
      final expected = ["This is amazing!", "Isn't it?", "Let's continue."];

      final result = sentence.splitSentences(text);

      expect(result, equals(expected));
    });
  });

  group('normalizeSequence', () {
    setUp(() {
      sentence = Sentence();
    });

    test('should normalize accented characters and convert to lowercase', () {
      const text = "Café Élégant";
      const expected = "cafe elegant";

      final result = sentence.normalizeSequence(text);

      expect(result, equals(expected));
    });

    test('should remove special characters and keep alphanumerics', () {
      const text = "Hello! This is a test.";
      const expected = "hello this is a test";

      final result = sentence.normalizeSequence(text);

      expect(result, equals(expected));
    });

    test('should remove multiple special characters', () {
      const text = "Let's test some special characters: %^&*()!";
      const expected = "let s test some special characters";

      final result = sentence.normalizeSequence(text);

      expect(result, equals(expected));
    });

    test('should handle numbers correctly', () {
      const text = "The price is 1,200.50!";
      const expected = "the price is 1 200 50";

      final result = sentence.normalizeSequence(text);

      expect(result, equals(expected));
    });

    test('should remove accents and trim white spaces', () {
      const text = "   àéïöû  ";
      const expected = "aeiou";

      final result = sentence.normalizeSequence(text);

      expect(result, equals(expected));
    });

    test('should handle empty string', () {
      const text = "";
      const expected = "";

      final result = sentence.normalizeSequence(text);

      expect(result, equals(expected));
    });

    test('should handle string with only special characters', () {
      const text = "@#\$%^&*()!";
      const expected = "";

      final result = sentence.normalizeSequence(text);

      expect(result, equals(expected));
    });

    test('should handle string with underscores', () {
      const text = "This_is_a_test_string";
      const expected = "this_is_a_test_string";

      final result = sentence.normalizeSequence(text);

      expect(result, equals(expected));
    });
  });

  group('isMatchingSequence', () {
    setUp(() {
      sentence = Sentence();
    });

    test('should return true for a matching sequence', () {
      final List<SrtWordModel> words = [
        SrtWordModel(word: "Hello", start: 0.0, end: 1.0, duration: 1),
        SrtWordModel(word: "world", start: 1.0, end: 2.0, duration: 1),
      ];
      final List<String> normalizedWords = ["hello", "world"];

      final result = sentence.isMatchingSequence(words, normalizedWords, 0);

      expect(result, isTrue);
    });

    test('should return false for a non-matching sequence', () {
      final List<SrtWordModel> words = [
        SrtWordModel(word: "Hello", start: 0.0, end: 1.0, duration: 1),
        SrtWordModel(word: "everyone", start: 1.0, end: 2.0, duration: 1),
      ];
      final List<String> normalizedWords = ["hello", "world"];

      final result = sentence.isMatchingSequence(words, normalizedWords, 0);

      expect(result, isFalse);
    });

    test('should return false if word is empty', () {
      final List<SrtWordModel> words = [
        SrtWordModel(word: "", start: 0.0, end: 1.0, duration: 1),
        SrtWordModel(word: "world", start: 1.0, end: 2.0, duration: 1),
      ];
      final List<String> normalizedWords = ["hello", "world"];

      final result = sentence.isMatchingSequence(words, normalizedWords, 0);

      expect(result, isFalse);
    });

    test('should return false if word start time is NaN', () {
      final List<SrtWordModel> words = [
        SrtWordModel(word: "Hello", start: double.nan, end: 1.0, duration: 1),
        SrtWordModel(word: "world", start: 1.0, end: 2.0, duration: 1),
      ];
      final List<String> normalizedWords = ["hello", "world"];

      final result = sentence.isMatchingSequence(words, normalizedWords, 0);

      expect(result, isFalse);
    });

    test('should return false if startIndex + j exceeds word list length', () {
      final List<SrtWordModel> words = [
        SrtWordModel(word: "Hello", start: 0.0, end: 1.0, duration: 1),
        SrtWordModel(word: "world", start: 1.0, end: 2.0, duration: 1),
      ];
      final List<String> normalizedWords = ["hello", "world", "extra"];

      final result = sentence.isMatchingSequence(words, normalizedWords, 0);

      expect(result, isFalse);
    });

    test(
        'should respect lastTime constraint and return false if start is before lastTime',
        () {
      final List<SrtWordModel> words = [
        SrtWordModel(word: "Hello", start: 0.5, end: 1.0, duration: 1),
        SrtWordModel(word: "world", start: 1.0, end: 2.0, duration: 1),
      ];
      final List<String> normalizedWords = ["hello", "world"];

      final result =
          sentence.isMatchingSequence(words, normalizedWords, 0, lastTime: 0.8);

      expect(result, isFalse);
    });

    test(
        'should return true if all words match and lastTime constraint is respected',
        () {
      final List<SrtWordModel> words = [
        SrtWordModel(word: "Hello", start: 1.0, end: 2.0, duration: 1),
        SrtWordModel(word: "world", start: 2.0, end: 3.0, duration: 1),
      ];
      final List<String> normalizedWords = ["hello", "world"];

      final result =
          sentence.isMatchingSequence(words, normalizedWords, 0, lastTime: 0.5);

      expect(result, isTrue);
    });
  });

  group('groupWords', () {
    setUp(() {
      sentence = Sentence();
    });

    test('should group simple words correctly', () {
      // Arrange
      final srtSentence = SrtSentenceModel(
        sentence: "hello world",
        normalized: "1.0",
        words: [
          SrtWordModel(word: 'hello', start: 0.0, end: 0.5, duration: 0.5),
          SrtWordModel(word: 'world', start: 0.6, end: 1.0, duration: 0.4),
        ],
        group: [],
        start: 0.0,
        end: 1.0,
        duration: 1.0,
      );

      // Act
      final result = sentence.groupWords(srtSentence);

      // Assert
      expect(result.group!.length, equals(2));
      expect(result.group![0].word, equals("hello"));
      expect(result.group![1].word, equals("world"));
    });

    test('should handle words with special characters correctly', () {
      // Arrange
      final srtSentence = SrtSentenceModel(
        sentence: "it's a test-case",
        normalized: "1.0",
        words: [
          SrtWordModel(word: 'it', start: 0.0, end: 0.3, duration: 0.3),
          SrtWordModel(word: 's', start: 0.3, end: 0.4, duration: 0.1),
          SrtWordModel(word: 'a', start: 0.5, end: 0.6, duration: 0.1),
          SrtWordModel(word: 'test', start: 0.7, end: 1.0, duration: 0.3),
          SrtWordModel(word: 'case', start: 1.1, end: 1.5, duration: 0.4),
        ],
        group: [],
        start: 0.0,
        end: 1.5,
        duration: 1.5,
      );

      // Act
      final result = sentence.groupWords(srtSentence);

      // Assert
      expect(result.group!.length, equals(3));
      expect(result.group![0].word, equals("it's"));
      expect(result.group![1].word, equals("a"));
      expect(result.group![2].word, equals("test-case"));
    });

    test('should return empty group when sentence has no matching words', () {
      // Arrange
      final srtSentence = SrtSentenceModel(
        sentence: "non matching sentence",
        normalized: "1.0",
        words: [
          SrtWordModel(word: 'hello', start: 0.0, end: 0.5, duration: 0.5),
          SrtWordModel(word: 'world', start: 0.6, end: 1.0, duration: 0.4),
        ],
        group: [],
        start: 0.0,
        end: 1.0,
        duration: 1.0,
      );

      // Act
      final result = sentence.groupWords(srtSentence);

      // Assert
      expect(result.group!.isEmpty, isTrue);
    });

    test('should normalize and group words with mixed cases correctly', () {
      // Arrange
      final srtSentence = SrtSentenceModel(
        sentence: "HELLO world",
        normalized: "hello world",
        words: [
          SrtWordModel(word: 'hello', start: 0.0, end: 0.5, duration: 0.5),
          SrtWordModel(word: 'world', start: 0.6, end: 1.0, duration: 0.4),
        ],
        group: [],
        start: 0.0,
        end: 1.0,
        duration: 1.0,
      );

      // Act
      final result = sentence.groupWords(srtSentence);

      // Assert
      expect(result.group!.length, equals(2));
      expect(result.group![0].word,
          equals("HELLO")); // attendu en minuscule après normalisation
      expect(result.group![1].word, equals("world"));
    });

    test('should handle cases where normalized word matches SRT words', () {
      // Arrange
      final srtSentence = SrtSentenceModel(
        sentence: "HELLO-World",
        normalized: "1.0",
        words: [
          SrtWordModel(word: 'hello', start: 0.0, end: 0.5, duration: 0.5),
          SrtWordModel(word: 'world', start: 0.6, end: 1.0, duration: 0.4),
        ],
        group: [],
        start: 0.0,
        end: 1.0,
        duration: 1.0,
      );

      // Act
      final result = sentence.groupWords(srtSentence);

      // Assert
      expect(result.group!.length, equals(1));
      expect(result.group![0].word, equals("HELLO-World"));
      expect(result.group![0].start, equals(0.0));
      expect(result.group![0].end, equals(1.0));
    });

    test('should handle cases where normalized word matches SRT words', () {
      // Arrange
      final srtSentence = SrtSentenceModel(
        sentence: "TotalEnergie,",
        normalized: "totalenergie",
        words: [
          SrtWordModel(
            word: 'TotalEnergie',
            start: 0.0,
            end: 0.5,
            duration: 0.5,
          ),
        ],
        group: [],
        start: 0.0,
        end: 1.0,
        duration: 1.0,
      );

      // Act
      final result = sentence.groupWords(srtSentence);

      // Assert
      expect(result.group!.length, equals(1));
      expect(result.group![0].word, equals("TotalEnergie,"));
    });
  });

  group('setGroupedWord', () {
    setUp(() {
      sentence = Sentence();
    });

    test('should return correct SrtWordModel when words match', () {
      // Arrange
      const word = "hello-world";
      final splittedWord = ['hello', 'world'];
      final words = [
        SrtWordModel(word: 'hello', start: 0.0, end: 0.5, duration: 0.5),
        SrtWordModel(word: 'world', start: 0.6, end: 1.0, duration: 0.4),
      ];

      // Act
      final result = sentence.setGroupedWord(word, splittedWord, words)!;

      // Assert
      expect(result.word, equals(word));
      expect(result.start, equals(0.0));
      expect(result.end, equals(1.0));
      expect(result.duration, equals(1.0));
    });

    test('should handle words with special characters correctly', () {
      // Arrange
      const word = "it's-test";
      final splittedWord = ["it", "s", 'test'];
      final words = [
        SrtWordModel(word: 'it', start: 0.0, end: 0.3, duration: 0.3),
        SrtWordModel(word: 's', start: 0.3, end: 0.4, duration: 0.1),
        SrtWordModel(word: 'test', start: 0.5, end: 1.0, duration: 0.5),
      ];

      // Act
      final result = sentence.setGroupedWord(word, splittedWord, words)!;

      // Assert
      expect(result.word, equals(word));
      expect(result.start, equals(0.0));
      expect(result.end, equals(1.0));
      expect(result.duration, equals(1.0));
    });

    test('should return first start and last end time', () {
      // Arrange
      const word = "united-states";
      final splittedWord = ['united', 'states'];
      final words = [
        SrtWordModel(word: 'united', start: 1.0, end: 1.5, duration: 0.5),
        SrtWordModel(word: 'states', start: 1.6, end: 2.0, duration: 0.4),
      ];

      // Act
      final result = sentence.setGroupedWord(word, splittedWord, words)!;

      // Assert
      expect(result.start, equals(1.0));
      expect(result.end, equals(2.0));
      expect(result.duration, equals(1.0));
    });

    test('should handle single word correctly', () {
      // Arrange
      const word = "hello";
      final splittedWord = ['hello'];
      final words = [
        SrtWordModel(word: 'hello', start: 0.0, end: 0.5, duration: 0.5),
      ];

      // Act
      final result = sentence.setGroupedWord(word, splittedWord, words)!;

      // Assert
      expect(result.word, equals(word));
      expect(result.start, equals(0.0));
      expect(result.end, equals(0.5));
      expect(result.duration, equals(0.5));
    });

    test('should return correct duration when word spans multiple timings', () {
      // Arrange
      const word = "long-compound-word";
      final splittedWord = ['long', 'compound', 'word'];
      final words = [
        SrtWordModel(word: 'long', start: 0.0, end: 0.5, duration: 0.5),
        SrtWordModel(word: 'compound', start: 0.6, end: 1.2, duration: 0.6),
        SrtWordModel(word: 'word', start: 1.3, end: 2.0, duration: 0.7),
      ];

      // Act
      final result = sentence.setGroupedWord(word, splittedWord, words)!;

      // Assert
      expect(result.start, equals(0.0));
      expect(result.end, equals(2.0));
      expect(result.duration, equals(2.0));
    });

    test('should handle case where word does not match any SRT word', () {
      // Arrange
      const word = "non-matching";
      final splittedWord = ['non', 'matching'];
      final words = [
        SrtWordModel(word: 'hello', start: 0.0, end: 0.5, duration: 0.5),
        SrtWordModel(word: 'world', start: 0.6, end: 1.0, duration: 0.4),
      ];

      // Act
      final result = sentence.setGroupedWord(word, splittedWord, words);

      // Assert
      expect(result, isNull);
    });
  });

  group('createGroupedWord', () {
    setUp(() {
      sentence = Sentence();
    });

    test('should group word with special characters', () {
      // Arrange
      const word = "it’s-test";
      final words = [
        SrtWordModel(word: 'it', start: 0.0, end: 0.3, duration: 0.3),
        SrtWordModel(word: 's', start: 0.3, end: 0.4, duration: 0.1),
        SrtWordModel(word: 'test', start: 0.5, end: 1.0, duration: 0.5),
      ];

      // Act
      final result = sentence.createGroupedWord(word, words)!;

      // Assert
      expect(result.word, equals(word));
      expect(result.start, equals(0.0));
      expect(result.end, equals(1.0));
      expect(result.duration, equals(1.0));
    });

    test('should handle single word without special characters', () {
      // Arrange
      const word = "hello";
      final words = [
        SrtWordModel(word: 'hello', start: 0.0, end: 0.5, duration: 0.5),
        SrtWordModel(word: 'world', start: 0.6, end: 1.0, duration: 0.4),
      ];

      // Act
      final result = sentence.createGroupedWord(word, words)!;

      // Assert
      expect(result.word, equals("hello"));
      expect(result.start, equals(0.0));
      expect(result.end, equals(0.5));
      expect(result.duration, equals(0.5));
    });

    test('should handle words with hyphens', () {
      // Arrange
      const word = "non-matching";
      final words = [
        SrtWordModel(word: 'non', start: 0.0, end: 0.5, duration: 0.5),
        SrtWordModel(word: 'matching', start: 0.6, end: 1.0, duration: 0.4),
      ];

      // Act
      final result = sentence.createGroupedWord(word, words)!;

      // Assert
      expect(result.word, equals("non-matching"));
      expect(result.start, equals(0.0));
      expect(result.end, equals(1.0));
      expect(result.duration, equals(1.0));
    });

    test('should return null for non-matching word', () {
      // Arrange
      const word = "different";
      final words = [
        SrtWordModel(word: 'hello', start: 0.0, end: 0.5, duration: 0.5),
        SrtWordModel(word: 'world', start: 0.6, end: 1.0, duration: 0.4),
      ];

      // Act
      final result = sentence.createGroupedWord(word, words);

      // Assert
      expect(result, isNull);
    });

    test('should handle empty word list', () {
      // Arrange
      const word = "hello";
      final words = <SrtWordModel>[];

      // Act
      final result = sentence.createGroupedWord(word, words);

      // Assert
      expect(result, isNull);
    });

    test('should group word with apostrophes correctly', () {
      // Arrange
      const word = "it's";
      final words = [
        SrtWordModel(word: 'it', start: 0.0, end: 0.3, duration: 0.3),
        SrtWordModel(word: 's', start: 0.3, end: 0.4, duration: 0.1),
      ];

      // Act
      final result = sentence.createGroupedWord(word, words)!;

      // Assert
      expect(result.word, equals("it's"));
      expect(result.start, equals(0.0));
      expect(result.end, equals(0.4));
      expect(result.duration, equals(0.4));
    });
  });

  group('findSentenceTiming', () {
    setUp(() {
      sentence = Sentence();
    });

    test('should return correct timing for matching sentence', () {
      // Arrange
      final sentenceModel = SrtSentenceModel(
        sentence: 'Hello world',
        normalized: 'hello world',
        words: [],
        group: [],
        start: 0.0,
        end: 0.0,
        duration: 0.0,
      );

      final words = [
        SrtWordModel(word: 'hello', start: 0.0, end: 0.5, duration: 0.5),
        SrtWordModel(word: 'world', start: 0.6, end: 1.0, duration: 0.4),
      ];

      // Act
      final result = sentence.findSentenceTiming(sentenceModel, words);

      // Assert
      expect(result, isNotNull);
      expect(result!.start, equals(0.0));
      expect(result.end, equals(1.0));
      expect(result.duration, equals(1.0));
    });

    test('should return null when no matching sequence is found', () {
      // Arrange
      final sentenceModel = SrtSentenceModel(
        sentence: 'Goodbye world',
        normalized: 'goodbye world',
        words: [],
        group: [],
        start: 0.0,
        end: 0.0,
        duration: 0.0,
      );

      final words = [
        SrtWordModel(word: 'hello', start: 0.0, end: 0.5, duration: 0.5),
        SrtWordModel(word: 'world', start: 0.6, end: 1.0, duration: 0.4),
      ];

      // Act
      final result = sentence.findSentenceTiming(sentenceModel, words);

      // Assert
      expect(result, isNull);
    });

    test('should throw error if any word is empty', () {
      // Arrange
      final sentenceModel = SrtSentenceModel(
        sentence: 'Hello world',
        normalized: 'hello world',
        words: [],
        group: [],
        start: 0.0,
        end: 0.0,
        duration: 0.0,
      );

      final words = [
        SrtWordModel(word: '', start: 0.0, end: 0.5, duration: 0.5),
        SrtWordModel(word: 'world', start: 0.6, end: 1.0, duration: 0.4),
      ];

      // Act & Assert
      expect(
        () => sentence.findSentenceTiming(sentenceModel, words),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should return correct timing when multiple words match', () {
      // Arrange
      final sentenceModel = SrtSentenceModel(
        sentence: 'The quick brown fox',
        normalized: 'the quick brown fox',
        words: [],
        group: [],
        start: 0.0,
        end: 0.0,
        duration: 0.0,
      );

      final words = [
        SrtWordModel(word: 'the', start: 0.0, end: 0.3, duration: 0.3),
        SrtWordModel(word: 'quick', start: 0.4, end: 0.7, duration: 0.3),
        SrtWordModel(word: 'brown', start: 0.8, end: 1.1, duration: 0.3),
        SrtWordModel(word: 'fox', start: 1.2, end: 1.5, duration: 0.3),
      ];

      // Act
      final result = sentence.findSentenceTiming(sentenceModel, words);

      // Assert
      expect(result, isNotNull);
      expect(result!.start, equals(0.0));
      expect(result.end, equals(1.5));
      expect(result.duration, equals(1.5));
    });

    test(
        'should handle partial match but return null if sequence does not match fully',
        () {
      // Arrange
      final sentenceModel = SrtSentenceModel(
        sentence: 'Hello quick fox',
        normalized: 'hello quick fox',
        words: [],
        group: [],
        start: 0.0,
        end: 0.0,
        duration: 0.0,
      );

      final words = [
        SrtWordModel(word: 'hello', start: 0.0, end: 0.5, duration: 0.5),
        SrtWordModel(word: 'quick', start: 0.6, end: 1.0, duration: 0.4),
        SrtWordModel(word: 'brown', start: 1.1, end: 1.5, duration: 0.4),
      ];

      // Act
      final result = sentence.findSentenceTiming(sentenceModel, words);

      // Assert
      expect(result, isNull);
    });
  });

  group('findSentencesTiming', () {
    setUp(() {
      sentence = Sentence();
    });

    test('should return correct sentence timings when matching', () {
      // Arrange
      final sentences = [
        SrtSentenceModel(
          sentence: "Hello world",
          normalized: "hello world",
          words: [],
          group: [],
          start: 0.0,
          end: 0.0,
          duration: 0.0,
        ),
        SrtSentenceModel(
          sentence: "How are you",
          normalized: "how are you",
          words: [],
          group: [],
          start: 0.0,
          end: 0.0,
          duration: 0.0,
        ),
      ];

      final words = [
        SrtWordModel(word: 'Hello', start: 0.0, end: 0.5, duration: 0.5),
        SrtWordModel(word: 'world', start: 0.6, end: 1.0, duration: 0.4),
        SrtWordModel(word: 'How', start: 1.1, end: 1.5, duration: 0.4),
        SrtWordModel(word: 'are', start: 1.6, end: 2.0, duration: 0.4),
        SrtWordModel(word: 'you', start: 2.1, end: 2.5, duration: 0.4),
      ];

      // Act
      final result = sentence.findSentencesTiming(sentences, words);

      // Assert
      expect(result.length, equals(2));
      expect(result[0].start, equals(0.0));
      expect(result[0].end, equals(1.0));
      expect(result[1].start, equals(1.1));
      expect(result[1].end, equals(2.5));
    });

    test('should return empty result when no matching words', () {
      // Arrange
      final sentences = [
        SrtSentenceModel(
          sentence: "No match",
          normalized: "1.0",
          words: [],
          group: [],
          start: 0.0,
          end: 0.0,
          duration: 0.0,
        ),
      ];

      final words = [
        SrtWordModel(word: 'Hello', start: 0.0, end: 0.5, duration: 0.5),
        SrtWordModel(word: 'world', start: 0.6, end: 1.0, duration: 0.4),
      ];

      // Act
      final result = sentence.findSentencesTiming(sentences, words);

      // Assert
      expect(result.length, equals(0)); // No matching words
    });

    test('should handle case where no sentences are provided', () {
      // Arrange
      final sentences = <SrtSentenceModel>[];
      final words = [
        SrtWordModel(word: 'Hello', start: 0.0, end: 0.5, duration: 0.5),
      ];

      // Act
      final result = sentence.findSentencesTiming(sentences, words);

      // Assert
      expect(result.isEmpty, isTrue); // Should return an empty list
    });

    test('should handle overlapping times correctly', () {
      // Arrange
      final sentences = [
        SrtSentenceModel(
          sentence: "Hello world",
          normalized: "hello world",
          words: [],
          group: [],
          start: 0.0,
          end: 0.0,
          duration: 0.0,
        ),
      ];

      final words = [
        SrtWordModel(word: 'Hello', start: 0.0, end: 0.5, duration: 0.5),
        SrtWordModel(word: 'world', start: 0.3, end: 1.0, duration: 0.7),
      ];

      // Act
      final result = sentence.findSentencesTiming(sentences, words);

      // Assert
      expect(result.length, equals(1));
      expect(result[0].start, equals(0.0));
      expect(result[0].end, equals(1.0)); // Last word end time
    });
  });
}
