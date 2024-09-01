import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/loading_controller.dart';

void main() {
  late ProviderContainer container;
  late LoadingController loadingController;

  setUp(() {
    container = ProviderContainer();
    loadingController = container.read(loadingControllerProvider.notifier);
  });

  tearDown(() {
    container.dispose();
  });

  test('Initial state should be empty', () {
    expect(loadingController.state.isEmpty, isTrue);
  });

  test('startLoading should set isLoading to true for a given key', () {
    const key = 'testKey';
    loadingController.startLoading(key);
    expect(loadingController.isLoading(key), isTrue);
  });

  test('stopLoading should set isLoading to false for a given key', () {
    const key = 'testKey';
    loadingController.startLoading(key); // Start loading first
    loadingController.stopLoading(key);
    expect(loadingController.isLoading(key), isFalse);
  });

  test('Provider should update state correctly for multiple keys', () {
    const key1 = 'key1';
    const key2 = 'key2';

    container.read(loadingControllerProvider.notifier).startLoading(key1);
    expect(container.read(loadingControllerProvider)[key1], isTrue);
    expect(container.read(loadingControllerProvider)[key2], isNull);

    container.read(loadingControllerProvider.notifier).startLoading(key2);
    expect(container.read(loadingControllerProvider)[key2], isTrue);

    container.read(loadingControllerProvider.notifier).stopLoading(key1);
    expect(container.read(loadingControllerProvider)[key1], isFalse);
  });
}
