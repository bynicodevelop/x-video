import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/components/buttons/popover_button_component.dart';
import 'package:x_video_ai/components/scaffold/nav_bar_component.dart';
import 'package:x_video_ai/components/scaffold/nav_bar_item_component.dart';
import 'package:x_video_ai/controllers/config_controller.dart';
import 'package:x_video_ai/controllers/project_controller.dart';
import 'package:x_video_ai/elements/dialogs/main_dialog_element.dart';
import 'package:x_video_ai/elements/forms/create_project_form_element.dart';
import 'package:x_video_ai/gateway/file_picker_gateway.dart';
import 'package:x_video_ai/models/project_model.dart';
import 'package:x_video_ai/screens/views/feed_view_screen.dart';
import 'package:x_video_ai/screens/views/settings_view_screen.dart';
import 'package:x_video_ai/services/config_service.dart';
import 'package:x_video_ai/utils/translate.dart';

class ScafflodScreen extends ConsumerStatefulWidget {
  const ScafflodScreen({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ScafflodScreenState();
}

class _ScafflodScreenState extends ConsumerState<ScafflodScreen> {
  final PageController _pageController = PageController(
    initialPage: 0,
  );

  @override
  void initState() {
    super.initState();

    if (kDebugMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // TODO: Ne pas commiter
        ref.read(configControllerProvider.notifier).loadConfiguration(
              path:
                  '/Volumes/Macintosh HD/Users/nicolasmoricet/Documents/XVideoIA/Nouveau project',
            );
      });
    }
  }

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
        ref
            .read(configControllerProvider.notifier)
            .loadConfiguration(path: value);
      }
    });
  }

  int _getCurrentPage() {
    if (_pageController.hasClients) {
      return _pageController.page?.round() ?? 0;
    } else {
      return 0;
    }
  }

  List<NavbarItemComponent> _buildNavBarItems(
    BuildContext context, {
    bool isActive = false,
  }) {
    return [
      NavbarItemComponent(
        selected: _getCurrentPage() == 0,
        icon: Icons.rss_feed_outlined,
        label: $(context).nav_bar_item_rss_feed,
        onTap: isActive ? () => _pageController.jumpToPage(0) : null,
      ),
      NavbarItemComponent(
        selected: _getCurrentPage() == 1,
        icon: Icons.settings_outlined,
        label: $(context).nav_bar_item_settings,
        onTap: isActive ? () => _pageController.jumpToPage(1) : null,
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final ConfigService<ProjectModel>? configService =
        ref.watch(configControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          configService != null && configService.model != null
              ? configService.model!.name
              : $(context).untitled_project_name,
          style: Theme.of(context).textTheme.titleSmall,
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
                controller: _pageController,
                onPageChanged: (value) => setState(() {}),
                children: [
                  FeedViewScreen(),
                  const SettingViewScreen(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
