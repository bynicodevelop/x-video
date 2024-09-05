import 'package:x_video_ai/models/srt_word_model.dart';
import 'package:x_video_ai/models/video_section_model.dart';

class SectionService {
  /// Permet de découper une liste de mots en sections de durée maximale
  /// TODO: optimiser la fonction avec un algorithme plus performant comme un pattern de temps
  /// Comme par exemple un tableau de durée en secondes [3, 5, 4, 3]
  List<VideoSectionModel> createSections(
    List<SrtWordModel> srtWithGroup, {
    double maxDuration = 10,
  }) {
    if (srtWithGroup.isEmpty) {
      return [];
    }

    List<VideoSectionModel> sections = [];
    String currentSentence = '';
    double currentStart = srtWithGroup.first.start;
    double accumulatedDuration = 0.0;
    double currentEnd = 0.0;

    for (var wordModel in srtWithGroup) {
      double wordStart = wordModel.start;
      double wordEnd = wordModel.end;
      String word = wordModel.word;

      double wordDuration = wordEnd - wordStart;

      // Si ajouter ce mot dépasse la durée maximale, créer une nouvelle section
      if (accumulatedDuration + wordDuration > maxDuration) {
        // Ajouter la section actuelle uniquement si la phrase n'est pas vide
        if (currentSentence.isNotEmpty) {
          sections.add(VideoSectionModel(
            sentence: currentSentence.trim(),
            start: currentStart,
            end: currentEnd,
            duration: accumulatedDuration,
            keyword:
                '', // On peut éventuellement ajouter des keywords ici plus tard
          ));
        }

        // Réinitialiser les variables pour la nouvelle section
        currentStart = wordStart;
        currentSentence = word;
        accumulatedDuration = wordDuration;
      } else {
        // Ajouter le mot à la phrase en cours
        currentSentence += ' $word';
        accumulatedDuration += wordDuration;
      }

      // Mettre à jour la fin actuelle de la section
      currentEnd = wordEnd;
    }

    // Ajouter la dernière section restante si elle n'a pas encore été ajoutée
    if (currentSentence.isNotEmpty) {
      sections.add(VideoSectionModel(
        sentence: currentSentence.trim(),
        start: currentStart,
        end: currentEnd,
        duration: accumulatedDuration,
        keyword:
            '', // On peut éventuellement ajouter des keywords ici plus tard
      ));
    }

    return sections;
  }
}
