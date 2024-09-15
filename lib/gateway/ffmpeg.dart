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
    final String uniqueId = '${DateTime.now().millisecondsSinceEpoch}_';

    try {
      // Chemin complet pour stocker la miniature
      final thumbnailPath =
          '$outputPath/$prefix$uniqueId$filename.$kImageExtension';

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

  Future<void> cutSegment(
    String inputPath,
    String outputPath,
    double duration,
    String format,
    void Function(double progress) onProgress,
  ) async {
    // Créer les options vidéo
    final List<String> defaultOptions = [
      '-t', '$duration', // Durée de la vidéo
      '-pix_fmt', 'yuv420p', // Format pixel yuv420p
      '-vsync', 'vfr', // Synchronisation vidéo variable
      '-movflags', 'faststart', // Optimisation pour un démarrage rapide
    ];

    // Créer les filtres vidéo
    final String videoFilter =
        'scale=$format:force_original_aspect_ratio=increase,crop=$format';

    // Créer la commande ffmpeg
    final List<String> command = [
      '-i', inputPath, // Chemin d'entrée
      ...defaultOptions, // Options par défaut
      '-c:v', 'libx264', // Codec vidéo libx264
      '-c:a', 'aac', // Codec audio AAC
      '-vf', videoFilter, // Appliquer les filtres vidéo
      '-y', // Écraser le fichier de sortie s'il existe déjà
      outputPath, // Chemin de sortie
    ];

    try {
      // Exécuter la commande ffmpeg avec Process.start pour suivre la progression
      final process = await Process.start('ffmpeg', command);

      double lastProgress = 0.0;

      // Écouter le flux stderr pour extraire la progression
      process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        // Décommenter pour voir toutes les sorties ffmpeg
        // print(line);

        final progress = _parseProgress(line, duration);
        if (progress != null) {
          if (progress >= lastProgress) {
            lastProgress = progress;
            onProgress(progress);
          }
        }
      });

      // Attendre la fin du processus
      final exitCode = await process.exitCode;

      // Gérer l'exécution du processus
      if (exitCode != 0) {
        // Lire le message d'erreur complet
        final error = await process.stderr.transform(utf8.decoder).join();
        print('Error: $error');
        throw Exception('FFmpeg process failed');
      } else {
        onProgress(100.0);
      }
    } catch (e) {
      print('Error creating segment: $outputPath - ${e.toString()}');
      throw Exception('Failed to create segment');
    }
  }

  Future<void> concat(
    List<String> tempFiles,
    String tempDir,
    String outputVideoPath,
    void Function(double progress) onProgress,
  ) async {
    try {
      print('Concatenating ${tempFiles.length} videos');

      // Construire la commande FFmpeg
      final List<String> command = [];

      for (var tempFile in tempFiles) {
        command.addAll(['-i', tempFile]);
      }

      final inputStreams =
          List.generate(tempFiles.length, (i) => '[$i:v]').join();
      final filterComplex =
          '$inputStreams concat=n=${tempFiles.length}:v=1[outv]';

      command.addAll([
        '-filter_complex',
        filterComplex,
        '-map',
        '[outv]',
        '-c:v',
        'libx264',
        '-movflags',
        'faststart',
        '-y',
        outputVideoPath,
      ]);

      print('Executing command: ffmpeg ${command.join(' ')}');

      // Démarrer le processus FFmpeg
      final process =
          await Process.start('ffmpeg', command, workingDirectory: tempDir);

      // Calculer la durée totale des vidéos
      final totalDuration = await _getTotalDuration(tempFiles);

      // Écouter le flux stderr pour extraire la progression
      process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        final progress = _parseProgress(line, totalDuration);
        if (progress != null) {
          onProgress(progress);
        }
      });

      // Attendre la fin du processus
      final exitCode = await process.exitCode;

      if (exitCode != 0) {
        print('Error: Process exited with code $exitCode');
        throw Exception('FFmpeg process failed');
      }

      onProgress(100.0);
    } catch (e) {
      print('Error concatenating videos: $e');
      print(
          'Details: tempFiles=$tempFiles, tempDir=$tempDir, outputVideoPath=$outputVideoPath');
      throw Exception('Failed to concatenate videos');
    }
  }

  Future<void> addAudioToVideo(
    String videoPath,
    String audioPath,
    String outputVideoPath,
    void Function(double progress) onProgress,
  ) async {
    print('Adding audio to video');

    // Construire la commande FFmpeg
    final List<String> command = [
      '-i',
      videoPath,
      '-i',
      audioPath,
      '-map',
      '0:v',
      '-map',
      '1:a',
      '-c:v',
      'copy',
      '-c:a',
      'aac',
      '-pix_fmt',
      'yuv420p',
      '-movflags',
      'faststart',
      '-shortest',
      '-y',
      outputVideoPath,
    ];

    try {
      // Obtenir la durée totale pour calculer la progression
      final totalDuration = await _getTotalDuration(
        [videoPath, audioPath],
        mode: 'shortest',
      );

      // Démarrer le processus FFmpeg
      final process = await Process.start('ffmpeg', command);

      // Écouter le flux stderr pour extraire la progression
      process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        // Décommenter la ligne suivante pour voir toutes les sorties FFmpeg
        // print(line);
        final progress = _parseProgress(line, totalDuration);
        if (progress != null) {
          onProgress(progress);
        }
      });

      // Attendre la fin du processus
      final exitCode = await process.exitCode;

      if (exitCode != 0) {
        print('Error: Process exited with code $exitCode');
        throw Exception('FFmpeg process failed');
      } else {
        onProgress(100.0);
        print('Video with audio created: $outputVideoPath');
      }
    } catch (e) {
      print('Error adding audio to video: $e');
      throw Exception('Failed to add audio to video');
    }
  }

  Future<void> addSubtitlesToVideo(
    String videoPath,
    String subtitlesContent,
    String outputVideoPath,
    void Function(double progress) onProgress,
  ) async {
    print('Adding subtitles to video');

    // Créer un fichier temporaire pour les sous-titres
    final tempSubtitlesFile =
        await File('${Directory.systemTemp.path}/temp_subtitles.ass').create();

    // Obtenir la durée totale de la vidéo avec ffprobe
    final duration = await _getVideoDuration(videoPath);

    try {
      // Écrire le contenu des sous-titres dans le fichier temporaire
      await tempSubtitlesFile.writeAsString(subtitlesContent);

      // Construire la commande FFmpeg avec le fichier temporaire
      final List<String> command = [
        '-i', videoPath,
        '-vf',
        'subtitles=${tempSubtitlesFile.path}', // Utilisation du fichier temporaire
        '-c:v', 'libx264',
        '-pix_fmt', 'yuv420p',
        '-movflags', 'faststart',
        '-y', outputVideoPath,
      ];

      print('Executing FFmpeg command: ffmpeg ${command.join(' ')}');

      // Démarrer le processus FFmpeg
      final process = await Process.start('ffmpeg', command);

      // Capturer les erreurs et les messages
      process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        // Extraction de la progression à partir de la sortie de FFmpeg
        final progress = _parseProgress(line, duration);
        if (progress != null) {
          onProgress(progress);
        }
      });

      // Attendre la fin du processus FFmpeg
      final exitCode = await process.exitCode;

      if (exitCode != 0) {
        throw Exception('FFmpeg process failed with exit code $exitCode');
      } else {
        onProgress(100.0);
        print('Video with subtitles created: $outputVideoPath');
      }
    } catch (e) {
      print('Error adding subtitles to video: $e');
      throw Exception('Failed to add subtitles to video');
    } finally {
      // Supprimer le fichier temporaire après utilisation
      if (await tempSubtitlesFile.exists()) {
        await tempSubtitlesFile.delete();
      }
    }
  }

  Future<double> _getTotalDuration(
    List<String> mediaPaths, {
    String mode = 'total', // 'total', 'shortest', 'longest'
  }) async {
    List<double> durations = [];

    for (var path in mediaPaths) {
      final result = await Process.run('ffprobe', [
        '-v',
        'error',
        '-show_entries',
        'format=duration',
        '-of',
        'default=noprint_wrappers=1:nokey=1',
        path,
      ]);

      if (result.exitCode == 0) {
        final duration = double.tryParse(result.stdout.toString().trim());
        if (duration != null) {
          durations.add(duration);
        }
      } else {
        print('Error getting duration of $path: ${result.stderr}');
        throw Exception('Error getting duration of $path');
      }
    }

    if (durations.isEmpty) {
      throw Exception('Unable to retrieve durations.');
    }

    switch (mode) {
      case 'shortest':
        return durations.reduce((a, b) => a < b ? a : b);
      case 'longest':
        return durations.reduce((a, b) => a > b ? a : b);
      default:
        return durations.reduce((a, b) => a + b);
    }
  }

  Future<double> _getVideoDuration(String videoPath) async {
    final result = await Process.run('ffprobe', [
      '-v',
      'error',
      '-show_entries',
      'format=duration',
      '-of',
      'default=noprint_wrappers=1:nokey=1',
      videoPath,
    ]);

    if (result.exitCode == 0) {
      return double.parse(result.stdout.toString().trim());
    } else {
      throw Exception('Failed to get video duration: ${result.stderr}');
    }
  }

// Fonction pour analyser la progression à partir des sorties de FFmpeg
  double? _parseProgress(String line, double totalDuration) {
    final regex = RegExp(r'time=(\d+:\d+:\d+\.\d+)');
    final match = regex.firstMatch(line);

    if (match != null) {
      final timeString = match.group(1)!;
      final elapsedSeconds = _timeStringToSeconds(timeString);

      final progress = (elapsedSeconds / totalDuration) * 100;
      return progress.clamp(0.0, 100.0);
    }

    return null;
  }

// Convertir une chaîne de temps HH:MM:SS.sss en secondes
  double _timeStringToSeconds(String timeString) {
    final parts = timeString.split(':');

    if (parts.length != 3) {
      return 0.0;
    }

    final hours = double.tryParse(parts[0]) ?? 0.0;
    final minutes = double.tryParse(parts[1]) ?? 0.0;
    final seconds = double.tryParse(parts[2]) ?? 0.0;

    return hours * 3600 + minutes * 60 + seconds;
  }
}
