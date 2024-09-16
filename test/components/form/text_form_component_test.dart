import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_video_ai/components/form/text_form_component.dart';

void main() {
  // Crée un widget testable avec Riverpod
  Widget createTestableWidget(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(body: child),
      ),
    );
  }

  testWidgets('TextFormComponent affiche la valeur initiale correctement',
      (WidgetTester tester) async {
    // Crée le widget avec une valeur initiale
    await tester.pumpWidget(
      createTestableWidget(
        const TextFormComponent(
          initialValue: 'Hello World',
        ),
      ),
    );

    // Vérifie que la valeur initiale est affichée
    expect(find.text('Hello World'), findsOneWidget);
  });

  testWidgets('TextFormComponent appelle onChanged lorsque le texte change',
      (WidgetTester tester) async {
    String? changedText;

    // Crée le widget avec un callback onChanged
    await tester.pumpWidget(
      createTestableWidget(
        TextFormComponent(
          onChanged: (value) {
            changedText = value;
          },
        ),
      ),
    );

    // Saisit du texte
    await tester.enterText(find.byType(TextField), 'Flutter');
    await tester.pump();

    // Vérifie que onChanged est appelé avec la bonne valeur
    expect(changedText, 'Flutter');
  });

  testWidgets(
      'TextFormComponent masque le texte lorsque obscureText est défini à true',
      (WidgetTester tester) async {
    // Crée le widget avec obscureText à true
    await tester.pumpWidget(
      createTestableWidget(
        const TextFormComponent(
          obscureText: true,
        ),
      ),
    );

    // Saisit du texte
    await tester.enterText(find.byType(TextField), 'Password');
    await tester.pump();

    // Vérifie que le texte est masqué
    TextField textField = tester.widget(find.byType(TextField));
    expect(textField.obscureText, isTrue);
  });

  testWidgets('TextFormComponent ne masque pas le texte par défaut',
      (WidgetTester tester) async {
    // Crée le widget sans obscureText (par défaut false)
    await tester.pumpWidget(
      createTestableWidget(
        const TextFormComponent(),
      ),
    );

    // Saisit du texte
    await tester.enterText(find.byType(TextField), 'NormalText');
    await tester.pump();

    // Vérifie que le texte n'est pas masqué
    TextField textField = tester.widget(find.byType(TextField));
    expect(textField.obscureText, isFalse);
  });

  testWidgets(
      'TextFormComponent permet plusieurs lignes lorsque isTextArea est vrai',
      (WidgetTester tester) async {
    // Crée le widget avec isTextArea défini à true
    await tester.pumpWidget(
      createTestableWidget(
        const TextFormComponent(
          isTextArea: true,
        ),
      ),
    );

    // Vérifie que le champ permet plusieurs lignes
    TextField textField = tester.widget(find.byType(TextField));
    expect(textField.maxLines,
        isNull); // maxLines null permet un nombre illimité de lignes
  });

  testWidgets(
      'TextFormComponent limite à une seule ligne lorsque isTextArea est faux',
      (WidgetTester tester) async {
    // Crée le widget avec isTextArea défini à false (par défaut)
    await tester.pumpWidget(
      createTestableWidget(
        const TextFormComponent(),
      ),
    );

    // Vérifie que le champ est limité à une seule ligne
    TextField textField = tester.widget(find.byType(TextField));
    expect(
        textField.maxLines, 1); // maxLines est 1 pour un champ de texte normal
  });
}
