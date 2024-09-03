import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:x_video_ai/controllers/content_controller.dart';
import 'package:x_video_ai/elements/forms/create_content/create_content_form_element_controller.dart';
import 'package:x_video_ai/services/content_service.dart';

import 'create_content_form_element_controller_test.mocks.dart';

@GenerateMocks([ContentService, ContentController])
void main() {
  late MockContentService mockContentService;
  late MockContentController mockContentController;
  late CreateContentFormController createContentFormController;

  setUp(() {
    mockContentService = MockContentService();
    mockContentController = MockContentController();
    createContentFormController = CreateContentFormController(
      mockContentService,
      mockContentController,
      "/path/to/project",
    );
  });

  group('CreateContentFormController', () {
    test('initial state should be empty', () {
      expect(createContentFormController.state.id, isEmpty);
      expect(createContentFormController.state.name, isEmpty);
      expect(createContentFormController.state.errors, isEmpty);
      expect(createContentFormController.state.isValidForm, isFalse);
    });

    test('setId should update the ID and trigger validation', () {
      createContentFormController.setId('123');

      expect(createContentFormController.state.id, '123');
      expect(createContentFormController.state.errors['id'], isNull);
    });

    test('setName should update the name and trigger validation', () {
      createContentFormController.setName('My Content');
      createContentFormController.setId('123');

      expect(createContentFormController.state.name, 'My Content');
      expect(createContentFormController.state.errors['name'], isNull);
      expect(createContentFormController.state.isValidForm, isTrue);
    });

    test('setName should show error for an empty name', () {
      createContentFormController.setName('');

      expect(createContentFormController.state.name, '');
      expect(
          createContentFormController.state.errors['name'], 'Name is required');
      expect(createContentFormController.state.isValidForm, isFalse);
    });

    test('setName should show error for a name that is too short', () {
      createContentFormController.setName('ab');

      expect(createContentFormController.state.name, 'ab');
      expect(createContentFormController.state.errors['name'],
          'Name must be at least 3 characters');
      expect(createContentFormController.state.isValidForm, isFalse);
    });

    test('validate should return false if the form is invalid', () {
      createContentFormController.setId('');
      createContentFormController.setName('ab');

      final isValid = createContentFormController.validate();

      expect(isValid, isFalse);
      expect(createContentFormController.state.errors['id'], 'ID is required');
      expect(createContentFormController.state.errors['name'],
          'Name must be at least 3 characters');
    });

    test('submit should save content if the form is valid', () {
      createContentFormController.setId('123');
      createContentFormController.setName('My Content');

      createContentFormController.submit();

      verify(mockContentService.saveContent(any)).called(1);
      verify(mockContentController.initContent(any)).called(1);
    });

    test('submit should not save content if the form is invalid', () {
      createContentFormController.setId('');
      createContentFormController.setName('');

      createContentFormController.submit();

      verifyNever(mockContentService.saveContent(any));
      verifyNever(mockContentController.initContent(any));
    });

    test('reset should clear the form state', () {
      createContentFormController.setId('123');
      createContentFormController.setName('My Content');

      createContentFormController.reset();

      expect(createContentFormController.state.id, isEmpty);
      expect(createContentFormController.state.name, isEmpty);
      expect(createContentFormController.state.errors, isEmpty);
      expect(createContentFormController.state.isValidForm, isFalse);
    });
  });
}
