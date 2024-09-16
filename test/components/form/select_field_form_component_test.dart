import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_video_ai/components/form/select_field_form_component.dart';

void main() {
  // Crée un widget testable avec Riverpod
  Widget createTestableWidget(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(body: child),
      ),
    );
  }

  testWidgets('SelectFormComponent affiche correctement la valeur initiale',
      (WidgetTester tester) async {
    // Les éléments de la dropdown
    final items = ['alloy', 'echo', 'fable', 'onyx'];

    // Crée le widget avec une valeur initiale
    await tester.pumpWidget(
      createTestableWidget(
        SelectFormComponent<String>(
          items: items,
          initialValue: 'echo',
        ),
      ),
    );

    // Vérifie si le Dropdown affiche la valeur initiale correctement
    expect(find.text('echo'), findsOneWidget);
  });

  testWidgets('SelectFormComponent affiche tous les items dans la dropdown',
      (WidgetTester tester) async {
    // Les éléments de la dropdown
    final items = ['alloy', 'echo', 'fable', 'onyx'];

    // Crée le widget sans valeur initiale
    await tester.pumpWidget(
      createTestableWidget(
        SelectFormComponent<String>(
          items: items,
        ),
      ),
    );

    // Ouvre la Dropdown
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    // Vérifie si tous les items sont affichés
    for (var item in items) {
      expect(find.text(item), findsOneWidget);
    }
  });

  testWidgets(
      'SelectFormComponent appelle le callback onChanged lorsque la sélection change',
      (WidgetTester tester) async {
    // Les éléments de la dropdown
    final items = ['alloy', 'echo', 'fable', 'onyx'];

    String? selectedValue;

    // Crée le widget avec un callback
    await tester.pumpWidget(
      createTestableWidget(
        SelectFormComponent<String>(
          items: items,
          onChanged: (value) {
            selectedValue = value;
          },
        ),
      ),
    );

    // Ouvre la Dropdown
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    // Sélectionne un nouvel item
    await tester.tap(find.text('fable').last);
    await tester.pumpAndSettle();

    // Vérifie que le callback a été appelé avec la bonne valeur
    expect(selectedValue, 'fable');
  });

  testWidgets(
      'SelectFormComponent ne sélectionne aucun item si initialValue n\'est pas dans la liste',
      (WidgetTester tester) async {
    // Les éléments de la dropdown
    final items = ['alloy', 'echo', 'fable', 'onyx'];

    // Crée le widget avec une valeur initiale inexistante
    await tester.pumpWidget(
      createTestableWidget(
        SelectFormComponent<String>(
          items: items,
          initialValue: 'inexistant',
        ),
      ),
    );

    // Ouvre la Dropdown
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    // Vérifie qu'aucun item n'est sélectionné par défaut
    expect(find.text('inexistant'), findsNothing);
  });
}
