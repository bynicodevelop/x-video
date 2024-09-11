import 'dart:typed_data';
import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:cross_file/cross_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/content_controller.dart';
import 'package:x_video_ai/gateway/ffmpeg.dart';
import 'package:x_video_ai/gateway/file_getaway.dart';
import 'package:x_video_ai/models/video_section_model.dart';
import 'package:x_video_ai/services/video_service.dart';
import 'package:x_video_ai/utils/constants.dart';

class ThumbnailController extends StateNotifier<Map<String, Uint8List?>> {
  final VideoService _videoService;
  final ContentController _contentController;

  ThumbnailController(
    VideoService videoService,
    ContentController contentController,
  )   : _videoService = videoService,
        _contentController = contentController,
        super({});

  // Fonction pour générer et stocker la miniature pour chaque section
  Future<void> setThumbnail(VideoSectionModel section) async {
    final String projectPath = _contentController.state.path;
    final String filePath =
        '$projectPath/videos/${section.fileName}.$kVideoExtension';

    // Vérification de l'existence du fichier vidéo
    if (!await File(filePath).exists()) {
      print("Le fichier vidéo n'existe pas : $filePath");
      return;
    }

    final XFile file = XFile(filePath);

    try {
      // Générer la miniature
      final Uint8List? thumbnail = await _videoService.generateThumbnail(
        file: file,
        outputPath: projectPath,
      );

      // Mettre à jour l'état avec la miniature associée à la section
      state = {
        ...state,
        section.fileName!:
            thumbnail, // Utiliser le nom de fichier comme clé unique
      };
    } catch (e) {
      print('Erreur lors de la génération de la miniature: $e');
      state = {
        ...state,
        section.fileName!: null,
      };
    }
  }

  // Accéder à une miniature spécifique par section
  Uint8List? getThumbnail(String file) {
    return state[file];
  }
}

final thumbnailControllerProvider =
    StateNotifierProvider<ThumbnailController, Map<String, Uint8List?>>(
  (ref) => ThumbnailController(
    VideoService(
      FileGateway(),
      FFMpeg(),
    ),
    ref.watch(contentControllerProvider.notifier),
  ),
);
