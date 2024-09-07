import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_video_ai/models/video_section_model.dart';
import 'package:x_video_ai/screens/views/editor/video/vignette_reader.dart';

void main() {
  testWidgets('should display correct UI when no file is dragged',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: VignetteReaderVideoEditor(
            section: VideoSectionModel.fromJson({
              'sentence': 'sentence',
              'keyword': 'keyword',
              'start': 0.0,
              'end': 0.0,
              'duration': 0.0,
              'file': null,
            }),
          ),
        ),
      ),
    );

    // Vérifier que le widget par défaut est affiché
    final uploadButton = find.byIcon(Icons.file_upload_outlined);
    expect(uploadButton, findsOneWidget);

    final container = find.byType(Container);
    expect(container, findsOneWidget);
  });

  testWidgets('should display correct UI when file is dragged',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: VignetteReaderVideoEditor(
            section: VideoSectionModel.fromJson({
              'sentence': 'sentence',
              'keyword': 'keyword',
              'start': 0.0,
              'end': 0.0,
              'duration': 0.0,
              'file': null,
            }),
          ),
        ),
      ),
    );

    // Vérifier que le widget par défaut est affiché
    final uploadButton = find.byIcon(Icons.file_upload_outlined);
    expect(uploadButton, findsOneWidget);

    final container = find.byType(Container);
    expect(container, findsOneWidget);

    // Drag file
    await tester.drag(find.byType(Container), const Offset(0, 100));

    // Vérifier que le widget par défaut est affiché
    final uploadButtonAfterDrag = find.byIcon(Icons.file_upload_outlined);
    expect(uploadButtonAfterDrag, findsOneWidget);

    final containerAfterDrag = find.byType(Container);
    expect(containerAfterDrag, findsOneWidget);
  });
}
