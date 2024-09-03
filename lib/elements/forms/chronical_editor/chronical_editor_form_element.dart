import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/content_controller.dart';
import 'package:x_video_ai/utils/translate.dart';

class ChronicalEditorFormElement extends ConsumerStatefulWidget {
  const ChronicalEditorFormElement({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChronicalEditorFormElementState();
}

class _ChronicalEditorFormElementState
    extends ConsumerState<ChronicalEditorFormElement> {
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final content = ref.read(contentControllerProvider.notifier);
      _contentController.text = content.content.chronical!['content'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _contentController,
      maxLines: null,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).colorScheme.secondary,
            fontSize: 18,
            height: 1.8,
          ),
      decoration: InputDecoration(
        hintText: $(context).chronical_editor_form_element_label,
        hintStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
            ),
        border: InputBorder.none,
      ),
    );
  }
}
