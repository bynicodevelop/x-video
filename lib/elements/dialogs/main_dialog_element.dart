import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainDialogElement extends ConsumerWidget {
  final Widget child;
  final String? title;
  final ButtonStyleButton confirm;
  final ButtonStyleButton? cancel;
  final double width;

  const MainDialogElement({
    required this.child,
    required this.confirm,
    this.cancel,
    this.title,
    this.width = 300,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: title != null ? Text(title!) : null,
      content: SizedBox(
        height: 100,
        width: width,
        child: SingleChildScrollView(
          child: child,
        ),
      ),
      actions: [
        if (cancel != null) cancel!,
        confirm,
      ],
    );
  }
}
