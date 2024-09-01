import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:x_video_ai/components/scaffold/nav_bar_item_component.dart';

// MockFunction
class MockFunction extends Mock {
  void call();
}

void main() {
  testWidgets('NavbarItemComponent displays icon and label',
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
    final mockOnTap = MockFunction();

    // Act
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

    await tester.tap(find.byIcon(testIcon));
    await tester.pump();

    // Assert
    verify(mockOnTap()).called(1);
  });

  testWidgets('NavbarItemComponent changes color when selected',
      (WidgetTester tester) async {
    // Arrange
    const testIcon = Icons.home;
    const testLabel = 'Home';
    const selectedColor = Colors.blue;
    const unselectedColor = Colors.grey;

    // Act
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: selectedColor,
              secondary: unselectedColor,
            ),
          ),
          home: Scaffold(
            body: NavbarItemComponent(
              icon: testIcon,
              label: testLabel,
              selected: true,
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    // Assert
    final iconFinder = find.byIcon(testIcon);
    final textFinder = find.text(testLabel);

    final iconWidget = tester.widget<Icon>(iconFinder);
    final textWidget = tester.widget<Text>(textFinder);

    // Check if the icon and text have the selected color
    expect(iconWidget.color, equals(selectedColor));
    expect(textWidget.style?.color, equals(selectedColor));
  });

  testWidgets('NavbarItemComponent uses secondary color when not selected',
      (WidgetTester tester) async {
    // Arrange
    const testIcon = Icons.home;
    const testLabel = 'Home';
    const selectedColor = Colors.blue;
    const unselectedColor = Colors.grey;

    // Act
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: selectedColor,
              secondary: unselectedColor,
            ),
          ),
          home: Scaffold(
            body: NavbarItemComponent(
              icon: testIcon,
              label: testLabel,
              selected: false,
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    // Assert
    final iconFinder = find.byIcon(testIcon);
    final textFinder = find.text(testLabel);

    final iconWidget = tester.widget<Icon>(iconFinder);
    final textWidget = tester.widget<Text>(textFinder);

    // Check if the icon and text have the unselected color
    expect(iconWidget.color, equals(unselectedColor));
    expect(textWidget.style?.color, equals(unselectedColor));
  });
}
