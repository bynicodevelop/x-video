import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/components/scaffold/tool_bar_editor_component.dart';
import 'package:x_video_ai/controllers/config_controller.dart';
import 'package:x_video_ai/controllers/content_controller.dart';
import 'package:x_video_ai/controllers/content_list_controller.dart';
import 'package:x_video_ai/controllers/video_data_controller.dart';
import 'package:x_video_ai/models/content_model.dart';
import 'package:x_video_ai/screens/views/editor/chronical_view_editor_screen.dart';
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
    initialPage: 1,
  );

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
      }
    });

    Future.microtask(() {
      if (kDebugMode) {
        ref.read(contentListControllerProvider.notifier).loadContents(
            "/Volumes/Macintosh HD/Users/nicolasmoricet/Documents/XVideoIA/Nouveau project");
        final contentModels =
            ref.read(contentListControllerProvider.notifier).contentList;

        ref
            .read(contentControllerProvider.notifier)
            .initContent(contentModels[0]);
      }

      ref.read(videoDataControllerProvider.notifier).loadVideos();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(contentControllerProvider);
    ref.watch(videoDataControllerProvider);

    return Scaffold(
      bottomNavigationBar:
          ref.read(contentControllerProvider.notifier).isInitialized
              ? ToolBarEditorComponent(
                  buttons: [
                    IconButton(
                      icon: Icon(
                        Icons.edit_note_outlined,
                        color: _pageController.page == 0
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade500,
                      ),
                      onPressed: () => _pageController.jumpToPage(0),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.movie_edit,
                        color: _pageController.page == 1
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade500,
                      ),
                      onPressed: () => _pageController.jumpToPage(1),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.coffee_maker,
                        color: _pageController.page == 2
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade500,
                      ),
                      onPressed: () => _pageController.jumpToPage(2),
                    ),
                  ],
                )
              : null,
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        children:
            ref.read(contentControllerProvider.notifier).content.id.isNotEmpty
                ? [
                    const ChronicalViewEditorScreen(),
                    const VideoViewEditorScreen(),
                    const VideoCreatorEditorScreen(),
                  ]
                : [],
      ),
    );
  }
}
