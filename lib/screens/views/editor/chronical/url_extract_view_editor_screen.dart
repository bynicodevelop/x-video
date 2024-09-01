import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/url_extractor_controller.dart';
import 'package:x_video_ai/utils/translate.dart';

class UrlExtractViewEditor extends ConsumerWidget {
  const UrlExtractViewEditor({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: $(context).form_extract_url_label,
            ),
            onChanged: (value) =>
                ref.read(urlExtractorControllerProvider.notifier).setUrl(value),
          ),
        ],
      ),
    );
  }
}
