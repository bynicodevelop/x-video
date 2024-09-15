import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/chronical_controller.dart';
import 'package:x_video_ai/controllers/config_controller.dart';
import 'package:x_video_ai/controllers/content_controller.dart';
import 'package:x_video_ai/controllers/content_list_controller.dart';
import 'package:x_video_ai/controllers/loading_controller.dart';
import 'package:x_video_ai/controllers/reader_content_controller.dart';
import 'package:x_video_ai/elements/forms/chronical_editor/chronical_editor_form_element.dart';
import 'package:x_video_ai/models/project_model.dart';
import 'package:x_video_ai/services/config_service.dart';
import 'package:x_video_ai/utils/constants.dart';

class ChronicalViewEditorScreen extends ConsumerStatefulWidget {
  const ChronicalViewEditorScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChronicalViewEditorScreenState();
}

class _ChronicalViewEditorScreenState
    extends ConsumerState<ChronicalViewEditorScreen> {
  void _initListener() {
    ref.listen<ConfigService<ProjectModel>?>(
      configControllerProvider,
      _onConfigChanged,
    );
    ref.listen<Map<String, dynamic>?>(
      readerContentControllerProvider,
      _onReaderContentChanged,
    );
    ref.listen<Map<String, dynamic>?>(
      chronicalControllerProvider,
      _onChronicalChanged,
    );
  }

  void _onConfigChanged(
    ConfigService<ProjectModel>? previous,
    ConfigService<ProjectModel>? next,
  ) {
    if (next != null && next.model != null) {
      final String path = "${next.model!.path}/${next.model!.name}";
      ref.read(contentListControllerProvider.notifier).loadContents(path);
    }
  }

  void _onReaderContentChanged(
    Map<String, dynamic>? previous,
    Map<String, dynamic>? next,
  ) {
    if (next != null) {
      ref.read(contentControllerProvider.notifier).setContent(
            next['title'],
            next['content'],
          );

      ref.read(contentControllerProvider.notifier).save();
      ref.read(chronicalControllerProvider.notifier).createChronical();
    }
  }

  void _onChronicalChanged(
    Map<String, dynamic>? previous,
    Map<String, dynamic>? next,
  ) {
    if (next != null && next['chronical'] != null) {
      ref
          .read(contentControllerProvider.notifier)
          .setChronical(next['chronical']);

      ref.read(contentControllerProvider.notifier).save();
      ref.read(loadingControllerProvider.notifier).stopLoading(kLoadingMain);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(contentListControllerProvider);
    ref.watch(contentControllerProvider);

    _initListener();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.20,
      ),
      child: const SingleChildScrollView(
        child: ChronicalEditorFormElement(),
      ),
    );
  }
}
