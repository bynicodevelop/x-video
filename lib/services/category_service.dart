import 'dart:convert';
import 'dart:io';

import 'package:x_video_ai/models/category_model.dart';
import 'package:x_video_ai/services/abstracts/file_service.dart';

class CategoryService extends FileService {
  final String _categoriesFile = 'categories.json';

  File _getCategoriesFile(String projectPath) {
    final String categoriesPath = '$projectPath/$_categoriesFile';
    return File(categoriesPath);
  }

  List<CategoryModel> _readCategories(String projectPath) {
    final File file = _getCategoriesFile(projectPath);

    if (file.existsSync()) {
      final String categoriesString = file.readAsStringSync();
      final List<dynamic> categoriesJson = jsonDecode(categoriesString);

      final List<CategoryModel> categories = categoriesJson
          .map((category) => CategoryModel.factory(category))
          .toList();

      return categories;
    } else {
      return [];
    }
  }

  Future<void> _writeCategories(
    List<CategoryModel> categories,
    String projectPath,
  ) async {
    final File file = _getCategoriesFile(projectPath);

    await createDirectory(
      projectPath,
    );

    final List<dynamic> categoriesJson =
        categories.map((e) => e.toJson()).toList();

    file.writeAsStringSync(jsonEncode(categoriesJson));
  }

  Future<List<CategoryModel>> getCategories(
    String projectPath,
  ) async {
    return _readCategories(projectPath);
  }

  Future<void> addCategory(
    CategoryModel category,
    String projectPath,
  ) async {
    final List<CategoryModel> categories = _readCategories(projectPath);

    categories.add(category);

    await _writeCategories(
      categories,
      projectPath,
    );
  }

  Future<void> updateCategory(
    CategoryModel category,
    String projectPath,
  ) async {
    final List<CategoryModel> categories = _readCategories(projectPath);
    final List<CategoryModel> categoriesUpdated =
        categories.map((e) => e.name == category.name ? category : e).toList();

    await _writeCategories(
      categoriesUpdated,
      projectPath,
    );
  }
}
