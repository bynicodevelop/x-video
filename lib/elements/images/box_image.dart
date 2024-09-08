import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/elements/images/box_image_controller.dart';

class BoxImageParams {
  final Key key;
  final bool dragging;
  final Uint8List? thumbnail;

  BoxImageParams({
    required this.key,
    required this.dragging,
    this.thumbnail,
  });
}

class BoxImage extends ConsumerStatefulWidget {
  final bool dragging;
  final Widget Function(BuildContext context, BoxImageParams params) builder;

  const BoxImage({
    required this.builder,
    this.dragging = false,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BoxImageState();
}

class _BoxImageState extends ConsumerState<BoxImage> {
  @override
  Widget build(BuildContext context) {
    ref.watch(boxImageControllerProvider);
    final thumbnail = ref
        .watch(boxImageControllerProvider.notifier)
        .getThumbnail(widget.key!);

    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: widget.dragging
            ? Colors.blue.shade100
            : thumbnail != null
                ? Colors.grey.shade100
                : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
        image: thumbnail != null
            ? DecorationImage(
                image: MemoryImage(thumbnail),
                fit: BoxFit.cover,
                opacity: 0.7,
              )
            : null,
      ),
      child: widget.builder(
        context,
        BoxImageParams(
          key: widget.key!,
          dragging: widget.dragging,
          thumbnail: thumbnail,
        ),
      ),
    );
  }
}
