import 'package:unorm_dart/unorm_dart.dart' as unorm;
import 'package:x_video_ai/models/srt_sentence_model.dart';
import 'package:x_video_ai/models/srt_word_model.dart';

class Sentence {
  // Liste des abréviations courantes à ne pas considérer comme fin de phrase.
  final List<String> abbreviations = [
    'Mr.',
    'Mrs.',
    'Ms.',
    'Dr.',
    'Prof.',
    'Jr.',
    'Sr.',
    'M.',
    'Mme.',
    'Mlle.',
    'St.',
    'p.m.'
  ];

  bool containSpecialChar(String word) {
    return RegExp(r"['’-]").hasMatch(word);
  }

  List<String> splitSentences(String text) {
    // Expression régulière mise à jour pour gérer les guillemets et parenthèses correctement
    final RegExp sentencePattern = RegExp(
      r'(?<!\b(?:\d{1,3}(?:,\d{3})*|\b[A-Z][a-z]*\.)\b)(?<=[.!?]["”’\)])\s+(?=\S)|(?<=[.!?])\s+(?=\S)|(?<=[,!?])\s+(?!\d)',
    );

    // Découper les phrases en utilisant la regex définie
    List<String> sentences =
        text.split(sentencePattern).map((sentence) => sentence.trim()).toList();

    // Recombiner les abréviations
    sentences = _recombineAbbreviations(sentences);

    // Retourner la liste des phrases en enlevant les phrases vides
    return sentences
        .where((sentence) => sentence.isNotEmpty && sentence != ".")
        .toList();
  }

  String normalizeSequence(String text) {
    return unorm
        .nfd(text) // Normalise les caractères (décomposition)
        .replaceAll(RegExp(r'[\u0300-\u036f]'), '') // Retire les accents
        .replaceAll(RegExp(r"[^\w\s]"),
            ' ') // Remplace les caractères non-alphanumériques par des espaces (y compris les apostrophes)
        .replaceAll(RegExp(r'\s+'),
            ' ') // Remplace les espaces multiples par un seul espace
        .trim() // Supprime les espaces de début et de fin
        .toLowerCase(); // Convertit en minuscules
  }

  bool isMatchingSequence(
    List<SrtWordModel> words,
    List<String> normalizedWords,
    int startIndex, {
    double lastTime = 0,
  }) {
    for (int j = 0; j < normalizedWords.length; j++) {
      // Vérification d'abord que l'index est dans les limites
      if (startIndex + j >= words.length) {
        return false;
      }

      // Vérification si le mot est vide ou si le début du mot est NaN
      if (words[startIndex + j].word.isEmpty ||
          words[startIndex + j].start.isNaN) {
        return false;
      }

      // Vérification si le mot ne correspond pas ou si le début du mot est avant `lastTime`
      if (normalizeSequence(words[startIndex + j].word) != normalizedWords[j] ||
          words[startIndex + j].start < lastTime) {
        return false;
      }
    }
    return true;
  }

  SrtSentenceModel groupWords(
    SrtSentenceModel sentence,
  ) {
    // Découper la phrase en mots
    final sentenceWords = sentence.sentence.split(' ');
    // Mapper les mots pour les grouper
    final List<SrtWordModel?> combinedWords = sentenceWords.map((word) {
      // Essayer de créer un groupe de mots
      SrtWordModel? result = createGroupedWord(
        word,
        sentence.words!,
      );

      // Si le groupe n'a pas été trouvé, essayer avec les mots normalisés
      if (result == null) {
        final normalizedWords = normalizeSequence(word)
            .split(' ')
            .where((w) => w.isNotEmpty)
            .toList();

        result = setGroupedWord(
          word,
          normalizedWords,
          sentence.words!,
        );
      }

      return result;
    }).toList();

    // Retourner une nouvelle instance de SrtSentenceModel avec les mots groupés
    return SrtSentenceModel(
      sentence: sentence.sentence,
      normalized: sentence.normalized,
      words: sentence.words,
      group: combinedWords
          .where((word) => word != null)
          .cast<SrtWordModel>()
          .toList(),
      start: sentence.start,
      end: sentence.end,
      duration: sentence.duration,
    );
  }

