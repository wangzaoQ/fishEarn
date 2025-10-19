import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:fish_earn/config/LocalCacheConfig.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:flutter/services.dart';
import 'package:flutter_udid/flutter_udid.dart';

class GlobalDataManager{
  // 私有构造函数
  GlobalDataManager._();

  // 全局唯一实例
  static final GlobalDataManager instance = GlobalDataManager._();

  bool _isBrazil = false;

  // 初始化监听系统 Locale 变化
  void init() {
    PlatformDispatcher.instance.onLocaleChanged = () {
      _updateBrazilStatus();
    };
    _updateBrazilStatus(); // 首次计算
  }

  // 外部调用
  bool isBrazilUser() => _isBrazil;

  // 内部更新逻辑
  void _updateBrazilStatus() {
    final localeTag = PlatformDispatcher.instance.locale.toLanguageTag();
    _isBrazil = localeTag.startsWith('pt-BR');
  }

  String getCommonCoin(int level){
    return level == 2?"+0.02/s":"+0.05/s";
  }

  static Future<String> getDeviceId() async {
    var deviceId = LocalCacheUtils.getString(LocalCacheConfig.deviceIdKey,defaultValue: "");
    if(deviceId.isNotEmpty)return deviceId;
    String udid = await FlutterUdid.udid;
    if(udid.isEmpty){
      udid = await FlutterUdid.consistentUdid;
    }
    LocalCacheUtils.putString(LocalCacheConfig.deviceIdKey, udid);
    return udid;
  }

// 复制文本到剪贴板
  static void copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  //解密：“data”：加密字符串；“code”：需求文档标题前的项目编号
  static String decrypt(String data, int code) {
    final decode = base64.decode(data);
    final decode2 = decode.toList();
    List<int> xorList = [];
    for (int i = 0; i < decode2.length; i++) {
      xorList.add(decode2[i] ^ code);
    }
    return utf8.decode(xorList);
  }

  static bool allowShowInt(double coin) {
    return true;
  }
}