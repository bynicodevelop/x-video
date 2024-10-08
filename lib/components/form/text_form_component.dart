import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TextFormComponent extends ConsumerWidget {
  final void Function(String)? onChanged;
  final bool obscureText;
  final String? initialValue;
  final TextEditingController? controller;

  const TextFormComponent({
    this.onChanged,
    this.controller,
    this.obscureText = false,
    this.initialValue,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      controller: controller ??
          TextEditingController(
            text: initialValue,
          ),
      obscureText: obscureText,
      onChanged: onChanged,
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.all(14),
        border: OutlineInputBorder(),
      ),
    );
  }
}
