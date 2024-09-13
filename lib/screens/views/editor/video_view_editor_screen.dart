import 'package:desktop_split_pane/desktop_split_pane.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/sections_controller.dart';
import 'package:x_video_ai/controllers/video_data_generator_controller.dart';
import 'package:x_video_ai/models/video_section_model.dart';
import 'package:x_video_ai/screens/views/editor/video/video_player_editor.dart';
import 'package:x_video_ai/screens/views/editor/video/vignette_reader.dart';
import 'package:x_video_ai/screens/views/editor/video/vignette_reader_controller.dart';

class VideoViewEditorScreen extends ConsumerStatefulWidget {
  const VideoViewEditorScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _VideoViewEditorScreenState();
}

class _VideoViewEditorScreenState extends ConsumerState<VideoViewEditorScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(videoDataGeneratorControllerProvider.notifier).startWorkflow();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(videoDataGeneratorControllerProvider);
    ref.watch(sectionsControllerProvider);

    return Stack(
      children: [
        LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            return VerticalSplitPane(
              fractions: const [0.8, 0.2],
              constraints: constraints,
              separatorColor: Colors.grey.shade300,
              separatorThickness: 2,
              children: List<Widget>.from([
                const VideoPlayerEditor(),
                Listener(
                  onPointerSignal: (event) {
                    if (event is PointerScrollEvent) {
                      _scrollController.jumpTo(
                        _scrollController.offset + event.scrollDelta.dy,
                      );
                    }
                  },
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      children: ref
                          .read(sectionsControllerProvider.notifier)
                          .sections
                          .map(
                        (VideoSectionModel section) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: VignetteReaderVideoEditor(
                              section: section,
                              onCompleted:
                                  (VignetteReaderState? vignetteReaderState) {
                                ref
                                    .read(sectionsControllerProvider.notifier)
                                    .updateSection(section.copyWith(
                                      fileName: vignetteReaderState
                                          ?.videoDataModel?.name,
                                    ));
                              },
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                ),
              ]),
            );
          },
        ),
      ],
    );
  }
}
