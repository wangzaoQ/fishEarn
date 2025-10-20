import 'dart:ui';

import 'package:advertising_id/advertising_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fish_earn/config/LocalCacheConfig.dart';
import 'package:fish_earn/utils/GlobalDataManager.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tba_info/flutter_tba_info.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

//https://market.gte666.com/#/appmeta/doc/1978748000189673474
class NetParamsManager{
  // 私有构造函数
  NetParamsManager._();

  // 全局唯一实例
  static final NetParamsManager instance = NetParamsManager._();

  // 公共访问点
  factory NetParamsManager() {
    return instance;
  }

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();


  Future<Map<String, dynamic>> getCommonJson() async {
    final Map<String, dynamic> parentJson = {};
    parentJson["c"] = await GlobalDataManager.instance.getDeviceId();
    parentJson["triode"] = await getOsVersion();
    parentJson["sliver"] = await Uuid().v4();
    parentJson["criteria"] = await getDeviceModel();
    parentJson["tracery"] = "widgeon";
    parentJson["hostage"] = getLocaleCode();
    parentJson["hobart"] = await getOperator();
    parentJson["plug"] = "com.fishearn.rewards";
    parentJson["carthage"] = await getDeviceManufacturer();
    parentJson["juan"] = await getAppVersion();
    parentJson["bulk"] = DateTime.now().millisecondsSinceEpoch;

    // parentJson["parsley"] = await getGID();
    // parentJson["still"] = await GlobalDataManager.getDeviceId();
    // parentJson["leila"] = DateTime.now().timeZoneOffset.inHours;
    return {"gemsbok":parentJson};
  }

  String getLocaleCode() {
    final locale = PlatformDispatcher.instance.locale; // 当前系统语言环境
    return '${locale.languageCode}_${locale.countryCode}';
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
    return gid;
  }

  Future<String> getDeviceManufacturer() async {
    String manufacturer = "";
    try {
      var androidInfo = await deviceInfo.androidInfo;
      manufacturer = androidInfo.manufacturer ?? 'Unknown';
    } catch (e) {
    }
    return manufacturer;
  }


  Future<String> getOsVersion() async {
    return await FlutterTbaInfo().getOsVersion();
  }

  Future<String> getDeviceModel() async {
    var cacheDeviceModelMKey = LocalCacheUtils.getString(LocalCacheConfig.cacheDMMKey,defaultValue: "");
    if(cacheDeviceModelMKey.isNotEmpty){
      return cacheDeviceModelMKey;
    }
    try {
      var androidInfo = await deviceInfo.androidInfo;
      LocalCacheUtils.putString(LocalCacheConfig.cacheDMMKey, androidInfo.model);
      return androidInfo.model;
    } catch (_) {}
    return "";
  }

  Future<String> getAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version; // 如 "1.0.0"
    } catch (e) {
      return "";
    }
  }

  Future<String> getBuildId() async {
    final androidInfo = await deviceInfo.androidInfo;
    var buildId = androidInfo.id;
    if (!buildId.startsWith('build/')) {
      buildId = 'build/$buildId';
    }
    return buildId;
  }

  Future<String> getWebViewUserAgent() async {
    var ua = LocalCacheUtils.getString(LocalCacheConfig.cacheWUAKey,defaultValue: "");
    if(ua.isEmpty){
      ua =  await FlutterTbaInfo().getDefaultUserAgent();
      LocalCacheUtils.putString(LocalCacheConfig.cacheWUAKey, ua);
    }
    return ua;
  }

  Future<String> getOperator() async{
    return "mcn";
  }
}