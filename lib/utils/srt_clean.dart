import 'package:x_video_ai/models/srt_word_model.dart';

class SrtClean {
  List<SrtWordModel> fillMissingWords(
    String originalText,
    List<SrtWordModel> words,
  ) {
    List<SrtWordModel> updatedWords = [];
    int textIndex = 0;

    for (int i = 0; i < words.length; i++) {
      if (words[i].word.isEmpty) {
        // Chercher dans le texte original pour remplacer la chaîne vide
        String missingChar =
            findMissingCharacter(originalText, words, textIndex, i);
        updatedWords.add(SrtWordModel(
          word: missingChar,
          start: words[i].start,
          end: words[i].end,
          duration: words[i].duration,
        ));
      } else {
        updatedWords.add(words[i]);
      }

      // Avancer dans l'index du texte pour suivre la position des mots
      textIndex =
          originalText.indexOf(words[i].word, textIndex) + words[i].word.length;
    }

    return updatedWords;
  }

  String findMissingCharacter(
    String originalText,
    List<SrtWordModel> words,
    int textIndex,
    int emptyWordIndex,
  ) {
    // On cherche la position du prochain mot dans le texte
    int nextWordIndex = emptyWordIndex + 1 < words.length
        ? originalText.indexOf(words[emptyWordIndex + 1].word, textIndex)
        : originalText.length;

    if (nextWordIndex != -1 && textIndex < nextWordIndex) {
      // Récupérer le texte entre textIndex et nextWordIndex
      String substring =
          originalText.substring(textIndex, nextWordIndex).trim();

      // Si la sous-chaîne est vide, retourner une chaîne vide
      if (substring.isEmpty) return "";

      // Filtrer uniquement les caractères non-alphanumériques dans la sous-chaîne
      String missingCharacter =
          substring.replaceAll(RegExp(r'[a-zA-Z0-9\s,]'), '');

      // Si un caractère est trouvé, le renvoyer, sinon retourner une chaîne vide
      return missingCharacter.isNotEmpty ? missingCharacter : "";
    }

    return ""; // Si on ne trouve rien, on renvoie une chaîne vide
  }
}
