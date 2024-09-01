import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:x_video_ai/controllers/feed_controller.dart';
import 'package:x_video_ai/controllers/loading_controller.dart';
import 'package:x_video_ai/models/feed_model.dart';
import 'package:x_video_ai/utils/constants.dart';

class RssSelectorViewEditor extends ConsumerStatefulWidget {
  final Function(FeedModel) onFeedSelected;

  const RssSelectorViewEditor({required this.onFeedSelected, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RssSelectorViewEditorState();
}

class _RssSelectorViewEditorState extends ConsumerState<RssSelectorViewEditor> {
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

    return loading[kLoadingFeeds] == true
        ? Center(
            child: SpinKitThreeBounce(
              color: Theme.of(context).primaryColor.withOpacity(.3),
              size: 30.0,
            ),
          )
        : SingleChildScrollView(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: feeds.length,
              itemBuilder: (context, index) {
                final feed = feeds[index];
                return ListTile(
                  title: Text(feed.title),
                  subtitle: Text(feed.domain),
                  onTap: () => widget.onFeedSelected(feed),
                );
              },
            ),
          );
  }
}
