import 'package:shared_preferences/shared_preferences.dart';

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

  // // 保存User，序列化成json字符串
  // static Future<bool> putUser(UserData user) async {
  //   String jsonStr = jsonEncode(user.toJson());
  //   return await _prefs!.setString(CacheConfig.cacheUserKey, jsonStr);
  // }
  //
  // // 读取User，反序列化
  // static UserData getUser() {
  //   String? jsonStr = _prefs?.getString(CacheConfig.cacheUserKey);
  //   if (jsonStr == null) {
  //     var user = UserData(newCoin: 0.0);
  //     putUser(user);
  //     return user;
  //   }
  //   Map<String, dynamic> map = jsonDecode(jsonStr);
  //   return UserData.fromJson(map);
  // }



  // 清空所有数据
  static Future<bool> clear() async {
    return await _prefs!.clear();
  }
}