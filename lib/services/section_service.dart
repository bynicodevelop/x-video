import 'package:dart_openai/dart_openai.dart';
import 'package:x_video_ai/gateway/open_ai_gateway.dart';
import 'package:x_video_ai/models/srt_word_model.dart';
import 'package:x_video_ai/models/video_section_model.dart';
import 'package:x_video_ai/utils/constants.dart';
import 'package:x_video_ai/utils/generate_md5_name.dart';

class SectionService {
  /// Permet de découper une liste de mots en sections de durée maximale
  /// TODO: optimiser la fonction avec un algorithme plus performant comme un pattern de temps
  /// Comme par exemple un tableau de durée en secondes [3, 5, 4, 3]
  Future<List<VideoSectionModel>> createSections(
    List<SrtWordModel> srtWithGroup, {
    double maxDuration = 10,
  }) async {
    if (srtWithGroup.isEmpty) {
      return [];
    }

    List<VideoSectionModel> sections = [];
    String currentSentence = '';
    double currentStart = srtWithGroup.first.start;
    double currentEnd = currentStart;
    double accumulatedDuration = 0.0; // Cumul des durées

    for (int i = 0; i < srtWithGroup.length; i++) {
      SrtWordModel wordModel = srtWithGroup[i];
      double wordStart = wordModel.start;
      double wordEnd = wordModel.end;
      String word = wordModel.word;

      // Vérifier si le mot actuel est discontinu par rapport au mot précédent
      if (i > 0 && wordStart - currentEnd > 0.001) {
        double discontinuityDuration = wordStart - currentEnd;
        // Tolérance de 1 milliseconde
        print(
            'Discontinuité détectée entre ${srtWithGroup[i - 1].word} et $word : ${wordStart - currentEnd} secondes');

        // Ajouter la durée de la discontinuité à la durée accumulée
        accumulatedDuration += discontinuityDuration;
      }

      // Durée du mot courant
      double wordDuration = wordEnd - wordStart;

      // Calculer la durée totale si on ajoute ce mot à la section en cours
      double newAccumulatedDuration = accumulatedDuration + wordDuration;

      // Si la nouvelle section dépasse la durée maximale, on crée une nouvelle section
      if (newAccumulatedDuration > maxDuration) {
        if (currentSentence.isNotEmpty) {
          // Ajouter la section actuelle avec la durée accumulée
          sections.add(VideoSectionModel(
            id: await generateMD5NameFromString(
              "$currentSentence$currentStart$currentEnd",
            ),
            sentence: currentSentence.trim(),
            start: currentStart,
            end: currentEnd,
            duration: accumulatedDuration, // Durée réelle accumulée
            keyword: '',
          ));
        }

        // Réinitialiser les variables pour la nouvelle section
        currentSentence =
            word; // Commencer une nouvelle phrase avec le mot actuel
        currentStart = wordStart; // Début de la nouvelle section
        accumulatedDuration =
            wordDuration; // Réinitialiser la durée accumulée pour la nouvelle section
      } else {
        // Ajouter le mot à la section en cours
        currentSentence += ' $word';
        accumulatedDuration = newAccumulatedDuration; // Ajouter la durée du mot
      }

      // Mettre à jour le temps de fin
      currentEnd = wordEnd;
    }

    // Ajouter la dernière section si nécessaire
    if (currentSentence.isNotEmpty) {
      sections.add(VideoSectionModel(
        id: await generateMD5NameFromString(
          "$currentSentence$currentStart$currentEnd",
        ),
        sentence: currentSentence.trim(),
        start: currentStart,
        end: currentEnd,
        duration: accumulatedDuration, // Utiliser la durée accumulée
        keyword: '',
      ));
    }

    return sections;
  }

  Future<List<VideoSectionModel>> generateKeywords(
    List<VideoSectionModel> sections,
    OpenAIGateway<String> openAIGateway,
    String model,
  ) async {
    final messages = <OpenAIChatCompletionChoiceMessageModel>[];
    final sectionsWithKeywords = <VideoSectionModel>[];

    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          kPromptGenerateKeywords,
        ),
      ],
      role: OpenAIChatMessageRole.system,
    );

    messages.add(systemMessage);

    for (VideoSectionModel section in sections) {
      final userMessage = OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            section.sentence,
          ),
        ],
        role: OpenAIChatMessageRole.user,
      );

      messages.add(userMessage);

      final String keyword = await openAIGateway.callOpenAI(
        messages: messages,
        model: model,
      );

      sectionsWithKeywords.add(section.copyWith(
        keyword: keyword,
      ));

      final systemeResponse = OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            keyword,
          ),
        ],
        role: OpenAIChatMessageRole.assistant,
      );

      messages.add(systemeResponse);
    }

    return sectionsWithKeywords;
  }
}
