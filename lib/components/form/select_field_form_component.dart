import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectFormComponent<T> extends ConsumerWidget {
  final void Function(T)? onChanged;
  final String? initialValue;
  final TextEditingController? controller;
  final List<T> items;

  const SelectFormComponent({
    required this.items,
    this.onChanged,
    this.controller,
    this.initialValue,
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    T? selectedValue = initialValue != null && items.contains(initialValue as T)
        ? initialValue as T
        : null;

    return DropdownButtonFormField<T>(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.all(14),
      ),
      value: selectedValue,
      onChanged: (value) {
        if (onChanged != null) {
          onChanged!(value as T);
        }
      },
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(item.toString()),
            ),
          )
          .toList(),
    );
  }
}
