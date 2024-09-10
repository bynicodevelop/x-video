import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_video_ai/elements/files/dropzone_element.dart';

void main() {
  group('DropzoneElement Tests', () {
    testWidgets('DropzoneElement shows correct initial state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: DropzoneElement(
              builder: (context, params) {
                return Text(params.dragging ? 'Dragging' : 'Not Dragging');
              },
              onFile: (files) {},
            ),
          ),
        ),
      );

      expect(find.text('Not Dragging'), findsOneWidget);
      expect(find.text('Dragging'), findsNothing);
    });
  });
}
