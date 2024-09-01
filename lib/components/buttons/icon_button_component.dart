import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IconButtonComponent extends ConsumerStatefulWidget {
  final IconData icon;
  final void Function()? onPressed;

  const IconButtonComponent({
    required this.icon,
    this.onPressed,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _IconButtonCompoentState();
}

class _IconButtonCompoentState extends ConsumerState<IconButtonComponent> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (event) => setState(() => isHover = true),
      onExit: (event) => setState(() => isHover = false),
      child: IconButton(
        onPressed: widget.onPressed,
        icon: Icon(
          widget.icon,
          size: 20,
        ),
        color: isHover ? Colors.grey.shade800 : Colors.grey.shade500,
      ),
    );
  }
}
