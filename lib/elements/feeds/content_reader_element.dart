import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:x_video_ai/components/buttons/icon_button_component.dart';
import 'package:x_video_ai/controllers/export_content_controller.dart';
import 'package:x_video_ai/controllers/loading_controller.dart';
import 'package:x_video_ai/controllers/reader_content_controller.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:x_video_ai/utils/constants.dart';

class ContentReaderElement extends ConsumerWidget {
  const ContentReaderElement({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(readerContentControllerProvider);
    final isLoading = ref.watch(loadingControllerProvider);

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.only(
            left: 10,
          ),
          child: isLoading[kLoadingReader] == true
              ? Center(
                  child: SpinKitThreeBounce(
                    color: Theme.of(context).primaryColor.withOpacity(.3),
                    size: 50.0,
                  ),
                )
              : content != null
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.only(
                        top: kToolbarHeight,
                      ),
                      child: Column(
                        children: [
                          SelectableText(
                            content['title'] ?? '',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SelectableText(content['content'] ?? ''),
                        ],
                      ),
                    )
                  : Center(
                      child: Text(
                        "(^_^)",
                        style:
                            Theme.of(context).textTheme.displayLarge!.copyWith(
                                  color: Colors.grey.shade300,
                                ),
                      ),
                    ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(.9),
          height: kToolbarHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButtonComponent(
                icon: Icons.file_download,
                onPressed: content != null
                    ? () => ref
                        .read(exportContentControllerProvider.notifier)
                        .exportContent(content)
                    : null,
              ),
              IconButtonComponent(
                icon: Icons.launch_outlined,
                onPressed: content != null
                    ? () async => await launchUrl(
                          Uri.parse(content['model'].link),
                        )
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
