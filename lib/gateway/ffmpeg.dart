import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:x_video_ai/utils/constants.dart';

class FFMpeg {
  /// Traite une vidéo en ajustant ses dimensions, son codec vidéo et ses options audio.
  ///
  /// Cette fonction utilise `ffmpeg` pour traiter une vidéo avec les options suivantes :
  ///
  /// - Redimensionner la vidéo à une résolution spécifiée tout en conservant le ratio d'aspect.
  /// - Recadrer la vidéo pour s'adapter à la résolution souhaitée.
  /// - Utiliser le codec vidéo `libx264` pour encoder la vidéo.
  /// - Utiliser le format pixel `yuv420p` pour une meilleure compatibilité.
  /// - Optimiser la vidéo pour un démarrage rapide sur le web avec `faststart`.
  /// - Inclure ou exclure l'audio en fonction du paramètre [sound].
  ///
  /// ### Paramètres
  ///
  /// - [inputPath] : Le chemin du fichier vidéo d'entrée à traiter.
  /// - [outputPath] : Le chemin du fichier de sortie où la vidéo traitée sera sauvegardée.
  /// - [format] : La résolution souhaitée sous la forme "largeur:hauteur" (par exemple, "1920:1080").
  /// - [sound] : Si `true`, l'audio original est conservé ; sinon, l'audio est supprimé.
  ///
  /// ### Exemple d'utilisation
  ///
  /// ```dart
  /// await processVideo(
  ///   inputPath: 'video_originale.mp4',
  ///   outputPath: 'video_finale.mp4',
  ///   format: '1920:1080',
  ///   sound: true,
  /// );
  /// ```
  ///
  /// ### Exceptions
  /// - Lance une exception si le processus `ffmpeg` échoue ou si une erreur survient lors du traitement.
  Future<void> processVideo({
    required String inputPath,
    required String outputPath,
    required String format,
    bool sound = false,
  }) async {
    // Créer les options vidéo
    final videoOptions =
        'scale=$format:force_original_aspect_ratio=increase,crop=$format';

    // Créer la commande ffmpeg
    final List<String> command = [
      '-i', inputPath,
      '-vf', videoOptions,
      '-c:v', 'libx264', // Utilisation du codec vidéo libx264
      '-pix_fmt', 'yuv420p', // Format pixel yuv420p
      '-movflags', 'faststart', // Optimisation pour un démarrage rapide
    ];

    // Gérer l'audio en fonction de l'option "sound"
    if (sound) {
      command.addAll(['-c:a', 'copy']); // Copier l'audio
    } else {
      command.add('-an'); // Supprimer l'audio
    }

    // Ajouter la sortie finale
    command.add(outputPath);

    // Exécuter la commande ffmpeg
    final result = await Process.run('ffmpeg', command);

    // Gérer les erreurs de processus
    if (result.exitCode != 0) {
      print('Error: ${result.stderr}');
      throw Exception('FFmpeg process failed');
    }

    print('Video processed successfully: ${result.stdout}');
  }

