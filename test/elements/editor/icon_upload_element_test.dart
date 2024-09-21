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
