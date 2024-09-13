import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:x_video_ai/components/buttons/icon_button_component.dart';
import 'package:x_video_ai/controllers/sections_controller.dart';
import 'package:x_video_ai/models/video_section_model.dart';
import 'package:x_video_ai/screens/views/editor/video/video_player_editor_controller.dart';

class VideoPlayerEditor extends ConsumerStatefulWidget {
  const VideoPlayerEditor({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _VideoPlayerEditorState();
}

class _VideoPlayerEditorState extends ConsumerState<VideoPlayerEditor> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final List<VideoSectionModel> sections =
          ref.read(sectionsControllerProvider.notifier).sections;

      ref
          .read(videoPlayerEditorControllerProvider.notifier)
          .initVideoPlayerEditor(
            sections,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(videoPlayerEditorControllerProvider);
    final videoPlayerController =
        ref.read(videoPlayerEditorControllerProvider.notifier);

    return Stack(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.2,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (videoPlayerController.videoPlayerController != null &&
                  videoPlayerController
                      .videoPlayerController!.value.isInitialized)
                AspectRatio(
                  aspectRatio: videoPlayerController
                      .videoPlayerController!.value.aspectRatio,
                  child:
                      VideoPlayer(videoPlayerController.videoPlayerController!),
                ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButtonComponent(
                onPressed: () {
                  if (videoPlayerController.isPlayingState) {
                    videoPlayerController.pauseVideo();
                  } else {
                    videoPlayerController.playVideo();
                  }
                },
                icon: videoPlayerController.isPlayingState
                    ? Icons.pause
                    : Icons.play_arrow,
              ),
            ],
          ),
        )
      ],
    );
  }
}
