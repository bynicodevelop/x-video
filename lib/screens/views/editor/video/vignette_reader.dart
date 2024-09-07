import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/thumbnail_controller.dart';
import 'package:x_video_ai/controllers/upload_controller.dart';
import 'package:x_video_ai/models/upload_state_model.dart';
import 'package:x_video_ai/models/video_section_model.dart';

class VignetteReaderVideoEditor extends ConsumerStatefulWidget {
  final VideoSectionModel section;

  const VignetteReaderVideoEditor({
    required this.section,
    super.key,
  });
  // }) : super(key: section.file != null ? Key(section.file!) : UniqueKey());

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _VignetteReaderVideoState();
}

class _VignetteReaderVideoState
    extends ConsumerState<VignetteReaderVideoEditor> {
  XFile? _file;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();

    if (widget.section.file != null) {
      Future.microtask(() {
        ref
            .read(thumbnailControllerProvider.notifier)
            .setThumbnail(widget.section);
      });
    }
  }

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
    final thumbnail = ref.watch(thumbnailControllerProvider
        .select((thumbnails) => thumbnails[widget.section.file]));

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
        ref.read(uploadControllerProvider.notifier).upload(
              _file!,
              widget.section,
            );
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
          color: _dragging
              ? Colors.blue.shade100
              : widget.section.file != null
                  ? Colors.grey.shade100
                  : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
          image: widget.section.file != null && thumbnail != null
              ? DecorationImage(
                  image: MemoryImage(thumbnail),
                  fit: BoxFit.cover,
                  opacity: 0.7,
                )
              : null,
        ),
        child: Center(
          child: IconButton(
            icon: Icon(
              _getIconBasedOnState(fileState),
              color: _dragging
                  ? Colors.blue.shade400
                  : widget.section.file != null
                      ? Colors.white
                      : Colors.grey.shade400,
            ),
            onPressed: () {},
          ),
        ),
      ),
    );
  }
}
