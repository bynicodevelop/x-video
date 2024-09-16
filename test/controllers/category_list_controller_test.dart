import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:x_video_ai/controllers/category_list_controller.dart';
import 'package:x_video_ai/controllers/content_controller.dart';
import 'package:x_video_ai/models/category_model.dart';
import 'package:x_video_ai/models/content_model.dart';
import 'package:x_video_ai/models/video_section_model.dart';
import 'package:x_video_ai/services/category_service.dart';

import 'category_list_controller_test.mocks.dart';

@GenerateMocks([CategoryService, ContentController])
void main() {
  late MockCategoryService mockCategoryService;
  late MockContentController mockContentController;
  late ProviderContainer container;

  setUp(() {
    // Initialiser les mocks
    mockCategoryService = MockCategoryService();
    mockContentController = MockContentController();

    // Simuler un chemin de projet dans le ContentController
    when(mockContentController.state).thenReturn(ContentModel(
      path: '/testProjectPath',
      id: '1',
      name: 'TestProject',
      content: null,
      chronical: null,
      audio: null,
      srt: null,
      srtWithGroup: null,
      assContent: null,
      sections: null,
    ));

    // Créer un ProviderContainer pour tester avec les overrides
    container = ProviderContainer(
      overrides: [
        categoryListControllerProvider.overrideWith(
          (ref) => CategoryListController(
            mockCategoryService,
            mockContentController,
          ),
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('should load and sort categories alphabetically', () async {
    // Simuler les catégories à retourner par le service
    final List<CategoryModel> mockCategories = [
      CategoryModel(name: 'Zebra', keywords: [], videos: []),
      CategoryModel(name: 'Apple', keywords: [], videos: []),
      CategoryModel(name: 'Banana', keywords: [], videos: []),
    ];

    when(mockCategoryService.getCategories(any))
        .thenAnswer((_) async => mockCategories);

    // Appeler la méthode loadCategories
    await container
        .read(categoryListControllerProvider.notifier)
        .loadCategories();

    // Vérifier que les catégories sont chargées et triées par ordre alphabétique
    final List<CategoryModel> categories = List<CategoryModel>.from(
      container.read(categoryListControllerProvider),
    );
    expect(categories.length, equals(3));
    expect(categories[0].name, equals('Apple'));
    expect(categories[1].name, equals('Banana'));
    expect(categories[2].name, equals('Zebra'));

    // Vérifier que le service a été appelé avec le bon chemin de projet
    verify(mockCategoryService.getCategories('/testProjectPath')).called(1);
  });

  test('should handle empty category list', () async {
    // Simuler un retour vide par le service de catégories
    when(mockCategoryService.getCategories(any)).thenAnswer((_) async => []);

    // Appeler la méthode loadCategories
    await container
        .read(categoryListControllerProvider.notifier)
        .loadCategories();

    // Vérifier que la liste des catégories est vide
    final List<CategoryModel> categories = List<CategoryModel>.from(
      container.read(categoryListControllerProvider),
    );
    expect(categories.length, equals(0));

    // Vérifier que le service a été appelé avec le bon chemin de projet
    verify(mockCategoryService.getCategories('/testProjectPath')).called(1);
  });

  test('should not throw error when service fails', () async {
    // Simuler une erreur lors de l'appel au service
    when(mockCategoryService.getCategories(any))
        .thenThrow(Exception('Service failed'));

    // Appeler la méthode loadCategories et vérifier qu'il n'y a pas d'erreur
    expect(
      () async => await container
          .read(categoryListControllerProvider.notifier)
          .loadCategories(),
      returnsNormally,
    );

    // Vérifier que la liste des catégories est restée vide
    final List<CategoryModel> categories = List<CategoryModel>.from(
      container.read(categoryListControllerProvider),
    );
    expect(categories.isEmpty, isTrue);

    // Vérifier que le service a été appelé avec le bon chemin de projet
    verify(mockCategoryService.getCategories('/testProjectPath')).called(1);
  });

  test('should find category by keyword', () async {
    // Simuler les catégories à retourner par le service
    final List<CategoryModel> mockCategories = [
      CategoryModel(name: 'Fruits', keywords: ['apple', 'banana'], videos: []),
      CategoryModel(name: 'Animals', keywords: ['zebra'], videos: []),
    ];

    when(mockCategoryService.getCategories(any))
        .thenAnswer((_) async => mockCategories);

    // Appeler la méthode loadCategories
    await container
        .read(categoryListControllerProvider.notifier)
        .loadCategories();

    // Créer une section de vidéo avec un mot-clé correspondant
    final section = VideoSectionModel(
      id: '1',
      sentence: 'Test sentence',
      duration: 120.0,
      fileName: 'testVideo',
      keyword: 'apple',
      start: 0.0,
      end: 120.0,
    );

    // Appeler la méthode keywordIsInCategory
    final CategoryModel? category = container
        .read(categoryListControllerProvider.notifier)
        .keywordIsInCategory(section);

    // Vérifier que la catégorie correspondant au mot-clé est retournée
    expect(category!.name, equals('Fruits'));
  });
}
