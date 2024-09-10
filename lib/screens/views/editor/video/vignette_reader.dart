// ignore: depend_on_referenced_packages
import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/editor_section_controller.dart';
import 'package:x_video_ai/controllers/upload_controller.dart';
import 'package:x_video_ai/elements/dialogs/main_dialog_element.dart';
import 'package:x_video_ai/elements/images/box_image.dart';
import 'package:x_video_ai/models/editor_section_model.dart';
import 'package:x_video_ai/models/upload_state_model.dart';
import 'package:x_video_ai/models/video_model.dart';
import 'package:x_video_ai/models/video_section_model.dart';
import 'package:x_video_ai/screens/views/sort_keyword_screen.dart';

class VignetteReaderVideoEditor extends ConsumerStatefulWidget {
  final VideoSectionModel section;

  const VignetteReaderVideoEditor({
    required this.section,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _VignetteReaderVideoState();
}

class _VignetteReaderVideoState
    extends ConsumerState<VignetteReaderVideoEditor> {
  bool _dragging = false;
  EditorSectionModel? _editorSectionModel;

  @override
  void initState() {
    super.initState();

    if (widget.section.fileName != null) {
      Future.microtask(
        () async => setState(() async {
          _editorSectionModel =
              await ref.read(editorSectionControllerProvider.notifier).add(
                    widget.section,
                  );
        }),
      );
    }
  }

  IconData _getIconBasedOnState(FileUploadState? fileState) {
    if (fileState == null) {
      return Icons.file_upload_outlined;
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

  void _createKeywordModal(
    BuildContext context,
    VideoDataModel videoData,
    VideoSectionModel section,
  ) {
    showDialog(
      context: context,
      builder: (context) => MainDialogElement(
        width: MediaQuery.of(context).size.width,
        height: double.infinity,
        child: SortKeywordSreen(
          video: videoData,
          section: section,
          key: widget.key!,
          onCompleted: () {
            ref.read(uploadControllerProvider.notifier).completeUpload(
                  videoData,
                );

            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ref.watch(uploadControllerProvider);
    // final videoDadaController = ref.watch(videoDataControllerProvider);
    // ref.watch(boxImageControllerProvider.notifier).generateThumbnailFromVideoId(
    //       widget.section.file,
    //       widget.key!,
    //     );

    // ref.listen(videoDataControllerProvider, (previous, next) {
    //   if (previous == next) return;

    //   final VideoDataModel videoData = next.firstWhere(
    //     (element) => element.file == _file,
    //     orElse: () => VideoDataModel.getDefault(),
    //   );

    //   if (videoData.fileState != null) {
    //     if (videoData.fileState!.status == UploadStatus.uploading) {
    //       final categoryListController =
    //           ref.read(categoryListControllerProvider.notifier);

    //       categoryListController.keywordIsInCategory(
    //         widget.key!,
    //         widget.section,
    //       );

    //       if (categoryListController.isInCategories ==
    //               CategoryContainer.notInCategory &&
    //           videoData.name.isNotEmpty) {
    //         _createKeywordModal(
    //           context,
    //           videoData,
    //           widget.section,
    //         );
    //       }
    //     }

    //     if (videoData.fileState!.status == UploadStatus.uploaded) {
    //       print('Uploade complete');
    //     }
    //   }
    // });

    // final VideoDataModel videoData = videoDadaController.firstWhere(
    //   (element) => element.file == _file,
    //   orElse: () => VideoDataModel.getDefault(),
    // );

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

        XFile file = detail.files.first;

        // ref.read(uploadControllerProvider.notifier).upload(
        //       _file!,
        //       widget.key!,
        //     );
        // ref.read(boxImageControllerProvider.notifier).generateThumbnailFromFile(
        //       _file!,
        //       widget.key!,
        //     );
      },
      onDragEntered: (detail) {
        setState(() => _dragging = true);
      },
      onDragExited: (detail) {
        setState(() => _dragging = false);
      },
      child: BoxImage(
        section: _editorSectionModel,
        dragging: _dragging,
        builder: (
          BuildContext context,
          BoxImageParams params,
        ) {
          return Center(
            child: IconButton(
              icon: Icon(
                _getIconBasedOnState(null),
                color: params.dragging
                    ? Colors.blue.shade400
                    : params.thumbnail != null
                        ? Colors.white
                        : Colors.grey.shade400,
              ),
              onPressed: () {},
            ),
          );
        },
      ),
    );
  }
}
