// ignore: depend_on_referenced_packages
import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/upload_controller.dart';
import 'package:x_video_ai/models/upload_state_model.dart';

class VignetteReaderVideoEditor extends ConsumerStatefulWidget {
  const VignetteReaderVideoEditor({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _VignetteReaderVideoState();
}

class _VignetteReaderVideoState
    extends ConsumerState<VignetteReaderVideoEditor> {
  XFile? _file;
  bool _dragging = false;

  IconData _getIconBasedOnState(FileUploadState? fileState) {
    if (fileState == null) {
      return Icons.file_upload_outlined; // Aucun fichier n'est sélectionné
    }

    switch (fileState.status) {
      case UploadStatus.uploading:
        return Icons
            .hourglass_top; // Indiquer que le fichier est en cours d'upload
      case UploadStatus.uploaded:
        return Icons.check_circle; // Indiquer que l'upload a réussi
      case UploadStatus.uploadFailed:
        return Icons.error; // Indiquer une erreur
      case UploadStatus.idle:
      default:
        return Icons.file_upload_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadControllerProvider);

    final fileState = _file != null
        ? uploadState.files.firstWhere(
            (element) => element.file == _file,
            orElse: () => FileUploadState(
              file: _file!,
              status: UploadStatus.idle,
            ),
          )
        : null;

    return DropTarget(
      onDragDone: (detail) {
        if (detail.files.length > 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              // TODO: Add a translation
              content: Text('Only one file can be uploaded at a time'),
            ),
          );

          return;
        }

        _file = detail.files.first;
        ref.read(uploadControllerProvider.notifier).upload(_file!);
      },
      onDragEntered: (detail) {
        setState(() => _dragging = true);
      },
      onDragExited: (detail) {
        setState(() => _dragging = false);
      },
      child: Container(
        width: 250,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: _dragging ? Colors.blue.shade100 : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: IconButton(
            icon: Icon(
              _getIconBasedOnState(fileState),
              color: _dragging ? Colors.blue.shade400 : Colors.grey.shade400,
            ),
            onPressed: () {},
          ),
        ),
      ),
    );
  }
}
