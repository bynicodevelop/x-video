import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/content_controller.dart';
import 'package:x_video_ai/models/video_section_model.dart';

class SectionsControllerProvider
    extends StateNotifier<List<VideoSectionModel>> {
  final ContentController _contentController;

  SectionsControllerProvider(
    ContentController contentController,
  )   : _contentController = contentController,
        super([]);

  List<VideoSectionModel> get sections =>
      _contentController.content.sections?['content']
          .map((e) => VideoSectionModel.fromJson(e))
          .whereType<VideoSectionModel>()
          .toList();

  void updateSection(
    VideoSectionModel section,
  ) {
    final List<VideoSectionModel> newSections = sections.map((e) {
      if (e.start == section.start && e.end == section.end) {
        return section;
      }
      return e;
    }).toList();

    _contentController.setSections(newSections.map((e) => e.toJson()).toList());
    _contentController.save();

    state = newSections;
  }
}

final sectionsControllerProvider =
    StateNotifierProvider<SectionsControllerProvider, List<VideoSectionModel>>(
  (ref) => SectionsControllerProvider(
    ref.watch(contentControllerProvider.notifier),
  ),
);
