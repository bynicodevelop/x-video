import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:x_video_ai/controllers/page_controller.dart';

import 'page_controller_test.mocks.dart';

@GenerateMocks([PageController])
void main() {
  late MockPageController mockPageController;
  late ProviderContainer container;
  late PageControllerNotifier pageControllerNotifier;

  setUp(() {
    mockPageController = MockPageController();
    container = ProviderContainer(
      overrides: [
        pageControllerProvider.overrideWith(
          (ref) => PageControllerNotifier(
            pageController: mockPageController,
          ),
        ),
      ],
    );
    pageControllerNotifier = container.read(pageControllerProvider.notifier);
  });

  tearDown(() {
    container.dispose();
  });

  test('initial state is 0', () {
    expect(container.read(pageControllerProvider), 0);
  });

  test('pageListener updates state when page changes', () {
    // Simulate the page change
    when(mockPageController.page).thenReturn(1.0);

    // Manually trigger the page change listener
    pageControllerNotifier.pageListener();

    // Verify the state has been updated
    expect(container.read(pageControllerProvider), 1);
  });

  test('jumpToPage calls PageController.jumpToPage', () {
    pageControllerNotifier.jumpToPage(2);

    verify(mockPageController.jumpToPage(2)).called(1);
  });
}
