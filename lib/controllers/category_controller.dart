import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/category_list_controller.dart';
import 'package:x_video_ai/controllers/content_controller.dart';
import 'package:x_video_ai/models/category_model.dart';
import 'package:x_video_ai/services/category_service.dart';

class CategoryController extends StateNotifier<CategoryModel?> {
  final CategoryService _categoryService;
  final ContentController _contentController;
  final CategoryListController _categoryListController;

  CategoryController(
    CategoryService categoryService,
    ContentController contentController,
    CategoryListController categoryListController,
  )   : _categoryService = categoryService,
        _contentController = contentController,
        _categoryListController = categoryListController,
        super(null);

  Future<void> loadCategory(String name) async {
    CategoryModel category = _categoryListController.categories.firstWhere(
      (category) => category.name == name,
      orElse: () => CategoryModel(
        name: name,
        keywords: [],
        videos: [],
      ),
    );

    if (category.name.isEmpty) {
      throw Exception("Category not found");
    }

    state = category;
  }

  Future<CategoryModel> createCategory(String name) async {
    state = CategoryModel(
      name: name,
      keywords: [],
      videos: [],
    );

    final String projectPath = _contentController.state.path;

    await _categoryService.addCategory(
      state!,
      projectPath,
    );

    return state!;
  }

  void addVideo(String videoId) {
    state = state!.mergeWith({
      "videos": [
        ...{...state!.videos, videoId}
      ],
    });
  }

  void addKeyword(String keyword) {
    state = state!.mergeWith({
      "keywords": [
        ...{...state!.keywords, keyword}
      ],
    });
  }

  void save() {
    final String projectPath = _contentController.state.path;

    _categoryService.updateCategory(
      state!,
      projectPath,
    );
  }
}

final categoryControllerProvider =
    StateNotifierProvider<CategoryController, CategoryModel?>(
  (ref) => CategoryController(
    CategoryService(),
    ref.read(contentControllerProvider.notifier),
    ref.read(categoryListControllerProvider.notifier),
  ),
);
