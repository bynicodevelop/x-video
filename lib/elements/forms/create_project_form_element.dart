import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/project_controller.dart';
import 'package:x_video_ai/utils/translate.dart';

class CreateProjectFormElement extends ConsumerWidget {
  const CreateProjectFormElement({
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
              labelText: $(context).form_project_name_label,
            ),
            onChanged: (value) => ref
                .read(createProjectControllerProvider.notifier)
                .setName(value),
          ),
        ],
      ),
    );
  }
}
