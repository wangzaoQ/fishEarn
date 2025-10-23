
import 'package:fish_earn/view/pop/NetErrorPop.dart';
import 'package:flutter/cupertino.dart';

import '../config/LocalConfig.dart';
import '../view/pop/BasePopView.dart';
import 'AudioUtils.dart';
import 'NetWorkManager.dart';

class ClickManager {
  static DateTime? _lastClickTime;

  static bool canClick({required BuildContext context,int interval = 500}) {
    AudioUtils().playClickAudio();
    if (NetWorkManager().isNetError(context)) {
      if(LocalConfig.globalContext!=null){
        BasePopView().showScaleDialog(
          context: LocalConfig.globalContext!,
          child: NetErrorPop(),
        );
      }
      return false;
    }
    final now = DateTime.now();
    if (_lastClickTime == null ||
        now.difference(_lastClickTime!) > Duration(milliseconds: interval)) {
      _lastClickTime = now;
      return true;
    }
    return false;
  }

  static void clickAudio() {
    AudioUtils().playClickAudio();
  }
}
