import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/content_controller.dart';
import 'package:x_video_ai/controllers/loading_controller.dart';
import 'package:x_video_ai/models/content_model.dart';
import 'package:x_video_ai/services/content_service.dart';
import 'package:x_video_ai/gateway/file_getaway.dart';

void main() {
  late ProviderContainer container;
  late ContentController contentController;
  late ContentService contentService;
  late LoadingController loadingController;

  setUp(() {
    container = ProviderContainer();
    contentService = ContentService(FileGateway());
    loadingController = LoadingController();
    contentController = ContentController(contentService, loadingController, 'test/path');
  });

  tearDown(() {
    container.dispose();
  });

  test('initial state is correct', () {
    expect(contentController.content.path, 'test/path');
    expect(contentController.isInitialized, false);
    expect(contentController.isReadyVideo, false);
    expect(contentController.hasChronical, false);
  });

  test('initContent sets the content model', () {
    final contentModel = ContentModel(path: 'new/path');
    contentController.initContent(contentModel);
    expect(contentController.content.path, 'new/path');
  });

  test('setContent updates the content', () {
    contentController.setContent('New Title', 'New Content');
    expect(contentController.content.content?['title'], 'New Title');
    expect(contentController.content.content?['content'], 'New Content');
  });

  test('setChronical updates the chronical', () {
    contentController.setChronical('New Chronical Content');
    expect(contentController.content.chronical?['content'], 'New Chronical Content');
  });

  test('setAudio updates the audio', () {
    contentController.setAudio('New Audio Content');
    expect(contentController.content.audio?['content'], 'New Audio Content');
  });

  test('setSrt updates the srt', () {
    final srt = {'key': 'value'};
    contentController.setSrt(srt);
    expect(contentController.content.srt?['content'], srt);
  });

  test('setSrtWithGroup updates the srtWithGroup', () {
    final srtWithGroup = [{'key': 'value'}];
    contentController.setSrtWithGroup(srtWithGroup);
    expect(contentController.content.srtWithGroup?['content'], srtWithGroup);
  });

  test('setAss updates the assContent', () {
    contentController.setAss('New ASS Content');
    expect(contentController.content.assContent?['content'], 'New ASS Content');
  });

  test('setSections updates the sections', () {
    final sections = [{'key': 'value'}];
    contentController.setSections(sections);
    expect(contentController.content.sections?['content'], sections);
  });

  test('updateSections updates an existing section', () {
    final section = {'sentence': 'test', 'key': 'value'};
    contentController.setSections([section]);
    final updatedSection = {'sentence': 'test', 'key': 'new value'};
    contentController.updateSections(updatedSection);
    expect(contentController.content.sections?['content'][0]['key'], 'new value');
  });

  test('updateSections exepect throw if it does not exist', () {
    final section = {'sentence': 'test', 'key': 'value'};
    
    // expect throw form updateSections
    expect(
      () => container.read(contentControllerProvider.notifier).updateSections(section),
      throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Sections content is not defined'))),
    );
  });

  test('save calls startLoading and saveContent', () {
    contentController.save();
    // Assuming you have a way to verify that startLoading and saveContent were called
  });
}