import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/config_controller.dart';
import 'package:x_video_ai/controllers/content_controller.dart';
import 'package:x_video_ai/elements/forms/create_content/create_content_state.dart';
import 'package:x_video_ai/models/content_model.dart';
import 'package:x_video_ai/services/content_service.dart';

class CreateContentFormController extends StateNotifier<CreateContentState> {
  final ContentService _contentService;
  final ContentController _contentController;
  final String _path;

  CreateContentFormController(
    ContentService contentService,
    ContentController contentController,
    String path,
  )   : _contentService = contentService,
        _contentController = contentController,
        _path = path,
        super(CreateContentState());

  void setId(String id) {
    state = state.mergeWith({
      "id": id,
    });

    validate();
  }

  void setName(String name) {
    state = state.mergeWith({
      "name": name,
    });

    validate();
  }

  bool validate() {
    final errors = <String, String>{};

    if (state.id.isEmpty) {
      errors['id'] = 'ID is required';
    }

    if (state.name.isEmpty) {
      errors['name'] = 'Name is required';
    } else if (state.name.length < 3) {
      errors['name'] = 'Name must be at least 3 characters';
    }

    state = state.mergeWith({
      'errors': errors,
      'isValidForm': errors.isEmpty,
    });

    return errors.isEmpty;
  }

  void reset() {
    state = CreateContentState();
  }

  void submit() {
    if (validate()) {
      final ContentModel contentModel = ContentModel.factory(
        {
          ...state.toJson(),
          'path': _path,
        },
      );

      _contentService.saveContent(contentModel);
      _contentController.initContent(contentModel);
    }
  }
}

final createContentFormControllerProvider =
    StateNotifierProvider<CreateContentFormController, CreateContentState>(
  (ref) {
    final ConfigController configController =
        ref.read(configControllerProvider.notifier);
    final ContentController contentController =
        ref.read(contentControllerProvider.notifier);
    final String path =
        "${configController.configService?.model?.path}/${configController.configService?.model?.name}";

    return CreateContentFormController(
      const ContentService(),
      contentController,
      path,
    );
  },
);
