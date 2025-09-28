import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fish_earn/utils/GameManager.dart';
import 'package:flutter/cupertino.dart';

import 'LogUtils.dart';

class NetWorkManager {
  static final NetWorkManager _instance = NetWorkManager._internal();

  factory NetWorkManager() => _instance;

  NetWorkManager._internal();

  late StreamSubscription<List<ConnectivityResult>> subscription;

  var netType = 0;

  void initNetworkListener() {
    subscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (results.contains(ConnectivityResult.none)) {
        netType = -1;
        LogUtils.logD("net none");
      } else {
        LogUtils.logD("net other");
        netType = 0;
      }
    });
  }

  void disposeNetworkListener() {
    subscription.cancel();
  }

  bool isNetError(BuildContext context) {
    if(netType == 0)return false;
    // BasePop().showScaleDialog(context: context, child:NetErrorPop(onConfirm: (int result) {
    // }, type: type,));
    GameManager.instance.showTips("app_net_error".tr());
    return true;
  }
}