  SrtWordModel? setGroupedWord(
    String word,
    List<String> splittedWord,
    List<SrtWordModel> words,
  ) {
    double? start;
    double? end;
    int indexSplit = 0;
    int foundWords = 0; // Compter le nombre de mots trouvés

    // Parcourt chaque mot divisé de la phrase
    while (indexSplit < splittedWord.length) {
      int startIndex = 0;

      // Parcourt chaque mot du SRT
      bool found = false;
      while (startIndex < words.length) {
        // Compare les mots après normalisation
        if (normalizeSequence(words[startIndex].word) ==
            normalizeSequence(splittedWord[indexSplit])) {
          if (indexSplit == 0) {
            start = words[startIndex].start;
          }
          end = words[startIndex].end;
          found = true;
          foundWords++;
          break; // On arrête la recherche dès qu'on a trouvé le mot
        }
        startIndex++;
      }

      // Si un des mots n'est pas trouvé, on arrête
      if (!found) {
        return null;
      }

      indexSplit++;
    }

    // Si on n'a pas trouvé tous les mots du mot divisé, on retourne null
    if (foundWords != splittedWord.length) {
      return null;
    }

    // Si on a trouvé les mots, on retourne l'objet SrtWordModel
    if (start != null && end != null) {
      return SrtWordModel(
        word: word,
        start: start,
        end: end,
        duration: end - start,
      );
    }

    return null; // Si on n'a pas trouvé de correspondance valable
  }

  SrtWordModel? createGroupedWord(
    String word,
    List<SrtWordModel> words,
  ) {
    // Si le mot contient un caractère spécial
    if (containSpecialChar(word)) {
      // Diviser le mot avec les caractères spéciaux
      final splittedWord = word.split(RegExp(r"['’-]"));

      // Essayer de grouper le mot
      return setGroupedWord(word, splittedWord, words);
    }

    // Parcourir les mots pour trouver une correspondance normalisée
    for (final wordModel in words) {
      if (normalizeSequence(wordModel.word) == normalizeSequence(word)) {
        // Retourner le mot avec la durée calculée
        return SrtWordModel(
          word: word,
          start: wordModel.start,
          end: wordModel.end,
          duration: wordModel.end - wordModel.start,
        );
      }
    }

    // Retourner null si aucun mot correspondant n'a été trouvé
    return null;
  }

  SrtSentenceModel? findSentenceTiming(
    SrtSentenceModel sentence,
    List<SrtWordModel> words, {
    double lastTime = 0,
  }) {
    if (words.any((w) => w.word.isEmpty)) {
      throw ArgumentError('Words should not be empty');
    }

    final List<String> normalizedWords = sentence.normalized
        .split(' ')
        .where((word) => word.isNotEmpty)
        .toList();

    for (int i = 0; i < words.length; i++) {
      if (normalizeSequence(words[i].word) == normalizedWords[0]) {
        if (isMatchingSequence(words, normalizedWords, i, lastTime: lastTime)) {
          final matchingWords = words.sublist(i, i + normalizedWords.length);

          return groupWords(
            SrtSentenceModel(
              sentence: sentence.sentence,
              normalized: sentence.normalized,
              start: matchingWords.first.start,
              end: matchingWords.last.end,
              duration: matchingWords.last.end - matchingWords.first.start,
              words: matchingWords,
              group: [],
            ),
          );
        }
      }
    }

    return null;
  }

  List<SrtSentenceModel> findSentencesTiming(
    List<SrtSentenceModel> sentences,
    List<SrtWordModel> words,
  ) {
    List<SrtSentenceModel> result = [];
    double lastTime = 0;

    for (final sentence in sentences) {
      final foundSentence = findSentenceTiming(
        sentence,
        words,
        lastTime: lastTime,
      );

      if (foundSentence != null) {
        result.add(foundSentence);
        lastTime = foundSentence.end;
      }
    }

    return result;
  }

  // Méthode pour recombiner les phrases coupées à cause des abréviations
  List<String> _recombineAbbreviations(List<String> sentences) {
    List<String> result = [];
    String buffer = '';

    for (int i = 0; i < sentences.length; i++) {
      String sentence = sentences[i];

      // Si le buffer est vide et la phrase courante est une abréviation, combiner avec la prochaine
      if (abbreviations.any((abbr) => sentence.endsWith(abbr)) &&
          i + 1 < sentences.length) {
        buffer = buffer.isEmpty ? sentence : '$buffer $sentence';

        // Combiner avec la phrase suivante, si elle ne commence pas une nouvelle phrase
        buffer = '$buffer ${sentences[i + 1]}';
        i++; // Ignorer la phrase suivante car elle est déjà combinée

        result.add(buffer);
        buffer =
            ''; // Réinitialiser le buffer après avoir ajouté la phrase combinée
      } else {
        result.add(sentence);
      }
    }

    return result;
  }
}
