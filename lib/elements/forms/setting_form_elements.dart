import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/components/form/heading_form_component.dart';
import 'package:x_video_ai/components/form/scaffold_field_form_component.dart';
import 'package:x_video_ai/components/form/text_form_component.dart';
import 'package:x_video_ai/controllers/config_controller.dart';
import 'package:x_video_ai/utils/debounce.dart';
import 'package:x_video_ai/utils/translate.dart';

class SettingFormElement extends ConsumerWidget {
  const SettingFormElement({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configControllerProvider);

    return Form(
      child: Column(
        children: [
          HeadingFormComponent(
            label: $(context).setting_section_open_ai,
          ),
          ScaffoldFieldFormComponent(
            label: $(context).setting_field_api_key_open_ai,
            field: TextFormComponent(
              initialValue: config?.model?.apiKeyOpenAi,
              obscureText: true,
              onChanged: (value) => debounce(
                () => ref.read(configControllerProvider)?.updateConfiguration(
                      'apiKeyOpenAi',
                      value,
                    ),
              ),
            ),
          ),
          ScaffoldFieldFormComponent(
            label: $(context).setting_field_model_open_ai,
            field: TextFormComponent(
              initialValue: config?.model?.modelOpenAi,
              onChanged: (value) => debounce(
                () => ref.read(configControllerProvider)?.updateConfiguration(
                      'modelOpenAi',
                      value,
                    ),
              ),
            ),
          ),
          ScaffoldFieldFormComponent(
            label: $(context).setting_field_voice_open_ai,
            field: TextFormComponent(
              initialValue: config?.model?.voiceOpenAi,
              onChanged: (value) => debounce(
                () => ref.read(configControllerProvider)?.updateConfiguration(
                      'voiceOpenAi',
                      value,
                    ),
              ),
            ),
          ),
          const HeadingFormComponent(
            label: 'Rss Feed',
          ),
          Column(
            children: [
              ...(config?.model?.feeds ?? []).asMap().entries.map<Widget>(
                (e) {
                  final index = e.key;
                  final value = e.value;

                  return ScaffoldFieldFormComponent(
                    label: "Feed ${index + 1}",
                    field: TextFormComponent(
                      initialValue: value,
                      onChanged: (value) {},
                    ),
                    suffix: IconButton(
                      onPressed: () {
                        final updatedFeeds =
                            List<String>.from(config?.model?.feeds ?? [])
                              ..removeAt(index);
                        ref
                            .read(configControllerProvider.notifier)
                            .update('feeds', updatedFeeds);
                      },
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ) as Widget;
                },
              ),
              const _AddFieldFormComponent(),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddFieldFormComponent extends ConsumerStatefulWidget {
  const _AddFieldFormComponent();

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      __AddFieldFormComponentState();
}

class __AddFieldFormComponentState
    extends ConsumerState<_AddFieldFormComponent> {
  final TextEditingController _apiKeyOpenAiController = TextEditingController();

  bool _isUrl(String value) {
    try {
      final Uri uri = Uri.parse(value);

      return uri.isAbsolute;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(configControllerProvider);

    return ScaffoldFieldFormComponent(
      label: "New Feed",
      field: TextFormComponent(
        controller: _apiKeyOpenAiController,
        onChanged: (value) => setState(() {}),
      ),
      suffix: IconButton(
        onPressed: _isUrl(_apiKeyOpenAiController.text)
            ? () {
                final updatedFeeds =
                    List<String>.from(config?.model?.feeds ?? [])
                      ..add(_apiKeyOpenAiController.text);
                ref
                    .read(configControllerProvider.notifier)
                    .update('feeds', updatedFeeds);

                _apiKeyOpenAiController.clear();
              }
            : null,
        icon: Icon(
          _isUrl(_apiKeyOpenAiController.text)
              ? Icons.add
              : _apiKeyOpenAiController.text.isEmpty
                  ? Icons.add
                  : Icons.error_outline,
        ),
      ),
    );
  }
}
