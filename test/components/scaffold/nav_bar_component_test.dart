import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:x_video_ai/components/scaffold/nav_bar_item_component.dart';

class MockCallback extends Mock {
  void call();
}

void main() {
  testWidgets('NavbarItemComponent renders icon and label correctly',
      (WidgetTester tester) async {
    // Arrange
    const testIcon = Icons.home;
    const testLabel = 'Home';

    // Act
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: NavbarItemComponent(
              icon: testIcon,
              label: testLabel,
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    // Assert
    expect(find.byIcon(testIcon), findsOneWidget);
    expect(find.text(testLabel), findsOneWidget);
  });

  testWidgets('NavbarItemComponent calls onTap when tapped',
      (WidgetTester tester) async {
    // Arrange
    const testIcon = Icons.home;
    const testLabel = 'Home';
    final mockOnTap = MockCallback();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: NavbarItemComponent(
              icon: testIcon,
              label: testLabel,
              onTap: mockOnTap.call,
            ),
          ),
        ),
      ),
    );

    // Act
    await tester.tap(find.byIcon(testIcon));
    await tester.pump();

    // Assert
    verify(mockOnTap()).called(1);
  });
}
