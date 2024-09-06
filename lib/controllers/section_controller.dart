import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/content_controller.dart';
import 'package:x_video_ai/models/video_section_model.dart';

class SectionControllerProvider extends StateNotifier<List<VideoSectionModel>> {
  final ContentController _contentController;

  SectionControllerProvider(
    ContentController contentController,
  )   : _contentController = contentController,
        super([]);

  List<VideoSectionModel> get sections => _contentController.content.sections?['content']
        .map((e) => VideoSectionModel.fromJson(e))
        .whereType<VideoSectionModel>()
        .toList();
}

final sectionControllerProvider =
    StateNotifierProvider<SectionControllerProvider, List<VideoSectionModel>>(
  (ref) => SectionControllerProvider(
    ref.watch(contentControllerProvider.notifier),
  ),
);
