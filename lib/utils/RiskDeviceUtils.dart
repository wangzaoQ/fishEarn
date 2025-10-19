import 'package:flutter/services.dart';

final class RiskDeviceUtils {
  static final RiskDeviceUtils instance = RiskDeviceUtils._internal();

  RiskDeviceUtils._internal();

  final _methodChannel = const MethodChannel('zxcv');

  //设备是否被Root
  Future<bool> root() async {
    return (await _methodChannel.invokeMethod("root")) == true;
  }

  //是否连接VPN网络
  Future<bool> vpn() async {
    return (await _methodChannel.invokeMethod("vpn")) == true;
  }

  //设备是否有可用的sim卡
  Future<bool> sim() async {
    return (await _methodChannel.invokeMethod("sim")) == true;
  }

  //设备是否为模拟器
  Future<bool> simulator() async {
    return (await _methodChannel.invokeMethod("simulator")) == true;
  }

  //应用是否安装自Google play store
  Future<bool> store() async {
    return (await _methodChannel.invokeMethod("store")) == true;
  }

  //设备是否启用开发者模式
  Future<bool> developer() async {
    return (await _methodChannel.invokeMethod("developer")) == true;
  }

  //安装应用的安装器程序的包名
  Future<String> installer() async {
    return await _methodChannel.invokeMethod("installer");
  }

  //初始化数盟平台
  Future<void> initNumberUnit({required String apiKey}) async {
    await _methodChannel.invokeMethod("initNumberUnit", apiKey);
  }

  //从数盟平台读取数盟可信ID，对应文档请求参数：did
  Future<String> getNumberUnitID({String channel = "", String message = ""}) async {
    return (await _methodChannel.invokeMethod("getNumberUnitID", {
      "channel": channel,
      "message": message,
    })) ??
        "";
  }
}
