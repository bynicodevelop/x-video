import 'dart:async';

final _debounce = Debounce();

void debounce(Function() action) {
  _debounce.debounce(action);
}

class Debounce {
  Timer? _timer;

  void debounce(Function() action) {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 500), action);
  }
}
