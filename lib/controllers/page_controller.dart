import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PageControllerNotifier extends StateNotifier<int> {
  final PageController pageController;

  PageControllerNotifier({required this.pageController}) : super(0) {
    pageController.addListener(pageListener);
  }

  void pageListener() {
    if (state != pageController.page?.round()) {
      state = pageController.page?.round() ?? 0;
    }
  }

  void jumpToPage(int page) {
    pageController.jumpToPage(page);
  }

  @override
  void dispose() {
    pageController.removeListener(pageListener);
    pageController.dispose();

    super.dispose();
  }
}

final pageControllerProvider =
    StateNotifierProvider<PageControllerNotifier, int>(
  (ref) => PageControllerNotifier(
    pageController: PageController(),
  ),
);
