import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/elements/images/box_image_controller.dart';
import 'package:x_video_ai/models/editor_section_model.dart';

class BoxImageParams {
  final bool dragging;
  final Uint8List? thumbnail;

  BoxImageParams({
    required this.dragging,
    this.thumbnail,
  });
}

class BoxImage extends ConsumerStatefulWidget {
  final EditorSectionModel? section;
  final bool dragging;
  final Widget Function(BuildContext context, BoxImageParams params) builder;

  const BoxImage({
    required this.builder,
    this.section,
    this.dragging = false,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BoxImageState();
}

class _BoxImageState extends ConsumerState<BoxImage> {
  @override
  void initState() {
    super.initState();

    if (widget.section != null) {
      // Future.microtask(() => )
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(boxImageControllerProvider);
    const thumbnail = null;
    // final thumbnail = ref
    //     .watch(boxImageControllerProvider.notifier)
    //     .getThumbnail(widget.key!);

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
          dragging: widget.dragging,
          thumbnail: thumbnail,
        ),
      ),
    );
  }
}
