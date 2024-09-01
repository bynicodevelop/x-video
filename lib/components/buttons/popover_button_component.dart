import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemPopoverButtonComponent {
  final String label;
  final Function onPressed;
  final IconData? icon;

  ItemPopoverButtonComponent({
    required this.label,
    required this.onPressed,
    this.icon,
  });
}

class PopoverButtonComponent extends ConsumerWidget {
  final String label;
  final IconData? icon;
  final List<ItemPopoverButtonComponent> items;

  const PopoverButtonComponent({
    required this.label,
    required this.items,
    this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton(
      elevation: 1,
      surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
      itemBuilder: (context) {
        return items
            .map(
              (item) => PopupMenuItem(
                  onTap: () => item.onPressed.call(),
                  child: Row(
                    children: [
                      if (item.icon != null) Icon(item.icon),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(item.label),
                    ],
                  )),
            )
            .toList();
      },
      position: PopupMenuPosition.under,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            if (icon != null) Icon(icon),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}
