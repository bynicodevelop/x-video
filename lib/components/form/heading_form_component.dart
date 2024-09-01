import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HeadingFormComponent extends ConsumerWidget {
  final String label;

  const HeadingFormComponent({
    required this.label,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 20,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Divider(
            color: Theme.of(context).dividerColor.withOpacity(
                  0.2,
                ),
          )
        ],
      ),
    );
  }
}
