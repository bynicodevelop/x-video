import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScaffoldFieldFormComponent extends ConsumerWidget {
  final String label;
  final Widget field;
  final Widget? suffix;
  final bool labelCenter;

  const ScaffoldFieldFormComponent({
    required this.label,
    required this.field,
    this.suffix,
    this.labelCenter = true,
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment:
            labelCenter ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: Text(
              '$label :',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          Expanded(
            child: field,
          ),
          if (suffix != null)
            const SizedBox(
              width: 6,
            ),
          if (suffix != null) suffix!,
        ],
      ),
    );
  }
}
