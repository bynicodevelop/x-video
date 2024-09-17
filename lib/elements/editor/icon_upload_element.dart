import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/screens/views/editor/video/vignette_reader_controller.dart';

class IconUploadEditorElement extends ConsumerStatefulWidget {
  final VignetteReaderStatus? status;
  final bool isDragging;
  final bool hasThumbnail;
  final void Function()? onCompleted;

  const IconUploadEditorElement({
    this.status,
    this.isDragging = false,
    this.hasThumbnail = false,
    this.onCompleted,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _IconUploadEditorElementState();
}

class _IconUploadEditorElementState
    extends ConsumerState<IconUploadEditorElement> {
  IconData _getIconBasedOnState(VignetteReaderStatus? status) {
    if (status == null) {
      return Icons.hourglass_top_outlined;
    }

    if (status == VignetteReaderStatus.error) {
      return Icons.error_outline;
    }

    if (status == VignetteReaderStatus.uploading) {
      return Icons.upload_file;
    }

    return Icons.file_upload_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _getIconBasedOnState(widget.status),
        color: widget.isDragging
            ? Colors.blue.shade400
            : widget.hasThumbnail
                ? Colors.white
                : Colors.grey.shade400,
      ),
      onPressed: widget.onCompleted,
    );
  }
}
