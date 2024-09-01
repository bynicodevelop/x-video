import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_video_ai/components/form/heading_form_component.dart';

void main() {
  testWidgets('HeadingFormComponent displays the correct label text',
      (WidgetTester tester) async {
    // Arrange
    const testLabel = 'Test Label';

    // Act
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: HeadingFormComponent(
              label: testLabel,
            ),
          ),
        ),
      ),
    );

    // Assert
    expect(find.text(testLabel), findsOneWidget);
  });
}
