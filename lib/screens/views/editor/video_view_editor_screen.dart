import 'package:desktop_split_pane/desktop_split_pane.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/content_controller.dart';
import 'package:x_video_ai/controllers/sections_controller.dart';
import 'package:x_video_ai/controllers/video_data_generator_controller.dart';
import 'package:x_video_ai/models/video_section_model.dart';
import 'package:x_video_ai/screens/views/editor/video/vignette_reader.dart';

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
    ref.watch(contentControllerProvider);
    ref.watch(videoDataGeneratorControllerProvider);
    ref.watch(sectionsControllerProvider);

    return LayoutBuilder(
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
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.2,
                vertical: 20,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: const Placeholder(),
                  ),
                ],
              ),
            ),
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
                        (VideoSectionModel e) =>
                            const VignetteReaderVideoEditor(),
                      )
                      .toList(),
                ),
              ),
            ),
          ]),
        );
      },
    );
  }
}
