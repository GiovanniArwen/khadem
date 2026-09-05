import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  static late SharedPreferences pref;

  static String kIsOnBoardingShown = 'isOnBoardingShown';
  static String kUserId = 'kUserId';

  static Future<void> init() async {
    pref = await SharedPreferences.getInstance();
  }

  static Future<void> isOnBoardingShown(bool isShown) async {
    await setData(kIsOnBoardingShown, isShown);
  }

  static bool? getIsOnBoardingShown() {
    return getData(kIsOnBoardingShown);
  }

  static Future<void> setUserId(String uid) async {
    await setData(kUserId, uid);
  }

  static String? getUserId() {
    return getData(kUserId);
  }

  static Future<void> setData(String key, dynamic value) async {
    if (value is int) {
      await pref.setInt(key, value);
    } else if (value is bool) {
      await pref.setBool(key, value);
    } else if (value is String) {
      await pref.setString(key, value);
    } else if (value is double) {
      await pref.setDouble(key, value);
    } else if (value is List<String>) {
      await pref.setStringList(key, value);
    }
  }

  static dynamic getData(String key) {
    return pref.get(key);
  }

  static Future<bool> clear() async {
    return await pref.clear();
  }

  static Future<bool> remove(String key) async {
    return await pref.remove(key);
  }
}
