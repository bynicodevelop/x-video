import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:x_video_ai/components/buttons/popover_button_component.dart';
import 'package:x_video_ai/components/scaffold/nav_bar_component.dart';
import 'package:x_video_ai/components/scaffold/nav_bar_item_component.dart';
import 'package:x_video_ai/controllers/config_controller.dart';
import 'package:x_video_ai/controllers/content_controller.dart';
import 'package:x_video_ai/controllers/content_list_controller.dart';
import 'package:x_video_ai/controllers/loading_controller.dart';
import 'package:x_video_ai/controllers/notification_controller.dart';
import 'package:x_video_ai/controllers/page_controller.dart';
import 'package:x_video_ai/controllers/project_controller.dart';
import 'package:x_video_ai/controllers/video_data_controller.dart';
import 'package:x_video_ai/elements/dialogs/main_dialog_element.dart';
import 'package:x_video_ai/elements/dialogs/notification_element.dart';
import 'package:x_video_ai/elements/forms/create_project_form_element.dart';
import 'package:x_video_ai/gateway/file_picker_gateway.dart';
import 'package:x_video_ai/models/project_model.dart';
import 'package:x_video_ai/screens/views/editor_view_screen.dart';
import 'package:x_video_ai/screens/views/feed_view_screen.dart';
import 'package:x_video_ai/screens/views/settings_view_screen.dart';
import 'package:x_video_ai/services/config_service.dart';
import 'package:x_video_ai/utils/constants.dart';
import 'package:x_video_ai/utils/translate.dart';

class ScafflodScreen extends ConsumerStatefulWidget {
  const ScafflodScreen({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ScafflodScreenState();
}

class _ScafflodScreenState extends ConsumerState<ScafflodScreen> {
  void _openFolderAndCreateProject(BuildContext context) {
    FilePickerGateway.openFolder().then((value) {
      if (value != null) {
        _createProjectDialog(context, value);
      }
    });
  }

  void _openFolderAndLoadConfiguration() {
    FilePickerGateway.openFolder().then((value) {
      if (value != null) {
        final configController = ref.read(configControllerProvider.notifier);
        configController.loadConfiguration(path: value);

        final configService = configController.configService!;

        ref.read(contentListControllerProvider.notifier).loadContents(
            "${configService.model!.path}/${configService.model!.name}");

        ref.read(videoDataControllerProvider.notifier).loadVideos();
      }
    });
  }

  List<NavbarItemComponent> _buildNavBarItems(
    BuildContext context, {
    bool isActive = false,
  }) {
    return [
      NavbarItemComponent(
        selected: ref.watch(pageControllerProvider) == kEditorPage,
        icon: Icons.auto_fix_high,
        label: $(context).nav_bar_item_editor,
        onTap: isActive
            ? () => ref
                .read(pageControllerProvider.notifier)
                .jumpToPage(kEditorPage)
            : null,
      ),
      NavbarItemComponent(
        selected: ref.watch(pageControllerProvider) == kRssFeedPage,
        icon: Icons.rss_feed_outlined,
        label: $(context).nav_bar_item_rss_feed,
        onTap: isActive
            ? () => ref
                .read(pageControllerProvider.notifier)
                .jumpToPage(kRssFeedPage)
            : null,
      ),
      NavbarItemComponent(
        selected: ref.watch(pageControllerProvider) == kSettingPage,
        icon: Icons.settings_outlined,
        label: $(context).nav_bar_item_settings,
        onTap: isActive
            ? () => ref
                .read(pageControllerProvider.notifier)
                .jumpToPage(kSettingPage)
            : null,
      ),
    ];
  }

  TextButton _createProjectButton(
    BuildContext context,
    String label, {
    bool isConfirm = false,
  }) {
    return TextButton(
      onPressed: () {
        if (isConfirm) {
          ref
              .read(createProjectControllerProvider.notifier)
              .save()
              .then((value) => Navigator.of(context).pop());
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Text(label),
    );
  }

  void _createProjectDialog(
    BuildContext context,
    String path,
  ) {
    ref.read(createProjectControllerProvider.notifier).setPath(path);

    showDialog(
      context: context,
      builder: (context) {
        return MainDialogElement(
          title: $(context).create_project_dialog_title,
          cancel: _createProjectButton(
            context,
            $(context).cancel_button_label,
          ),
          confirm: _createProjectButton(
            context,
            $(context).confirm_button_label,
            isConfirm: true,
          ),
          child: const CreateProjectFormElement(),
        );
      },
    );
  }

  late PageController _localPageController;

  @override
  void initState() {
    super.initState();
    // Initialiser le PageController à partir du provider
    _localPageController =
        ref.read(pageControllerProvider.notifier).pageController;
  }

  @override
  void dispose() {
    _localPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final ConfigService<ProjectModel>? configService =
        ref.watch(configControllerProvider);
    ref.watch(contentControllerProvider);
    ref.watch(loadingControllerProvider);

    final loadingController = ref.read(loadingControllerProvider.notifier);

    ref.listen(notificationControllerProvider, (previous, next) {
      if (next.message.isNotEmpty) {
        showNotification(
          context,
          next.message,
          next.type,
        );
      }
    });

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Text(
                  configService != null && configService.model != null
                      ? configService.model!.name
                      : $(context).untitled_project_name,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(
                  width: 10,
                ),
                TextButton(
                  onPressed: ref
                          .read(contentControllerProvider.notifier)
                          .isInitialized
                      ? () {
                          ref.read(contentControllerProvider.notifier).reset();
                        }
                      : null,
                  // TODO: Add translation
                  child: const Text("New content"),
                ),
              ],
            ),
            actions: [
              PopoverButtonComponent(
                label: $(context).projects_button_label,
                icon: Icons.source_outlined,
                items: [
                  ItemPopoverButtonComponent(
                    label: $(context).create_projects_button_label,
                    icon: Icons.create_new_folder_outlined,
                    onPressed: () => _openFolderAndCreateProject(context),
                  ),
                  ItemPopoverButtonComponent(
                    label: $(context).open_projects_button_label,
                    icon: Icons.folder_open_outlined,
                    onPressed: () => _openFolderAndLoadConfiguration(),
                  ),
                ],
              ),
              const SizedBox(
                width: 20,
              ),
            ],
          ),
          body: Row(
            children: [
              NavBarComponent(
                items: _buildNavBarItems(
                  context,
                  isActive: configService != null,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: PageView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: ref
                        .watch(pageControllerProvider.notifier)
                        .pageController,
                    children: const [
                      EditorViewScreen(),
                      FeedViewScreen(),
                      SettingViewScreen(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Visibility(
          visible: loadingController.isLoading(kLoadingMain),
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(
                  0.7,
                ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SpinKitSpinningLines(
                  color: Theme.of(context).primaryColor,
                  size: 50.0,
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  loadingController.progressState?.message ?? '',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
