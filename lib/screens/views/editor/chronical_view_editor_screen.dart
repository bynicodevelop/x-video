import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/components/scaffold/nav_bar_item_component.dart';
import 'package:x_video_ai/controllers/reader_content_controller.dart';
import 'package:x_video_ai/controllers/url_extractor_controller.dart';
import 'package:x_video_ai/elements/dialogs/main_dialog_element.dart';
import 'package:x_video_ai/models/feed_model.dart';
import 'package:x_video_ai/screens/views/editor/chronical/rss_selector_view_editor_screen.dart';
import 'package:x_video_ai/screens/views/editor/chronical/url_extract_view_editor_screen.dart';
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

                        final FeedModel feed = FeedModel(
                          title: '',
                          link: url,
                          description: '',
                          domain: '',
                          date: DateTime.now(),
                        );

                        print(feed.toJson());

                        ref
                            .read(readerContentControllerProvider.notifier)
                            .loadContent(feed);

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

  @override
  Widget build(BuildContext context) {
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
                              print(feed.toJson());

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
                )
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
