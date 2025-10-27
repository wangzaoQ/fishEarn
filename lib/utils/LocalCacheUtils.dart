import 'dart:convert';

import 'package:fish_earn/config/LocalCacheConfig.dart';
import 'package:fish_earn/config/LocalConfig.dart';
import 'package:fish_earn/data/GameData.dart';
import 'package:fish_earn/data/UserData.dart';
import 'package:fish_earn/task/CashManager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/EventConfig.dart';
import '../config/global.dart';
import '../event/NotifyEvent.dart';
import '../view/pop/BasePopView.dart';
import '../view/pop/WithdrawPop.dart';

class LocalCacheUtils{
  static SharedPreferences? _prefs;

  // 初始化，App启动时调用一次
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 写操作
  static Future<bool> putInt(String key, int value) async {
    return await _prefs!.setInt(key, value);
  }

  static Future<bool> putDouble(String key, double value) async {
    return await _prefs!.setDouble(key, value);
  }

  static Future<bool> putBool(String key, bool value) async {
    return await _prefs!.setBool(key, value);
  }

  static Future<bool> putString(String key, String value) async {
    return await _prefs!.setString(key, value);
  }

  static Future<bool> putStringList(String key, List<String> value) async {
    return await _prefs!.setStringList(key, value);
  }

  // 读操作，带默认值
  static int getInt(String key, {int defaultValue = 0}) {
    return _prefs?.getInt(key) ?? defaultValue;
  }

  static double getDouble(String key, {double defaultValue = 0.0}) {
    return _prefs?.getDouble(key) ?? defaultValue;
  }

  static bool getBool(String key, {bool defaultValue = false}) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  static String getString(String key, {String defaultValue = ''}) {
    return _prefs?.getString(key) ?? defaultValue;
  }

  static List<String> getStringList(
      String key, {
        List<String> defaultValue = const [],
      }) {
    return _prefs?.getStringList(key) ?? defaultValue;
  }

  // 删除某个key
  static Future<bool> remove(String key) async {
    return await _prefs!.remove(key);
  }

  // 保存Game，序列化成json字符串
  static Future<bool> putGameData(GameData gameData) async {
    String jsonStr = jsonEncode(gameData.toJson());
    var result =  await _prefs!.setString(LocalCacheConfig.cacheKeyLocalGame, jsonStr);
    // CashManager.instance.onMoneyChanged(gameData.coin.toInt());
    if(gameData.coin>=500){
      var firstShowCashLimit = LocalCacheUtils.getBool(LocalCacheConfig.firstShowCashLimit,defaultValue: true);
      if(firstShowCashLimit){
        LocalCacheUtils.putBool(LocalCacheConfig.firstShowCashLimit, false);
        eventBus.fire(NotifyEvent(EventConfig.cashTips1));
        if(result == 1){
          eventBus.fire(NotifyEvent(EventConfig.toCash));
        }
      }
    }else if(gameData.coin>=200){
      var firstShowCashLimit = LocalCacheUtils.getBool(LocalCacheConfig.firstShowCashTips,defaultValue: true);
      if(firstShowCashLimit){
        LocalCacheUtils.putBool(LocalCacheConfig.firstShowCashTips, false);
        eventBus.fire(NotifyEvent(EventConfig.cashTips2));
      }
    }
    return result;
  }

  // 读取Game，反序列化
  static GameData getGameData() {
    String? jsonStr = _prefs?.getString(LocalCacheConfig.cacheKeyLocalGame);
    if (jsonStr == null) {
      var user = GameData();
      putGameData(user);
      return user;
    }
    Map<String, dynamic> map = jsonDecode(jsonStr);
    return GameData.fromJson(map);
  }

  // 保存Game，序列化成json字符串
  static Future<bool> putUserData(UserData user) async {
    String jsonStr = jsonEncode(user.toJson());
    return await _prefs!.setString(LocalCacheConfig.cacheKeyUserData, jsonStr);
  }

  // 读取Game，反序列化
  static UserData getUserData() {
    String? jsonStr = _prefs?.getString(LocalCacheConfig.cacheKeyUserData);
    if (jsonStr == null) {
      var user = UserData();
      putUserData(user);
      return user;
    }
    Map<String, dynamic> map = jsonDecode(jsonStr);
    return UserData.fromJson(map);
  }

  static Future<void> saveIntList(String key, List<int> list) async {
    String encoded = jsonEncode(list); // 转 JSON
    await _prefs?.setString(key, encoded);
  }

  static List<int> loadIntList(String key)  {
    String? encoded = _prefs?.getString(key);
    if (encoded == null) return [];
    List<dynamic> decoded = jsonDecode(encoded);
    return decoded.cast<int>();
  }

  // 清空所有数据
  static Future<bool> clear() async {
    return await _prefs!.clear();
  }
}