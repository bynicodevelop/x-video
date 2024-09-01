import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FlexButtonComponent extends ConsumerStatefulWidget {
  final void Function()? onTap;

  const FlexButtonComponent({
    this.onTap,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FlexButtonComponentState();
}

class _FlexButtonComponentState extends ConsumerState<FlexButtonComponent> {
  bool _isHovering = false;

  @override
  Widget build(
    BuildContext context,
  ) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: _isHovering ? Colors.grey.shade400 : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Icon(
            Icons.add,
            color: _isHovering ? Colors.grey.shade800 : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}
