import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/elements/forms/create_content/create_content_form_element_controller.dart';
import 'package:x_video_ai/utils/translate.dart';

class CreateContentFormElement extends ConsumerStatefulWidget {
  const CreateContentFormElement({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateContentFormElementState();
}

class _CreateContentFormElementState
    extends ConsumerState<CreateContentFormElement> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final defaultName = 'Content-$id';

    _nameController = TextEditingController(
      text: defaultName,
    );

    Future.microtask(() {
      ref
          .read(createContentFormControllerProvider.notifier)
          .setName(defaultName);

      ref.read(createContentFormControllerProvider.notifier).setId(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(createContentFormControllerProvider);

    return Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: $(context).create_content_label_form_element,
              errorText: formState.errors['name'],
            ),
            onChanged: (value) => ref
                .read(createContentFormControllerProvider.notifier)
                .setName(value),
          ),
        ],
      ),
    );
  }
}
