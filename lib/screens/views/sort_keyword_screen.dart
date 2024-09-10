import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/category_controller.dart';
import 'package:x_video_ai/controllers/category_list_controller.dart';
import 'package:x_video_ai/controllers/sections_controller.dart';
import 'package:x_video_ai/elements/forms/category_form_element.dart';
import 'package:x_video_ai/elements/images/box_image.dart';
import 'package:x_video_ai/models/category_model.dart';
import 'package:x_video_ai/models/video_model.dart';
import 'package:x_video_ai/models/video_section_model.dart';

class SortKeywordSreen extends ConsumerStatefulWidget {
  final VideoDataModel video;
  final VideoSectionModel section;
  final Function()? onCompleted;

  const SortKeywordSreen({
    required this.video,
    required this.section,
    this.onCompleted,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SortKeywordSreenState();
}

class _SortKeywordSreenState extends ConsumerState<SortKeywordSreen> {
  @override
  Widget build(BuildContext context) {
    ref.watch(categoryListControllerProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.5,
            // child: BoxImage(
            //   key: widget.key,
            //   builder: (context, params) => const SizedBox.shrink(),
            // ),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Expanded(
          flex: 1,
          child: CategoryFormElement(
            onCategorySelected: (CategoryModel category) {
              if (widget.section.keyword == null) {
                throw Exception("Keyword is required");
              }

              // Update les mots-clés de la catégorie
              final categoryController =
                  ref.read(categoryControllerProvider.notifier);
              categoryController.loadCategory(category.name);
              categoryController.addVideo(widget.video.name);
              categoryController.addKeyword(widget.section.keyword!);
              categoryController.save();

              // Update la section avec la vidéo choisie
              final sectionController =
                  ref.read(sectionsControllerProvider.notifier);

              sectionController.updateSection(
                widget.section.copyWith(
                  fileName: widget.video.name,
                ),
              );

              // Permet de dire que le traitement est terminé pour les mots-clés
              ref
                  .read(categoryListControllerProvider.notifier)
                  .resetKeywordIsInCategory();

              widget.onCompleted?.call();
            },
          ),
        ),
      ],
    );
  }
}
