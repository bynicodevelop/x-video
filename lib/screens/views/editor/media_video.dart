import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/category_list_controller.dart';
import 'package:x_video_ai/elements/forms/category_form_element.dart';
import 'package:x_video_ai/elements/images/box_image.dart';
import 'package:x_video_ai/models/category_model.dart';

class MediaVideo extends ConsumerStatefulWidget {
  final void Function(String)? onVideoSelected;

  const MediaVideo({
    this.onVideoSelected,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MediaVideoState();
}

class _MediaVideoState extends ConsumerState<MediaVideo> {
  int _defaultSelectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    ref.watch(categoryListControllerProvider.notifier);

    final List<CategoryModel> categories =
        ref.watch(categoryListControllerProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 16 / 9,
              ),
              itemCount: categories[_defaultSelectedIndex].videos.length,
              itemBuilder: (context, index) {
                final videoId = categories[_defaultSelectedIndex].videos[index];

                return AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Consumer(
                    builder: (context, ref, child) {
                      return GestureDetector(
                        onTap: () {
                          if (widget.onVideoSelected != null) {
                            widget.onVideoSelected!(videoId);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                          ),
                          child: BoxImage(
                            key: UniqueKey(),
                            videoId: videoId,
                            builder: (
                              context,
                              image,
                            ) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 20,
            ),
            child: CategoryFormElement(
              onCategorySelected: (category) {
                final index = categories.indexWhere(
                  (element) => element.name == category.name,
                );

                setState(() => _defaultSelectedIndex = index);
              },
            ),
          ),
        ),
      ],
    );
  }
}
