import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TextButtonComponent extends ConsumerWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;

  const TextButtonComponent({
    required this.text,
    this.icon,
    this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton(
      onPressed: onPressed,
      child: Row(
        children: [
          if (icon != null) Icon(icon),
          const SizedBox(width: 5),
          Text(text),
        ],
      ),
    );
  }
}
