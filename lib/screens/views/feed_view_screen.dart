import 'package:desktop_split_pane/desktop_split_pane.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:x_video_ai/controllers/feed_controller.dart';
import 'package:x_video_ai/controllers/loading_controller.dart';
import 'package:x_video_ai/controllers/page_controller.dart';
import 'package:x_video_ai/controllers/reader_content_controller.dart';
import 'package:x_video_ai/elements/feeds/content_reader_element.dart';
import 'package:x_video_ai/utils/constants.dart';
import 'package:x_video_ai/utils/translate.dart';

class FeedViewScreen extends ConsumerStatefulWidget {
  const FeedViewScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FeedViewScreenState();
}

class _FeedViewScreenState extends ConsumerState<FeedViewScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(feedControllerProvider.notifier).fetch());
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final feeds = ref.watch(feedControllerProvider);
    final loading = ref.watch(loadingControllerProvider);

    return LayoutBuilder(builder: (context, constraints) {
      return HorizontalSplitPane(
        fractions: const [0.6, 0.4],
        constraints: constraints,
        separatorColor: Colors.grey.shade300,
        separatorThickness: 2,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              right: 10,
            ),
            child: loading[kLoadingFeeds] == true
                ? Center(
                    child: SpinKitThreeBounce(
                      color: Theme.of(context).primaryColor.withOpacity(.3),
                      size: 40.0,
                    ),
                  )
                : feeds.isNotEmpty
                    ? ListView.builder(
                        itemCount: feeds.length,
                        itemBuilder: (context, index) {
                          final feed = feeds[index];
                          return ListTile(
                            title: Text(feed.title),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(timeago.format(feed.date)),
                                const Padding(
                                  padding: EdgeInsets.only(
                                    left: 3,
                                    right: 3,
                                  ),
                                  child: Text('•'),
                                ),
                                Text(feed.domain),
                              ],
                            ),
                            onTap: () => ref
                                .read(readerContentControllerProvider.notifier)
                                .loadContent(feed),
                          );
                        },
                      )
                    : Center(
                        child: TextButton(
                          onPressed: () => ref
                              .read(pageControllerProvider.notifier)
                              .jumpToPage(2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text($(context).button_add_rss_feed),
                              const SizedBox(
                                width: 5,
                              ),
                              const Icon(
                                Icons.rss_feed,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
          ),
          const ContentReaderElement(),
        ],
      );
    });
  }
}
