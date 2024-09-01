import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavbarItemComponent extends ConsumerStatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final void Function()? onTap;

  const NavbarItemComponent({
    required this.icon,
    required this.label,
    this.selected = false,
    this.onTap,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NavbarItemComponentState();
}

class _NavbarItemComponentState extends ConsumerState<NavbarItemComponent> {
  bool isHovered = false;

  @override
  Widget build(
    BuildContext context,
  ) {
    return MouseRegion(
      onEnter: (event) => setState(() => isHovered = true),
      onExit: (event) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          children: [
            Icon(
              widget.icon,
              size: 24,
              color: widget.onTap != null
                  ? isHovered || widget.selected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary
                  : Colors.grey,
            ),
            Text(
              widget.label,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: widget.onTap != null
                        ? isHovered || widget.selected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.secondary
                        : Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
