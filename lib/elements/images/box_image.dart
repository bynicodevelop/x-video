// ignore: depend_on_referenced_packages
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/elements/images/box_image_controller.dart';

class BoxImage extends ConsumerStatefulWidget {
  final String? videoId;
  final XFile? file;
  final Widget Function(
    BuildContext context,
    ImageModel imageModel,
  ) builder;

  const BoxImage({
    required this.builder,
    this.videoId,
    this.file,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BoxImageState();
}

class _BoxImageState extends ConsumerState<BoxImage> {
  void _initiateBoxImageController() {
    if (mounted) {
      if (widget.file != null) {
        ref.read(boxImageControllerProvider.notifier).generateThumbnailFromFile(
              widget.file!,
              widget.key!,
            );

        return;
      }

      if (widget.videoId != null) {
        ref
            .read(boxImageControllerProvider.notifier)
            .generateThumbnailFromVideoId(
              widget.videoId,
              widget.key!,
            );

        return;
      }
    }
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(_initiateBoxImageController);
  }

  @override
  void didUpdateWidget(covariant BoxImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.videoId != widget.videoId) {
      Future.microtask(_initiateBoxImageController);
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
