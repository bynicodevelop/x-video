import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainDialogElement extends ConsumerWidget {
  final Widget child;
  final String? title;
  final ButtonStyleButton? confirm;
  final ButtonStyleButton? cancel;
  final double width;
  final double? height;

  const MainDialogElement({
    required this.child,
    this.confirm,
    this.cancel,
    this.title,
    this.width = 300,
    this.height,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      content: SizedBox(
        height: height ?? 100,
        width: width,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            title: title != null ? Text(title!) : null,
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: child,
          ),
        ),
      ),
      actions: [
        if (cancel != null) cancel!,
        if (confirm != null) confirm!,
      ],
    );
  }
}
