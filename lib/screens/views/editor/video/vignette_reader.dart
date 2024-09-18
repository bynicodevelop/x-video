import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/category_controller.dart';
import 'package:x_video_ai/controllers/category_list_controller.dart';
import 'package:x_video_ai/controllers/video_data_controller.dart';
import 'package:x_video_ai/elements/dialogs/main_dialog_element.dart';
import 'package:x_video_ai/elements/editor/icon_upload_element.dart';
import 'package:x_video_ai/elements/files/dropzone_element.dart';
import 'package:x_video_ai/elements/images/box_image.dart';
import 'package:x_video_ai/elements/images/box_image_controller.dart';
import 'package:x_video_ai/models/category_model.dart';
import 'package:x_video_ai/models/video_section_model.dart';
import 'package:x_video_ai/screens/views/editor/video/vignette_reader_controller.dart';
import 'package:x_video_ai/screens/views/sort_keyword_screen.dart';

class VignetteReaderVideoEditor extends ConsumerStatefulWidget {
  final Function(VignetteReaderState?) onCompleted;
  final VideoSectionModel section;

  const VignetteReaderVideoEditor({
    required this.section,
    required this.onCompleted,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _VignetteReaderVideoState();
}

class _VignetteReaderVideoState
    extends ConsumerState<VignetteReaderVideoEditor> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_initiateVignetteReaderController);
  }

  @override
  void didUpdateWidget(covariant VignetteReaderVideoEditor oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.section != widget.section) {
      Future.microtask(_initiateVignetteReaderController);
    }
  }

  Future<void> _initiateVignetteReaderController() async {
    await ref.read(categoryListControllerProvider.notifier).loadCategories();
    await ref.read(vignetteReaderControllerProvider.notifier).initState(
          widget.section,
        );
  }

  void _createKeywordModal(
    BuildContext context,
    VignetteReaderState vignetteReaderState,
  ) {
    showDialog(
      context: context,
      builder: (context) => MainDialogElement(
        width: MediaQuery.of(context).size.width,
        height: double.infinity,
        onClose: () {
          ref
              .read(vignetteReaderControllerProvider.notifier)
              .resetVignetteReaderState(
                vignetteReaderState,
              );
        },
        child: SortKeywordSreen(
          vignetteReaderState: vignetteReaderState,
          onCompleted: (CategoryModel category) {
            _upload(category, vignetteReaderState);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _upload(
    CategoryModel category,
    VignetteReaderState vignetteReaderState,
  ) {
    ref.read(categoryControllerProvider.notifier).loadCategory(
          category.name,
        );
    ref.read(vignetteReaderControllerProvider.notifier).upload(
          vignetteReaderState,
        );
  }

  void _onUploading(
    BuildContext context,
    VignetteReaderState nextStat,
  ) {
    final CategoryModel? keywordIsInCategory =
        ref.read(categoryListControllerProvider.notifier).keywordIsInCategory(
              widget.section,
            );

    if (keywordIsInCategory == null) {
      _createKeywordModal(context, nextStat);
      return;
    }

    _upload(keywordIsInCategory, nextStat);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(categoryListControllerProvider);
    final vignetteReaderController =
        ref.watch(vignetteReaderControllerProvider);

    final VignetteReaderState? vignetteReaderState =
        vignetteReaderController.firstWhere(
      (element) => element?.section == widget.section,
      orElse: () => null,
    );

    ref.listen(
      vignetteReaderControllerProvider,
      (previous, next) {
        final nextStat = next.firstWhere(
          (element) => element?.section == widget.section,
          orElse: () => null,
        );

        if (nextStat != null) {
          switch (nextStat.status) {
            case VignetteReaderStatus.uploading:
              _onUploading(context, nextStat);
              break;
            case VignetteReaderStatus.uploaded:
              ref.read(categoryControllerProvider.notifier).addVideo(
                    nextStat.videoDataModel!.name,
                  );
              ref.read(categoryControllerProvider.notifier).addKeyword(
                    nextStat.section.keyword!,
                  );
              ref.read(categoryControllerProvider.notifier).save();
              ref.read(videoDataControllerProvider.notifier).addVideo(
                    nextStat.videoDataModel!,
                  );

              widget.onCompleted(nextStat);
              break;
            default:
              break;
          }
        }
      },
    );

    return DropzoneElement(
      onFile: (files) =>
          ref.read(vignetteReaderControllerProvider.notifier).addVideoDataModel(
                widget.section,
                files.first,
              ),
      builder: (
        context,
        dropzoneParams,
      ) {
        return Consumer(
          builder: (context, ref, child) {
            final String? videoId = vignetteReaderState?.section.fileName;

            return BoxImage(
              key: UniqueKey(),
              videoId: videoId,
              builder: (
                BuildContext context,
                ImageModel imageModel,
              ) {
                if (dropzoneParams.errorType != ErrorType.idle) {
                  debugPrint('Error: ${dropzoneParams.errorType}');
                }

                VignetteReaderState? vignetteReaderState =
                    vignetteReaderController.firstWhere(
                  (element) => element?.section == widget.section,
                  orElse: () => null,
                );

                if (imageModel.state != ImageState.loaded) {
                  return Center(
                    child: Icon(
                      Icons.hourglass_top_outlined,
                      color: Colors.grey.shade400,
                    ),
                  );
                }

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Center(
                      child: IconUploadEditorElement(
                        status: dropzoneParams.errorType == ErrorType.idle
                            ? vignetteReaderState?.status
                            : VignetteReaderStatus.error,
                        isDragging: dropzoneParams.dragging,
                        hasThumbnail: videoId != null,
                        onCompleted: () async {
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
                            allowMultiple: false,
                            type: FileType.video,
                          );

                          if (result == null) {
                            return;
                          }

                          ref
                              .read(vignetteReaderControllerProvider.notifier)
                              .addVideoDataModel(
                                widget.section,
                                XFile(result.files.first.path!),
                              );
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 10,
                      child: Text(
                        vignetteReaderState?.section.keyword ?? '',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: videoId == null
                              ? Colors.grey.shade600
                              : Colors.white,
                          fontStyle: FontStyle.italic,
                          shadows: [
                            if (videoId != null)
                              Shadow(
                                color: Colors.grey.shade800,
                                offset: const Offset(.5, .5),
                                blurRadius: 6,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
