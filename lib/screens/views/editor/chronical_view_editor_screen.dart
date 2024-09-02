import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/components/scaffold/nav_bar_item_component.dart';
import 'package:x_video_ai/controllers/content_controller.dart';
import 'package:x_video_ai/controllers/content_list_controller.dart';
import 'package:x_video_ai/controllers/loading_controller.dart';
import 'package:x_video_ai/controllers/reader_content_controller.dart';
import 'package:x_video_ai/controllers/url_extractor_controller.dart';
import 'package:x_video_ai/elements/dialogs/main_dialog_element.dart';
import 'package:x_video_ai/models/link_model.dart';
import 'package:x_video_ai/screens/views/editor/chronical/rss_selector_view_editor_screen.dart';
import 'package:x_video_ai/screens/views/editor/chronical/url_extract_view_editor_screen.dart';
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

                        Navigator.of(context).pop();
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

  void _createOpenContenttDialog(
    BuildContext context,
  ) {
    final isLoading = ref.watch(loadingControllerProvider);
    ref.read(contentListControllerProvider.notifier).loadContents();

    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final contentModels =
                ref.read(contentListControllerProvider.notifier).contentList;

            return MainDialogElement(
              title: 'Ouvrir un contenu existant',
              child: isLoading[kLoadingContent] == true
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: contentModels.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text('Content ${contentModels[index].id}'),
                          onTap: () {
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

  @override
  Widget build(BuildContext context) {
    ref.listen(readerContentControllerProvider, (previous, next) {
      if (next != null) {
        ref.read(contentControllerProvider.notifier).setContent(
              next['title'],
              next['content'],
            );

        ref.read(contentControllerProvider.notifier).save();

        setState(() => showEditor = true);
      }
    });

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.20,
      ),
      child: !showEditor
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
                        onTap: () => _createRsstDialog(
                          context,
                          RssSelectorViewEditor(
                            onFeedSelected: (feed) {
                              ref
                                  .read(
                                      readerContentControllerProvider.notifier)
                                  .loadContent(feed);
                              Navigator.of(context).pop();
                              setState(() => showEditor = true);
                            },
                          ),
                          $(context).form_extract_rss_title_label,
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
                        onTap: () => _createLinktDialog(
                          context,
                          const UrlExtractViewEditor(),
                          $(context).form_extract_title_label,
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
                        onTap: () => setState(() => showEditor = true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 32,
                ),
                TextButton(
                  onPressed: () => _createOpenContenttDialog(context),
                  child: const Text('Ouvrir un contenu existant'),
                ),
              ],
            )
          : Column(
              children: [
                TextField(
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Titre',
                    hintStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.7),
                        ),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
