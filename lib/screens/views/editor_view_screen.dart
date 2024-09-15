import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/components/scaffold/tool_bar_editor_component.dart';
import 'package:x_video_ai/controllers/config_controller.dart';
import 'package:x_video_ai/controllers/content_controller.dart';
import 'package:x_video_ai/controllers/content_list_controller.dart';
import 'package:x_video_ai/controllers/video_data_controller.dart';
import 'package:x_video_ai/models/content_model.dart';
import 'package:x_video_ai/screens/views/editor/chronical_view_editor_screen.dart';
import 'package:x_video_ai/screens/views/editor/initialize_content_editor_screen.dart';
import 'package:x_video_ai/screens/views/editor/video_creator_editor_screen.dart';
import 'package:x_video_ai/screens/views/editor/video_view_editor_screen.dart';

class EditorViewScreen extends ConsumerStatefulWidget {
  const EditorViewScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditorViewScreenState();
}

class _EditorViewScreenState extends ConsumerState<EditorViewScreen> {
  final PageController _pageController = PageController(
    initialPage: 0,
  );
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final configService = ref.read(configControllerProvider);

      if (configService?.model != null &&
          configService!.model!.path.isNotEmpty &&
          configService.model!.name.isNotEmpty) {
        ref.read(contentControllerProvider.notifier).initContent(ContentModel(
              path: "${configService.model!.path}/${configService.model!.name}",
            ));

        ref.read(contentListControllerProvider.notifier).loadContents(
            "${configService.model!.path}/${configService.model!.name}");

        ref.read(videoDataControllerProvider.notifier).loadVideos();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(contentControllerProvider);
    ref.watch(videoDataControllerProvider);

    final contentController = ref.read(contentControllerProvider.notifier);

    return Scaffold(
      bottomNavigationBar: contentController.isInitialized
          ? ToolBarEditorComponent(
              buttons: [
                IconButton(
                  icon: Icon(
                    Icons.edit_note_outlined,
                    color: _currentPage == 0
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade500,
                  ),
                  onPressed: () =>
                      setState(() => _pageController.jumpToPage(0)),
                ),
                IconButton(
                  icon: Icon(
                    Icons.movie_edit,
                    color: _currentPage == 1
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade500,
                  ),
                  onPressed: contentController.hasChronical
                      ? () => setState(() => _pageController.jumpToPage(1))
                      : null,
                ),
                IconButton(
                  icon: Icon(
                    Icons.coffee_maker,
                    color: _currentPage == 2
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade500,
                  ),
                  onPressed: contentController.hasChronical
                      ? () => setState(() => _pageController.jumpToPage(2))
                      : null,
                ),
              ],
            )
          : null,
      body: contentController.isInitialized
          ? PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              onPageChanged: (value) => setState(() => _currentPage = value),
              children: contentController.content.id.isNotEmpty
                  ? [
                      const ChronicalViewEditorScreen(),
                      const VideoViewEditorScreen(),
                      const VideoCreatorEditorScreen(),
                    ]
                  : [],
            )
          : const InitializeContentEditorScreen(),
    );
  }
}
