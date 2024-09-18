import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/elements/images/box_image_controller.dart';

class BoxImage extends ConsumerStatefulWidget {
  final String? videoId;
  final Widget Function(
    BuildContext context,
    ImageModel imageModel,
  ) builder;

  const BoxImage({
    required this.videoId,
    required this.builder,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BoxImageState();
}

class _BoxImageState extends ConsumerState<BoxImage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(
      () {
        if (mounted) {
          ref
              .read(boxImageControllerProvider.notifier)
              .generateThumbnailFromVideoId(
                widget.videoId,
                widget.key!,
              );
        }
      },
    );
  }

  @override
  void didUpdateWidget(covariant BoxImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.videoId != widget.videoId) {
      Future.microtask(
        () {
          if (mounted) {
            ref
                .read(boxImageControllerProvider.notifier)
                .generateThumbnailFromVideoId(
                  widget.videoId,
                  widget.key!,
                );
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(boxImageControllerProvider);

    final ImageModel imageModel = ref
        .watch(boxImageControllerProvider.notifier)
        .getThumbnailModel(widget.key!);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        image: imageModel.thumbnail != null
            ? DecorationImage(
                image: MemoryImage(imageModel.thumbnail!),
                opacity: 0.7,
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: widget.builder(
        context,
        imageModel,
      ),
    );
  }
}
