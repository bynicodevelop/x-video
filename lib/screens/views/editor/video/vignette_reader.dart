import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/category_controller.dart';
import 'package:x_video_ai/controllers/category_list_controller.dart';
import 'package:x_video_ai/controllers/video_data_controller.dart';
import 'package:x_video_ai/elements/dialogs/main_dialog_element.dart';
import 'package:x_video_ai/elements/files/dropzone_element.dart';
import 'package:x_video_ai/elements/images/box_image.dart';
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

  IconData _getIconBasedOnState(VignetteReaderStatus? status) {
    if (status == null) {
      return Icons.hourglass_top_outlined;
    }

    if (status == VignetteReaderStatus.uploading) {
      return Icons.upload_file;
    }

    return Icons.file_upload_outlined; // Add a return statement at the end
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

    final thumbnail = vignetteReaderController
        .firstWhere(
          (element) => element?.section == widget.section,
          orElse: () => null,
        )
        ?.thumbnail;

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
      onFile: (files) {
        ref.read(vignetteReaderControllerProvider.notifier).addVideoDataModel(
              widget.section,
              files.first,
            );
      },
      builder: (
        context,
        dropzoneParams,
      ) {
        return BoxImage(
          thumbnail: thumbnail,
          builder: (
            BuildContext context,
          ) {
            if (dropzoneParams.errorType != ErrorType.idle) {
              debugPrint('Error: ${dropzoneParams.errorType}');
            }

            return Center(
              child: IconButton(
                icon: Icon(
                  dropzoneParams.errorType == ErrorType.idle
                      ? _getIconBasedOnState(
                          vignetteReaderController
                              .firstWhere(
                                (element) => element?.section == widget.section,
                                orElse: () => null,
                              )
                              ?.status,
                        )
                      : Icons.error,
                  color: dropzoneParams.dragging
                      ? Colors.blue.shade400
                      : thumbnail != null
                          ? Colors.white
                          : Colors.grey.shade400,
                ),
                onPressed: () {},
              ),
            );
          },
        );
      },
    );
  }
}
