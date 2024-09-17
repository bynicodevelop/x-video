import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/elements/lists/list_element.dart';

void main() {
  group('ListElement', () {
    testWidgets('displays all elements', (WidgetTester tester) async {
      final elements = ['Element 1', 'Element 2', 'Element 3'];
      formatter(String element) => element;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ListElement<String>(
                elements: elements,
                onTap: (_) {},
                formatter: formatter,
              ),
            ),
          ),
        ),
      );

      for (final element in elements) {
        expect(find.text(element), findsOneWidget);
      }
    });

    testWidgets('calls onTap when an element is tapped',
        (WidgetTester tester) async {
      final elements = ['Element 1', 'Element 2', 'Element 3'];
      formatter(String element) => element;
      String? tappedElement;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ListElement<String>(
                elements: elements,
                onTap: (element) {
                  tappedElement = element;
                },
                formatter: formatter,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Element 2'));
      await tester.pump();

      expect(tappedElement, 'Element 2');
    });
  });
}
