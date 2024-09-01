import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ToolBarEditorComponent extends ConsumerWidget {
  final List<Widget> buttons;

  const ToolBarEditorComponent({
    required this.buttons,
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: buttons
            .map(
              (button) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                ),
                child: button,
              ),
            )
            .toList(),
      ),
    );
  }
}
