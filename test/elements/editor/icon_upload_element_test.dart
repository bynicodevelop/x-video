import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_video_ai/elements/editor/icon_upload_element.dart';
import 'package:x_video_ai/screens/views/editor/video/vignette_reader_controller.dart';

void main() {
  group('IconUploadEditorElement Tests', () {
    testWidgets('Displays correct icon based on status',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home:
                IconUploadEditorElement(status: VignetteReaderStatus.uploading),
          ),
        ),
      );

      expect(find.byIcon(Icons.upload_file), findsOneWidget);
    });

    testWidgets('Displays correct color when dragging',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: IconUploadEditorElement(isDragging: true),
          ),
        ),
      );

      final icon =
          tester.widget<IconButton>(find.byType(IconButton)).icon as Icon;
      expect(icon.color, Colors.blue.shade400);
    });

    testWidgets('Displays correct color when has thumbnail',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: IconUploadEditorElement(hasThumbnail: true),
          ),
        ),
      );

      final icon =
          tester.widget<IconButton>(find.byType(IconButton)).icon as Icon;
      expect(icon.color, Colors.white);
    });

    testWidgets('Displays correct color when not dragging and no thumbnail',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: IconUploadEditorElement(),
          ),
        ),
      );

      final icon =
          tester.widget<IconButton>(find.byType(IconButton)).icon as Icon;
      expect(icon.color, Colors.grey.shade400);
    });

    testWidgets('Calls onCompleted when icon is pressed',
        (WidgetTester tester) async {
      bool completed = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: IconUploadEditorElement(
              onCompleted: () {
                completed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(IconButton));
      expect(completed, isTrue);
    });

    testWidgets('Displays error icon when status is error',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: IconUploadEditorElement(status: VignetteReaderStatus.error),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('Displays default icon when status is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: IconUploadEditorElement(),
          ),
        ),
      );

      expect(find.byIcon(Icons.hourglass_top_outlined), findsOneWidget);
    });
  });
}
