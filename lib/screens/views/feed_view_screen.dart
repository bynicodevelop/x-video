import 'package:desktop_split_pane/desktop_split_pane.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:x_video_ai/controllers/config_controller.dart';
import 'package:x_video_ai/controllers/feed_controller.dart';
import 'package:x_video_ai/controllers/loading_controller.dart';
import 'package:x_video_ai/controllers/reader_content_controller.dart';
import 'package:x_video_ai/elements/feeds/content_reader_element.dart';
import 'package:x_video_ai/services/parse_service.dart';

class FeedViewScreen extends ConsumerWidget {
  FeedViewScreen({super.key});

  final ParseService parseService = ParseService();

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final feeds = ref.watch(feedControllerProvider);
    final loading = ref.watch(loadingControllerProvider);

    ref.listen(configControllerProvider, (previous, next) {
      if (previous?.model != next?.model) {
        ref.read(feedControllerProvider.notifier).fetch();
      }
    });

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
            child: loading['feeds'] == true
                ? Center(
                    child: SpinKitThreeBounce(
                      color: Theme.of(context).primaryColor.withOpacity(.3),
                      size: 50.0,
                    ),
                  )
                : ListView.builder(
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
                  ),
          ),
          const ContentReaderElement(),
        ],
      );
    });
  }
}
