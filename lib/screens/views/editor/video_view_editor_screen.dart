import 'package:desktop_split_pane/desktop_split_pane.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/sections_controller.dart';
import 'package:x_video_ai/controllers/video_data_generator_controller.dart';
import 'package:x_video_ai/models/video_section_model.dart';
import 'package:x_video_ai/screens/views/editor/video/video_player_editor.dart';
import 'package:x_video_ai/screens/views/editor/video/video_player_editor_controller.dart';
import 'package:x_video_ai/screens/views/editor/video/video_selector_editor.dart';
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

  List<GlobalKey> _sectionKeys = [];

  void _scrollToCurrentIndex() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentIndex = ref
          .read(videoPlayerEditorControllerProvider.notifier)
          .currentVideoIndex;

      if (currentIndex >= _sectionKeys.length) return;

      RenderBox? currentBox = _sectionKeys[currentIndex]
          .currentContext
          ?.findRenderObject() as RenderBox?;
      if (currentBox == null) return;

      Offset position = currentBox.localToGlobal(Offset.zero,
          ancestor: context.findRenderObject());

      double itemCenter = position.dx + currentBox.size.width / 2;

      double viewportWidth = MediaQuery.of(context).size.width;

      double targetScrollOffset =
          _scrollController.offset + itemCenter - viewportWidth / 2;

      double maxScrollExtent = _scrollController.position.maxScrollExtent;
      double minScrollExtent = _scrollController.position.minScrollExtent;

      if (targetScrollOffset < minScrollExtent) {
        targetScrollOffset = minScrollExtent;
      } else if (targetScrollOffset > maxScrollExtent) {
        targetScrollOffset = maxScrollExtent;
      }

      _scrollController.animateTo(
        targetScrollOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(videoDataGeneratorControllerProvider);
    ref.watch(sectionsControllerProvider);

    if (_sectionKeys.length !=
        ref.read(sectionsControllerProvider.notifier).sections.length) {
      _sectionKeys = List.generate(
        ref.read(sectionsControllerProvider.notifier).sections.length,
        (index) => GlobalKey(),
      );
    }

    ref.listen(
      videoPlayerEditorControllerProvider,
      (previous, next) {
        _scrollToCurrentIndex();
      },
    );

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
                          .asMap()
                          .entries
                          .map(
                        (MapEntry<int, VideoSectionModel> entry) {
                          final int index = entry.key;
                          final VideoSectionModel section = entry.value;
                          final BorderRadius borderRadius =
                              BorderRadius.circular(8);
                          return Padding(
                            padding: const EdgeInsets.only(
                              right: 8,
                            ),
                            child: VideoSelectorEditor(
                              key: _sectionKeys[index],
                              index: index,
                              borderRadius: borderRadius,
                              child: VignetteReaderVideoEditor(
                                key: ValueKey(section.id),
                                section: section,
                                onCompleted:
                                    (VignetteReaderState? vignetteReaderState) {
                                  ref
                                      .read(sectionsControllerProvider.notifier)
                                      .updateSection(
                                        section.copyWith(
                                          fileName: vignetteReaderState
                                              ?.videoDataModel?.name,
                                        ),
                                      );
                                },
                              ),
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
