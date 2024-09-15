import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/elements/forms/category_form_element.dart';
import 'package:x_video_ai/elements/images/box_image.dart';
import 'package:x_video_ai/models/category_model.dart';
import 'package:x_video_ai/screens/views/editor/video/vignette_reader_controller.dart';

class SortKeywordSreen extends ConsumerStatefulWidget {
  final VignetteReaderState vignetteReaderState;
  final Function(CategoryModel)? onCompleted;

  const SortKeywordSreen({
    required this.vignetteReaderState,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.5,
            child: BoxImage(
              thumbnail: widget.vignetteReaderState.thumbnail,
              builder: (context) => const SizedBox.shrink(),
            ),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Expanded(
          flex: 1,
          child: CategoryFormElement(
            keyword: widget.vignetteReaderState.section.keyword!,
            onCategorySelected: (
              CategoryModel category,
            ) {
              if (widget.vignetteReaderState.section.keyword == null) {
                throw Exception("Keyword is required");
              }

              widget.onCompleted?.call(category);
            },
          ),
        ),
      ],
    );
  }
}
