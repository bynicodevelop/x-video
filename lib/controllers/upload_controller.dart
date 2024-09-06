// ignore: depend_on_referenced_packages
import 'package:cross_file/cross_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/content_controller.dart';
import 'package:x_video_ai/models/upload_state_model.dart';
import 'package:x_video_ai/services/video_service.dart';

class UploadControllerProvider extends StateNotifier<UploadStateState> {
  final VideoService _videoService;
  final ContentController _contentController;

  UploadControllerProvider(
    VideoService videoService,
    ContentController contentController,
  )   : _videoService = videoService,
        _contentController = contentController,
        super(UploadStateState(files: []));

  Future<void> upload(XFile file) async {
    // Ajouter le fichier à la liste avec l'état "uploading"
    final newFileState = FileUploadState(
      file: file,
      status: UploadStatus.uploading,
    );

    state = state.copyWith(
      files: [...state.files, newFileState],
    );

    try {
      await _videoService.uploadToTmpFolder(
        file,
        _contentController.state.path,
      );

      // Mettre à jour l'état du fichier à "uploaded"
      _updateFileStatus(file, UploadStatus.uploaded);
    } catch (e) {
      // En cas d'erreur, mettre à jour l'état du fichier à "uploadFailed"
      _updateFileStatus(file, UploadStatus.uploadFailed, e.toString());
    }
  }

  void _updateFileStatus(XFile file, UploadStatus status, [String? message]) {
    final updatedFiles = state.files.map((fileState) {
      if (fileState.file == file) {
        return fileState.copyWith(status: status, message: message);
      }

      return fileState;
    }).toList();

    state = state.copyWith(files: updatedFiles);
  }
}

final uploadControllerProvider =
    StateNotifierProvider<UploadControllerProvider, UploadStateState>(
  (ref) => UploadControllerProvider(
    VideoService(),
    ref.read(contentControllerProvider.notifier),
  ),
);
