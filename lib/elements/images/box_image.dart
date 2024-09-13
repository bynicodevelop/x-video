import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BoxImage extends ConsumerStatefulWidget {
  final Uint8List? thumbnail;
  final Widget Function(
    BuildContext context,
  ) builder;

  const BoxImage({
    required this.thumbnail,
    required this.builder,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BoxImageState();
}

class _BoxImageState extends ConsumerState<BoxImage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        image: widget.thumbnail != null
            ? DecorationImage(
                image: MemoryImage(widget.thumbnail!),
                opacity: 0.7,
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: widget.builder(
        context,
      ),
    );
  }
}
