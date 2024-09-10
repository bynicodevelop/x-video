import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/upload_controller.dart';
import 'package:x_video_ai/models/editor_section_model.dart';
import 'package:x_video_ai/models/video_section_model.dart';
import 'package:x_video_ai/utils/generate_md5_name.dart';

class EditorSectionControllerProvider
    extends StateNotifier<List<EditorSectionModel>> {
  EditorSectionControllerProvider(
    UploadControllerProvider uploadControllerProvider,
  ) : super([]);

  EditorSectionModel getSectionById(String id) {
    return state.firstWhere(
      (element) => element.id == id,
    );
  }

  Future<EditorSectionModel> add(
    VideoSectionModel section,
  ) async {
    final EditorSectionModel editorSectionModel = EditorSectionModel(
      id: await generateMD5NameFromString(
        "${section.sentence}-${section.keyword}",
      ),
      section: section,
    );

    state = [...state, editorSectionModel];

    return editorSectionModel;
  }

  Future<void> uploadInTmpDirectory() async {}
}

final editorSectionControllerProvider = StateNotifierProvider<
    EditorSectionControllerProvider, List<EditorSectionModel>>(
  (ref) => EditorSectionControllerProvider(
    ref.read(uploadControllerProvider.notifier),
  ),
);
