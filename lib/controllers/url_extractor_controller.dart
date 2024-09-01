import 'package:flutter_riverpod/flutter_riverpod.dart';

class UrlExtractorController extends StateNotifier<Map<String, dynamic>> {
  UrlExtractorController()
      : super({
          'url': '',
        });

  String get url => state['url'];

  bool isValideUrl() {
    try {
      final uri = Uri.parse(state['url']);
      return uri.hasScheme && (uri.hasAuthority || uri.hasFragment);
    } catch (e) {
      return false;
    }
  }

  void setUrl(String url) {
    state = {
      'url': url,
    };
  }

  void clearUrl() {
    state = {
      'url': '',
    };
  }
}

final urlExtractorControllerProvider =
    StateNotifierProvider<UrlExtractorController, Map<String, dynamic>>(
  (ref) => UrlExtractorController(),
);
