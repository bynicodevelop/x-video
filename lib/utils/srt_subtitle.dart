import 'package:x_video_ai/models/srt_sentence_model.dart';
import 'package:x_video_ai/models/srt_word_model.dart';

class SrtSubtitle {
  final Map<String, Function> karaokeStyle = {
    'STYLE_NONE': ({int duration = 100, String highlightColor = '&H00FF00&'}) =>
        '{\\c$highlightColor}',
    'STYLE_1': ({int duration = 100, String highlightColor = '&H00FF00&'}) =>
        '{\\k$duration}{\\c$highlightColor}',
  };

  List<List<SrtWordModel>> createSubtitles(
    List<SrtSentenceModel> srtWithGroup, {
    int wordPerLine = 3, // Par défaut, 3 mots par ligne
  }) {
    List<List<SrtWordModel>> subtitles = [];

    // Pour chaque phrase dans la liste
    for (final sentence in srtWithGroup) {
      // Diviser le groupe de mots en sous-parties selon wordPerLine
      for (int i = 0; i < sentence.group!.length; i += wordPerLine) {
        // Créer une sous-liste des mots en fonction du nombre de mots par ligne
        List<SrtWordModel> subtitlePart = sentence.group!.sublist(
          i,
          i + wordPerLine > sentence.group!.length
              ? sentence.group!.length
              : i + wordPerLine,
        );

        // Ajouter la sous-liste dans le résultat final
        subtitles.add(subtitlePart);
      }
    }

    return subtitles;
  }

  String generateAssFile(
    List<List<SrtWordModel>> subtitles, {
    String? karaokeEffect, // Si null, pas d'effet karaoké
    String highlightColor = '&H00FF00&', // Couleur par défaut
  }) {
    // Créer les métadonnées de base
    String assFileContent = _createAssHeader();

    // Ajouter les sous-titres
    assFileContent += "[Events]\n";
    assFileContent +=
        "Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text\n";

    // Pour chaque ligne de sous-titres
    for (final subtitleLine in subtitles) {
      String start = _formatTime(subtitleLine.first.start);
      String end = _formatTime(subtitleLine.last.end);
      StringBuffer lineContent = StringBuffer();

      // Ajouter les mots avec ou sans l'effet karaoké
      for (var word in subtitleLine) {
        final wordDuration = ((word.end - word.start) * 100).round();
        final karaokeTag = karaokeEffect != null
            ? karaokeStyle[karaokeEffect]!(
                duration: wordDuration,
                highlightColor: highlightColor,
              )
            : ''; // Pas d'effet si karaoké n'est pas activé

        lineContent.write('$karaokeTag${word.word} ');
      }

      // Ajouter chaque ligne formatée au fichier .ass
      assFileContent +=
          _createDialogue(start, end, lineContent.toString().trim());
    }

    return assFileContent;
  }

  String _createAssHeader() {
    return '''[Script Info]
Title: Generated Subtitles
ScriptType: v4.00+
Collisions: Normal
PlayDepth: 0

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: Default,Arial,20,&H00FFFFFF,&H000000FF,&H00000000,&H64000000,-1,0,0,0,100,100,0.00,0,1,1.00,0.00,2,10,10,10,1

''';
  }

  String _createDialogue(String start, String end, String text) {
    return 'Dialogue: 0,$start,$end,Default,,0,0,0,,$text\n';
  }

  // Formater le temps (de secondes) au format .ass
  String _formatTime(double seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    double secs = seconds % 60;

    // Formater les parties du temps avec zéro devant si nécessaire
    return '${hours.toString().padLeft(1, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toStringAsFixed(2).padLeft(5, '0')}';
  }
}
