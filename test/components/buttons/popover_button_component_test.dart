// Créez des mocks pour les fonctions de rappel
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:x_video_ai/components/buttons/popover_button_component.dart';

class MockCallback extends Mock {
  void call();
}

void main() {
  testWidgets('PopoverButtonComponent displays items and triggers callbacks',
      (WidgetTester tester) async {
    // Arrange
    final mockCallback1 = MockCallback();
    final mockCallback2 = MockCallback();

    final items = [
      ItemPopoverButtonComponent(
        label: 'Item 1',
        onPressed: mockCallback1.call,
        icon: Icons.star,
      ),
      ItemPopoverButtonComponent(
        label: 'Item 2',
        onPressed: mockCallback2.call,
        icon: Icons.settings,
      ),
    ];

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PopoverButtonComponent(
            label: 'Open Menu',
            items: items,
            icon: Icons.menu,
          ),
        ),
      ),
    );

    // Ouvrez le PopupMenuButton
    await tester.tap(find.byType(PopupMenuButton));
    await tester.pumpAndSettle(); // Attendez l'animation du menu

    // Assert: Vérifiez que les éléments sont affichés
    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 2'), findsOneWidget);

    // Sélectionnez le premier élément du menu
    await tester.tap(find.text('Item 1'));
    await tester.pumpAndSettle(); // Attendez la fermeture du menu

    // Vérifiez que le rappel correspondant a été appelé
    verify(mockCallback1.call()).called(1);

    // Répétez pour le deuxième élément
    await tester.tap(find.byType(PopupMenuButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Item 2'));
    await tester.pumpAndSettle();

    verify(mockCallback2.call()).called(1);
  });
}
