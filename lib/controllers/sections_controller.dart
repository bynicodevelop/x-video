import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/content_controller.dart';
import 'package:x_video_ai/gateway/file_getaway.dart';
import 'package:x_video_ai/models/category_model.dart';
import 'package:x_video_ai/models/video_section_model.dart';
import 'package:x_video_ai/services/category_service.dart';

class SectionsControllerProvider
    extends StateNotifier<List<VideoSectionModel>> {
  final CategoryService _categoryService;
  final ContentController _contentController;

  SectionsControllerProvider(
    CategoryService categoryService,
    ContentController contentController,
  )   : _categoryService = categoryService,
        _contentController = contentController,
        super([]);

  List<VideoSectionModel> get sections => state;

  void initSections() {
    List<VideoSectionModel> sections =
        _contentController.content.sections?['content']
            .map((e) {
              CategoryModel categoryModel = CategoryModel.factory({});

              if (e['fileName'] == null || e['fileName'].isEmpty) {
                categoryModel = _categoryService.findCategoryByKeyword(
                  e['keyword'],
                  _contentController.state.path,
                );
              }

              final VideoSectionModel section = VideoSectionModel.fromJson(e);

              if (categoryModel.isEmpty()) {
                return section;
              }

              return section.mergeWith(
                fileName: categoryModel.videos.first,
              );
            })
            .whereType<VideoSectionModel>()
            .toList();

    _save(sections);

    state = sections;
  }

  void updateSection(
    VideoSectionModel section,
  ) {
    final List<VideoSectionModel> newSections = sections.map((e) {
      if (e.start == section.start && e.end == section.end) {
        return section;
      }
      return e;
    }).toList();

    _save(newSections);

    state = newSections;
  }

  void _save(List<VideoSectionModel> sections) {
    _contentController.setSections(sections.map((e) => e.toJson()).toList());
    _contentController.save();
  }
}

final sectionsControllerProvider =
    StateNotifierProvider<SectionsControllerProvider, List<VideoSectionModel>>(
  (ref) => SectionsControllerProvider(
    CategoryService(
      FileGateway(),
    ),
    ref.watch(contentControllerProvider.notifier),
  ),
);
