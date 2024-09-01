import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:x_video_ai/components/buttons/icon_button_component.dart';

// Mock Function
class MockFunction extends Mock {
  void call();
}

void main() {
  testWidgets('IconButtonCompoent displays the correct icon and handles hover',
      (WidgetTester tester) async {
    // Arrange
    const testIcon = Icons.home;

    // Act
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: IconButtonComponent(
              icon: testIcon,
              onPressed: () {},
            ),
          ),
        ),
      ),
    );

    // Assert initial state
    expect(find.byIcon(testIcon), findsOneWidget);
    final iconButton = tester.widget<IconButton>(find.byType(IconButton));
    expect(iconButton.color, Colors.grey.shade500);

    // Simulate mouse hover
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);

    // Assert hover effect
    final hoveredIconButton =
        tester.widget<IconButton>(find.byType(IconButton));
    expect(hoveredIconButton.color, const Color(0xff9e9e9e));
  });

  testWidgets('IconButtonCompoent calls onPressed when tapped',
      (WidgetTester tester) async {
    // Arrange
    final mockOnPressed = MockFunction();
    const testIcon = Icons.home;

    // Act
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: IconButtonComponent(
              icon: testIcon,
              onPressed: mockOnPressed.call,
            ),
          ),
        ),
      ),
    );

    // Simulate button press
    await tester.tap(find.byType(IconButton));
    await tester.pump();

    // Assert that the onPressed callback is called
    verify(mockOnPressed()).called(1);
  });

  testWidgets('IconButtonCompoent should not call onPressed if it is null',
      (WidgetTester tester) async {
    // Arrange
    const testIcon = Icons.home;

    // Act
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: IconButtonComponent(
              icon: testIcon,
              onPressed: null, // onPressed is null
            ),
          ),
        ),
      ),
    );

    // Simulate button press
    await tester.tap(find.byType(IconButton));
    await tester.pump();

    // Assert that nothing happens (no exception)
    // If onPressed is null, there should be no action triggered.
    expect(tester.takeException(), isNull);
  });
}
