class ClickManager {
  static DateTime? _lastClickTime;

  static bool canClick({int interval = 1100}) {
    final now = DateTime.now();
    if (_lastClickTime == null ||
        now.difference(_lastClickTime!) > Duration(milliseconds: interval)) {
      _lastClickTime = now;
      return true;
    }
    return false;
  }
}