  /// Génère une miniature d'une vidéo en utilisant FFmpeg.
  ///
  /// Cette fonction utilise FFmpeg pour extraire une image de la vidéo spécifiée et la stocker
  /// sous forme de fichier temporaire. L'image est ensuite lue sous forme de byte array (Uint8List)
  /// et retournée. Après avoir lu l'image, le fichier temporaire est supprimé.
  ///
  /// ### Paramètres
  ///
  /// - [outputPath] : Le chemin où la miniature sera stockée temporairement.
  /// - [inputFile] : Le chemin du fichier vidéo à partir duquel la miniature sera générée.
  /// - [filename] : Le nom du fichier pour la miniature (optionnel, par défaut 'thumbnail').
  ///
  /// ### Retour
  ///
  /// Cette fonction retourne un `Uint8List?` représentant l'image miniature si la génération
  /// réussit, ou `null` en cas d'erreur.
  ///
  /// ### Exemple d'utilisation
  ///
  /// ```dart
  /// final Uint8List? thumbnail = await generateThumbnail(
  ///   outputPath: '/path/to/output',
  ///   inputFile: '/path/to/video.mp4',
  /// );
  /// if (thumbnail != null) {
  ///   // Utilisez la miniature
  /// }
  /// ```
  ///
  /// ### Exceptions
  /// - Si FFmpeg ne parvient pas à générer la miniature, un message d'erreur est affiché dans la console,
  ///   et `null` est retourné.
  Future<Uint8List?> generateThumbnail({
    required String outputPath,
    required String inputFile,
    String filename = 'thumbnail',
  }) async {
    const String prefix = 'thumbnail_';

    try {
      // Chemin complet pour stocker la miniature
      final thumbnailPath = '$outputPath/$prefix$filename.$kImageExtension';

      // Exécuter FFmpeg pour générer la miniature
      final result = await Process.run(
        'ffmpeg',
        ['-i', inputFile, '-ss', '00:00:01', '-vframes', '1', thumbnailPath],
      );

      // Vérifier si la commande FFmpeg s'est exécutée correctement
      if (result.exitCode == 0) {
        // Lire l'image générée sous forme de byte array
        final bytes = await File(thumbnailPath).readAsBytes();

        // Vous pouvez supprimer la miniature temporaire après l'avoir lue si vous le souhaitez
        await File(thumbnailPath).delete();

        return bytes;
      } else {
        print('Erreur lors de la génération de la miniature: ${result.stderr}');
        return null;
      }
    } catch (e) {
      print('Erreur: $e');
      return null;
    }
  }

  /// Récupère les informations d'une vidéo à partir de son chemin d'entrée en utilisant la commande `ffprobe`.
  ///
  /// Cette fonction exécute un processus système pour exécuter `ffprobe`, un outil de la suite FFmpeg,
  /// afin de récupérer les informations sur le flux vidéo, y compris la largeur, la hauteur et la durée.
  /// Les informations sont extraites en JSON et renvoyées sous la forme d'une carte (`Map`).
  ///
  /// ### Paramètres:
  ///
  /// - `inputPath` (`String`): Le chemin du fichier vidéo à analyser.
  ///
  /// ### Retour:
  ///
  /// - `Future<Map<String, dynamic>>`: Une carte contenant les informations suivantes sur la vidéo :
  ///   - `width` (`double`): La largeur de la vidéo.
  ///   - `height` (`double`): La hauteur de la vidéo.
  ///   - `duration` (`double`): La durée de la vidéo en secondes.
  ///
  /// Si la commande `ffprobe` échoue, la fonction renvoie une carte vide (`{}`).
  ///
  /// ### Exemple:
  ///
  /// ```dart
  /// final videoInfo = await getVideoInformation('/chemin/vers/video.mp4');
  /// print('Largeur: ${videoInfo['width']}');
  /// print('Hauteur: ${videoInfo['height']}');
  /// print('Durée: ${videoInfo['duration']}');
  /// ```
  ///
  /// ### Erreurs possibles:
  ///
  /// Si la commande `ffprobe` retourne un code de sortie différent de 0, une erreur est affichée dans la console,
  /// et une carte vide est renvoyée.
  ///
  /// ### Remarques:
  /// - Assurez-vous que `ffprobe` est installé et accessible dans le chemin système de la machine exécutant cette fonction.
  /// - Les informations sont récupérées uniquement à partir du premier flux vidéo (`v:0`).
  ///
  /// ### Dépendances:
  /// - La commande `ffprobe` de FFmpeg.
  /// - `dart:convert` pour la conversion du JSON.
  Future<Map<String, dynamic>> getVideoInformation(
    String inputPath,
  ) async {
    final result = await Process.run('ffprobe', [
      '-v',
      'error',
      '-select_streams',
      'v:0',
      '-show_entries',
      'stream=width,height,duration',
      '-of',
      'json',
      inputPath,
    ]);

    if (result.exitCode == 0) {
      final data = result.stdout as String;
      final json = jsonDecode(data);

      final videoData = json['streams'][0];

      return {
        'width': double.parse(videoData['width'].toString()),
        'height': double.parse(videoData['height'].toString()),
        'duration': double.parse(videoData['duration'].toString()),
      };
    } else {
      print(
          'Erreur lors de la récupération des informations de la vidéo: ${result.stderr}');
      return {};
    }
  }
}
