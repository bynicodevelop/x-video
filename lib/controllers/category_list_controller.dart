import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/content_controller.dart';
import 'package:x_video_ai/gateway/file_getaway.dart';
import 'package:x_video_ai/models/category_model.dart';
import 'package:x_video_ai/models/video_section_model.dart';
import 'package:x_video_ai/services/category_service.dart';

class CategoryListController extends StateNotifier<List<CategoryModel>> {
  final CategoryService _categoryService;
  final ContentController _contentController;

  CategoryListController(
    CategoryService categoryService,
    ContentController contentController,
  )   : _categoryService = categoryService,
        _contentController = contentController,
        super([]);

  List<CategoryModel> get categories => state;

  Future<void> loadCategories() async {
    final String projectPath = _contentController.state.path;

    try {
      final List<CategoryModel> categories =
          await _categoryService.getCategories(projectPath);
      categories.sort((a, b) => a.name.compareTo(b.name));

      state = categories;
    } catch (e) {
      state = [];
    }
  }

  CategoryModel? keywordIsInCategory(
    VideoSectionModel section,
  ) {
    final List<CategoryModel> categories = state
        .where(
          (category) => category.keywords.contains(section.keyword),
        )
        .toList();

    if (categories.isEmpty) {
      return null;
    }

    return categories.first;
  }
}

final categoryListControllerProvider =
    StateNotifierProvider<CategoryListController, List<CategoryModel>>(
  (ref) => CategoryListController(
    CategoryService(
      FileGateway(),
    ),
    ref.read(contentControllerProvider.notifier),
  ),
);
