import 'package:flutter/cupertino.dart';

import 'AudioUtils.dart';
import 'NetWorkManager.dart';

class ClickManager {
  static DateTime? _lastClickTime;

  static bool canClick({required BuildContext context,int interval = 1100}) {
    AudioUtils().playClickAudio();
    if (NetWorkManager().isNetError(context)) return false;
    final now = DateTime.now();
    if (_lastClickTime == null ||
        now.difference(_lastClickTime!) > Duration(milliseconds: interval)) {
      _lastClickTime = now;
      return true;
    }
    return false;
  }
}
