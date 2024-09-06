// ignore: depend_on_referenced_packages
import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_video_ai/screens/views/editor/video/vignette_reader.dart';

void main() {
  testWidgets('should display correct UI when no file is dragged',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: VignetteReaderVideoEditor(),
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
      const ProviderScope(
        child: MaterialApp(
          home: VignetteReaderVideoEditor(),
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

  testWidgets('should call onFileDropped when file is dropped',
      (WidgetTester tester) async {
    XFile? file;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: VignetteReaderVideoEditor(
            onFileDropped: (XFile f) {
              file = f;
            },
          ),
        ),
      ),
    );

    // Drag file
    final gesture = await tester.startGesture(const Offset(100, 100));

    // Déplacer l'élément au-dessus de la cible (DropTarget)
    await gesture.moveTo(const Offset(150, 150));

    // Simuler la fin du geste (drop)
    await gesture.up();

    final testFile = XFile('test_video.mp4');
    final dropTargetFinder = find.byType(DropTarget);
    final dropTargetWidget = tester.widget<DropTarget>(dropTargetFinder);

    dropTargetWidget.onDragDone!(
      DropDoneDetails(
          files: [testFile],
          localPosition: Offset.zero,
          globalPosition: Offset.zero),
    );

    await tester.pump();

    // Vérifier que le fichier a été déposé
    expect(file, testFile);
    expect(file!.path, 'test_video.mp4');
  });
}
