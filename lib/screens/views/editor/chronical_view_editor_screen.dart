import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/components/scaffold/nav_bar_item_component.dart';
import 'package:x_video_ai/controllers/chronical_controller.dart';
import 'package:x_video_ai/controllers/config_controller.dart';
import 'package:x_video_ai/controllers/content_controller.dart';
import 'package:x_video_ai/controllers/content_list_controller.dart';
import 'package:x_video_ai/controllers/loading_controller.dart';
import 'package:x_video_ai/controllers/reader_content_controller.dart';
import 'package:x_video_ai/controllers/url_extractor_controller.dart';
import 'package:x_video_ai/elements/dialogs/main_dialog_element.dart';
import 'package:x_video_ai/elements/forms/chronical_editor/chronical_editor_form_element.dart';
import 'package:x_video_ai/elements/forms/create_content/create_content_form_element.dart';
import 'package:x_video_ai/elements/forms/create_content/create_content_form_element_controller.dart';
import 'package:x_video_ai/models/link_model.dart';
import 'package:x_video_ai/models/project_model.dart';
import 'package:x_video_ai/screens/views/editor/chronical/rss_selector_view_editor_screen.dart';
import 'package:x_video_ai/screens/views/editor/chronical/url_extract_view_editor_screen.dart';
import 'package:x_video_ai/services/config_service.dart';
import 'package:x_video_ai/utils/constants.dart';
import 'package:x_video_ai/utils/translate.dart';

class ChronicalViewEditorScreen extends ConsumerStatefulWidget {
  const ChronicalViewEditorScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChronicalViewEditorScreenState();
}

class _ChronicalViewEditorScreenState
    extends ConsumerState<ChronicalViewEditorScreen> {
  bool showEditor = false;

  void _createRsstDialog(
    BuildContext context,
    Widget child,
    String title,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return MainDialogElement(
          width: MediaQuery.of(context).size.width * 0.40,
          height: MediaQuery.of(context).size.height * 0.60,
          title: title,
          child: child,
        );
      },
    );
  }

  void _createLinktDialog(
    BuildContext context,
    Widget child,
    String title,
  ) {
    ref.read(urlExtractorControllerProvider.notifier).clearUrl();

    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            ref.watch(urlExtractorControllerProvider);

            return MainDialogElement(
              title: title,
              confirm: TextButton(
                onPressed: ref
                        .read(urlExtractorControllerProvider.notifier)
                        .isValideUrl()
                    ? () {
                        Navigator.of(context).pop();

                        ref
                            .read(loadingControllerProvider.notifier)
                            .startLoading(kLoadingMain);

                        final String url = ref
                            .read(urlExtractorControllerProvider.notifier)
                            .url;

                        ref
                            .read(readerContentControllerProvider.notifier)
                            .loadContent(
                              LinkModel(
                                link: url,
                              ),
                            );
                      }
                    : null,
                child: Text($(context).confirm_extract_button_label),
              ),
              cancel: TextButton(
                onPressed: () {
                  ref.read(urlExtractorControllerProvider.notifier).clearUrl();
                  Navigator.of(context).pop();
                },
                child: Text($(context).cancel_button_label),
              ),
              child: child,
            );
          },
        );
      },
    );
  }

  void _createOpenContentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final contentModels =
                ref.read(contentListControllerProvider.notifier).contentList;

            return MainDialogElement(
              width: MediaQuery.of(context).size.width * 0.25,
              height: MediaQuery.of(context).size.height * 0.60,
              // TODO: Translate
              title: 'Ouvrir un contenu existant',
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: contentModels.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Content ${contentModels[index].id}'),
                    onTap: () {
                      print(contentModels[index].toJson());
                      ref
                          .read(contentControllerProvider.notifier)
                          .initContent(contentModels[index]);

                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _createNewContenttDialog(
    BuildContext context,
    Function onContentCreated,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final formController =
                ref.read(createContentFormControllerProvider.notifier);
            final formState = ref.watch(createContentFormControllerProvider);

            return MainDialogElement(
              height: 80,
              title: $(context).create_content_title_modal,
              confirm: TextButton(
                onPressed: formState.isValidForm
                    ? () {
                        formController.submit();
                        Navigator.of(context).pop();
                        onContentCreated();
                      }
                    : null,
                child: Text(
                  $(context).nex_button_modal,
                ),
              ),
              child: const CreateContentFormElement(),
            );
          },
        );
      },
    );
  }

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
      print(path);
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

      setState(() => showEditor = true);
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

      setState(() => showEditor = true);

      ref.read(loadingControllerProvider.notifier).stopLoading(kLoadingMain);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(contentListControllerProvider);
    ref.watch(contentControllerProvider);

    _initListener();

    final contentController = ref.read(contentControllerProvider.notifier);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.20,
      ),
      child: !contentController.isInitialized || !contentController.hasChronical
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  $(context).chronicle_view_title_answer,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  $(context).chronicle_view_subtitle_answer,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(
                  height: 32,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Tooltip(
                      preferBelow: false,
                      textAlign: TextAlign.center,
                      message: $(context).tooltip_button_extract_rss,
                      child: NavbarItemComponent(
                        icon: Icons.rss_feed_outlined,
                        label: $(context).chronicle_button_extract_rss_label,
                        onTap: () => _createNewContenttDialog(
                          context,
                          () => _createRsstDialog(
                            context,
                            RssSelectorViewEditor(
                              onFeedSelected: (feed) {
                                ref
                                    .read(loadingControllerProvider.notifier)
                                    .startLoading(kLoadingMain);

                                Navigator.of(context).pop();

                                ref
                                    .read(readerContentControllerProvider
                                        .notifier)
                                    .loadContent(feed);
                              },
                            ),
                            $(context).form_extract_rss_title_label,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 52,
                    ),
                    Tooltip(
                      preferBelow: false,
                      textAlign: TextAlign.center,
                      message: $(context).tooltip_button_extract_url,
                      child: NavbarItemComponent(
                        icon: Icons.link_outlined,
                        label: $(context).chronicle_button_extract_url_label,
                        onTap: () => _createNewContenttDialog(
                          context,
                          () => _createLinktDialog(
                            context,
                            const UrlExtractViewEditor(),
                            $(context).form_extract_title_label,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 52,
                    ),
                    Tooltip(
                      preferBelow: false,
                      textAlign: TextAlign.center,
                      message: $(context).tooltip_button_write,
                      child: NavbarItemComponent(
                        icon: Icons.edit_note_outlined,
                        label: $(context).chronicle_button_extract_write_label,
                        onTap: () => _createNewContenttDialog(
                          context,
                          () => setState(() => showEditor = true),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 32,
                ),
                TextButton(
                  onPressed: ref
                          .read(contentListControllerProvider.notifier)
                          .contentList
                          .isNotEmpty
                      ? () => _createOpenContentDialog(context)
                      : null,
                  child: Text(
                    $(context).chronicle_button_open_contents,
                  ),
                ),
              ],
            )
          : const SingleChildScrollView(
              child: ChronicalEditorFormElement(),
            ),
    );
  }
}
