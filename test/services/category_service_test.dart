import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:x_video_ai/gateway/file_getaway.dart';
import 'package:x_video_ai/models/category_model.dart';
import 'package:x_video_ai/services/category_service.dart';

import 'content_service_test.mocks.dart';

@GenerateMocks([FileGateway])
void main() {
  late MockFileGateway mockFileGateway;
  late MockFileWrapper mockFileWrapper;
  late CategoryService categoryService;

  setUp(() {
    mockFileGateway = MockFileGateway();
    mockFileWrapper = MockFileWrapper();
    categoryService = CategoryService(mockFileGateway);
  });

  group('CategoryService', () {
    test('getCategories returns empty list if file does not exist', () async {
      // Configurer le mock pour renvoyer false lorsque file.existsSync() est appelé
      when(mockFileGateway.getFile(any)).thenReturn(mockFileWrapper);
      when(mockFileWrapper.existsSync()).thenReturn(false);

      // Appeler la méthode getCategories
      final categories = await categoryService.getCategories('/test/project');

      // Vérifier que la liste est vide
      expect(categories, isEmpty);
    });

    test('getCategories returns list of categories if file exists', () async {
      final categoriesJson = jsonEncode([
        {'name': 'Category1', 'keywords': [], 'videos': []},
        {'name': 'Category2', 'keywords': [], 'videos': []},
      ]);

      // Configurer le mock pour renvoyer true et une chaîne JSON valide
      when(mockFileGateway.getFile(any)).thenReturn(mockFileWrapper);
      when(mockFileWrapper.existsSync()).thenReturn(true);
      when(mockFileWrapper.readAsStringSync()).thenReturn(categoriesJson);

      // Appeler la méthode getCategories
      final categories = await categoryService.getCategories('/test/project');

      // Vérifier que deux catégories ont été chargées
      expect(categories, hasLength(2));
      expect(categories.first.name, equals('Category1'));
    });

    test('addCategory adds a category to the list and writes to file',
        () async {
      final category =
          CategoryModel(name: 'NewCategory', keywords: [], videos: []);
      final existingCategoriesJson = jsonEncode([
        {'name': 'ExistingCategory', 'keywords': [], 'videos': []},
      ]);

      // Configurer le mock pour renvoyer des catégories existantes
      when(mockFileGateway.getFile(any)).thenReturn(mockFileWrapper);
      when(mockFileWrapper.existsSync()).thenReturn(true);
      when(mockFileWrapper.readAsStringSync())
          .thenReturn(existingCategoriesJson);

      // Appeler la méthode addCategory
      await categoryService.addCategory(category, '/test/project');

      // Vérifier que writeAsStringSync a été appelé avec la nouvelle liste de catégories
      verify(mockFileWrapper
              .writeAsStringSync(argThat(contains('NewCategory'))))
          .called(1);
    });

    test('updateCategory updates a category and writes to file', () async {
      final updatedCategory = CategoryModel(
        name: 'Category1',
        keywords: ['updated'],
        videos: [],
      );

      final existingCategoriesJson = jsonEncode([
        {'name': 'Category1', 'keywords': [], 'videos': []},
        {'name': 'Category2', 'keywords': [], 'videos': []},
      ]);

      // Configurer le mock pour renvoyer des catégories existantes
      when(mockFileGateway.getFile(any)).thenReturn(mockFileWrapper);
      when(mockFileWrapper.existsSync()).thenReturn(true);
      when(mockFileWrapper.readAsStringSync())
          .thenReturn(existingCategoriesJson);

      // Appeler la méthode updateCategory
      await categoryService.updateCategory(updatedCategory, '/test/project');

      // La chaîne JSON attendue après mise à jour
      final updatedCategoriesJson = jsonEncode([
        {
          'name': 'Category1',
          'keywords': ['updated'],
          'videos': []
        },
        {'name': 'Category2', 'keywords': [], 'videos': []},
      ]);

      // Vérifier que la catégorie a été mise à jour et écrite dans le fichier
      verify(mockFileWrapper.writeAsStringSync(updatedCategoriesJson))
          .called(1);
    });
  });
}
