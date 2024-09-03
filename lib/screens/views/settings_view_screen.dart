import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/elements/forms/setting_form_elements.dart';

class SettingViewScreen extends ConsumerWidget {
  const SettingViewScreen({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return const SingleChildScrollView(
      child: SettingFormElement(),
    );
  }
}
