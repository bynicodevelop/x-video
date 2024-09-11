import 'dart:convert';

import 'package:x_video_ai/gateway/file_getaway.dart';
import 'package:x_video_ai/models/category_model.dart';

class CategoryService {
  final FileGateway _fileGateway;

  CategoryService(
    FileGateway fileGateway,
  ) : _fileGateway = fileGateway;

  final String _categoriesFile = 'categories.json';

  List<CategoryModel> _readCategories(String projectPath) {
    final FileWrapper file =
        _fileGateway.getFile("$projectPath/$_categoriesFile");

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
    final FileWrapper file =
        _fileGateway.getFile("$projectPath/$_categoriesFile");
    await _fileGateway.createDirectory(projectPath);

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
