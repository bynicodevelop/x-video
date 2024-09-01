import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:x_video_ai/components/buttons/text_button_component.dart';

class MockCallback extends Mock {
  void call();
}

void main() {
  testWidgets('TextButtonComponent displays text and icon',
      (WidgetTester tester) async {
    // Arrange
    final mockCallback = MockCallback();

    // Act
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: TextButtonComponent(
              text: 'Press me',
              icon: Icons.add,
              onPressed: mockCallback.call,
            ),
          ),
        ),
      ),
    );

    // Assert
    expect(find.text('Press me'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('TextButtonComponent calls onPressed when tapped',
      (WidgetTester tester) async {
    // Arrange
    final mockCallback = MockCallback();

    // Act
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: TextButtonComponent(
              text: 'Press me',
              onPressed: mockCallback.call,
            ),
          ),
        ),
      ),
    );

    // Appuyez sur le bouton
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    // Assert
    verify(mockCallback()).called(1);
  });

  testWidgets('TextButtonComponent displays only text when no icon is provided',
      (WidgetTester tester) async {
    // Act
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: TextButtonComponent(
              text: 'Press me',
              onPressed: () {},
            ),
          ),
        ),
      ),
    );

    // Assert
    expect(find.text('Press me'), findsOneWidget);
    expect(find.byType(Icon), findsNothing);
  });

  testWidgets('TextButtonComponent is disabled when onPressed is null',
      (WidgetTester tester) async {
    // Act
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: TextButtonComponent(
              text: 'Press me',
              onPressed: null,
            ),
          ),
        ),
      ),
    );

    // Appuyez sur le bouton
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    // Assert: Le rappel ne devrait pas être appelé car onPressed est null
    expect(find.byType(TextButton), findsOneWidget);
    verifyNever(MockCallback().call());
  });
}
