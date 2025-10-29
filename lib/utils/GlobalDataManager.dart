import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:advertising_id/advertising_id.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fish_earn/config/LocalCacheConfig.dart';
import 'package:fish_earn/data/GlobalConfig.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:flutter/services.dart';
import 'package:flutter_udid/flutter_udid.dart';

import '../config/CashConfig.dart';
import '../data/IntAdConfig.dart';
import '../task/RewardManager.dart';
import 'LogUtils.dart';

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
    return level == 2?"+${RewardManager.instance.get2LevelCoin()}/s":"+${RewardManager.instance.get3LevelCoin()}/s";
  }

  Future<String> getDeviceId() async {
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
  void copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  //解密：“data”：加密字符串；“code”：需求文档标题前的项目编号
  String decrypt(String data, int code) {
    final decode = base64.decode(data);
    final decode2 = decode.toList();
    List<int> xorList = [];
    for (int i = 0; i < decode2.length; i++) {
      xorList.add(decode2[i] ^ code);
    }
    return utf8.decode(xorList);
  }


  /// 加密方法：
  /// - [data] 明文字符串
  /// - [code] 需求文档标题前的项目编号
  String encrypt(String data, int code) {
    // 1️⃣ 将字符串转为 UTF8 字节数组
    final bytes = utf8.encode(data);

    // 2️⃣ 对每个字节进行 XOR 运算
    List<int> xorList = [];
    for (int i = 0; i < bytes.length; i++) {
      xorList.add(bytes[i] ^ code);
    }

    // 3️⃣ 再进行 Base64 编码
    return base64.encode(xorList);
  }


  IntAdConfig? intADConfig;
  void initIntADConfig(Map<String, dynamic>? initialTasks){
    try{
      if (initialTasks != null) {
        intADConfig = IntAdConfig.fromJson(initialTasks);
      }
    }catch (e){
      LogUtils.logE("IntAdConfig  init error $e");
    }
    if(intADConfig == null){
      intADConfig = IntAdConfig.fromJson(CashConfig.defaultIntAD);
    }
  }

  GlobalConfig? globalData;
  void initGlobalConfig(Map<String, dynamic>? initialTasks){
    try{
      if (initialTasks != null) {
        globalData = GlobalConfig.fromJson(initialTasks);
      }
    }catch (e){
      LogUtils.logE("IntAdConfig  init error $e");
    }
    if(globalData == null){
      globalData = GlobalConfig.fromJson(CashConfig.defaultGlobalConfig);
    }
  }

  int addLevel1_2() {
    return globalData?.level_1_2??10;
  }
  int addLevel2_3() {
    return globalData?.level_2_3??20;
  }
  int getUnLimitedTime(){
    var time = globalData?.unlimitedTime??100;
    return time;
  }


  bool allowShowInt(double coin) {
    var isCashed =LocalCacheUtils.getBool(LocalCacheConfig.isCashed,defaultValue: false);
    if(isCashed){
      return true;
    }
    if(intADConfig == null)return true;
    if(intADConfig!.intAd.isEmpty){
      return false;
    }
    var currentItem = intADConfig!.intAd[intADConfig!.intAd.length-1];
    for (var item in intADConfig!.intAd) {
      if (coin >= item.firstNumber && coin < item.endNumber) {
        currentItem = item;
        break;
      }
    }
    return Random().nextInt(100)<currentItem.point;
  }


  Future getGID() async {
    String? gid="";
    gid = LocalCacheUtils.getString(LocalCacheConfig.cacheGIDKey,defaultValue: "");
    if(gid.isNotEmpty){
      return gid;
    }
    try {
      gid = await AdvertisingId.id(true);
    } on Exception {
      gid = "";
    }
    LocalCacheUtils.putString(LocalCacheConfig.cacheGIDKey,gid??"");

    return gid;
  }


}