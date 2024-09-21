import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:popover/popover.dart';
import 'package:x_video_ai/elements/dialogs/main_dialog_element.dart';
import 'package:x_video_ai/screens/views/editor/media_video.dart';
import 'package:x_video_ai/screens/views/editor/video/vignette_reader_controller.dart';

class IconUploadEditorElement extends ConsumerStatefulWidget {
  final VignetteReaderStatus? status;
  final bool isDragging;
  final bool hasThumbnail;
  final void Function(String? videoId)? onCompleted;

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

  Widget _item(
    IconData icon,
    String title,
    void Function() onTap,
  ) {
    return ListTile(
      dense: true,
      title: Text(title),
      leading: Icon(
        icon,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  void _openMediaLibrary(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (context) => MainDialogElement(
        width: MediaQuery.of(context).size.width,
        height: double.infinity,
        onClose: () {},
        child: MediaVideo(
          onVideoSelected: (videoId) {
            Navigator.of(context).pop();
            widget.onCompleted?.call(videoId);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Icon(
        _getIconBasedOnState(widget.status),
        color: widget.isDragging
            ? Colors.blue.shade400
            : widget.hasThumbnail
                ? Colors.white
                : Colors.grey.shade400,
      ),
      onTap: () {
        showPopover(
          context: context,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          barrierColor: Colors.transparent,
          bodyBuilder: (context) => Container(
            child: Column(
              children: [
                _item(
                  Icons.upload_file,
                  // TODO: Add translation
                  'Upload',
                  () {
                    Navigator.of(context).pop();
                    widget.onCompleted?.call(null);
                  },
                ),
                _item(
                  Icons.video_library_outlined,
                  // TODO: Add translation
                  'Media Library',
                  () {
                    Navigator.of(context).pop();
                    _openMediaLibrary(context);
                  },
                ),
              ],
            ),
          ),
          direction: PopoverDirection.top,
          width: 180,
          height: 80,
          arrowHeight: 15,
          arrowWidth: 15,
        );
      },
    );
  }
}
