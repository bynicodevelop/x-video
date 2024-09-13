import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/screens/views/editor/video/video_player_editor_controller.dart';

class VideoSelectorEditor extends ConsumerWidget {
  final Widget child;
  final int index;
  final BorderRadius borderRadius;

  const VideoSelectorEditor({
    super.key,
    required this.child,
    required this.index,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex =
        ref.watch(videoPlayerEditorControllerProvider)['index'];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color:
            index == currentIndex ? Colors.blue.shade300 : Colors.transparent,
        borderRadius: borderRadius,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: child,
      ),
    );
  }
}
