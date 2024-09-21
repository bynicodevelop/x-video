import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ListElement<T> extends ConsumerStatefulWidget {
  final List<T> elements;
  final Function(T) onTap;
  final String Function(T) formatter;
  final int selectedIndex;

  const ListElement({
    required this.elements,
    required this.onTap,
    required this.formatter,
    required this.selectedIndex,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CategoriesListElementState<T>();
}

class _CategoriesListElementState<T> extends ConsumerState<ListElement<T>> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.elements.length,
      itemBuilder: (context, index) {
        final element = widget.elements[index];

        return ListTile(
          selected: index == widget.selectedIndex,
          title: Text(widget.formatter(element)),
          onTap: () => widget.onTap(element),
        );
      },
    );
  }
}
