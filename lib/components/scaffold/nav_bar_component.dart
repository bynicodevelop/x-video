import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/components/scaffold/nav_bar_item_component.dart';

class NavBarComponent extends ConsumerWidget {
  final List<NavbarItemComponent> items;
  final double gap;

  const NavBarComponent({
    required this.items,
    this.gap = 22,
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 24,
        horizontal: 8,
      ),
      constraints: const BoxConstraints(
        minWidth: 60,
      ),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.5),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            items[i],
            if (i < items.length - 1) SizedBox(height: gap),
          ],
        ],
      ),
    );
  }
}
