import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/content_controller.dart';
import 'package:x_video_ai/models/category_model.dart';
import 'package:x_video_ai/models/video_section_model.dart';
import 'package:x_video_ai/services/category_service.dart';

enum CategoryContainer { idle, notInCategory, inCategory }

class CategoryListController extends StateNotifier<Map<String, dynamic>> {
  final CategoryService _categoryService;
  final ContentController _contentController;

  CategoryListController(
    CategoryService categoryService,
    ContentController contentController,
  )   : _categoryService = categoryService,
        _contentController = contentController,
        super({
          "categories": [],
          "isInCategories": CategoryContainer.idle,
          "section": null,
          "key": null,
        });

  List<CategoryModel> get categories =>
      List<CategoryModel>.from(state["categories"]);
  CategoryContainer get isInCategories => state["isInCategories"];
  Key? get key => state["key"];

  VideoSectionModel? get section => state["section"];

  Future<void> loadCategories() async {
    final String projectPath = _contentController.state.path;

    try {
      final List<CategoryModel> categories =
          await _categoryService.getCategories(projectPath);
      categories.sort((a, b) => a.name.compareTo(b.name));
      state = {
        ...state,
        "categories": categories,
      };
    } catch (e) {
      state = {
        ...state,
        "categories": [],
      };
    }
  }

  void keywordIsInCategory(
    Key key,
    VideoSectionModel section,
  ) {
    final List<CategoryModel> categories = List<CategoryModel>.from(
      state["categories"],
    );
    final bool isInCategories = categories.any(
      (category) => category.keywords.contains(section.keyword),
    );

    state = {
      ...state,
      "isInCategories": isInCategories
          ? CategoryContainer.inCategory
          : CategoryContainer.notInCategory,
      "section": section,
      "key": key,
    };
  }

  void resetKeywordIsInCategory() {
    state = {
      ...state,
      "isInCategories": CategoryContainer.idle,
      "section": null,
      "key": null,
    };
  }
}

final categoryListControllerProvider =
    StateNotifierProvider<CategoryListController, Map<String, dynamic>>(
  (ref) => CategoryListController(
    CategoryService(),
    ref.read(contentControllerProvider.notifier),
  ),
);
