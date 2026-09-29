import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Helper wrapper around [SharedPreferences] providing typed read/write/remove utilities.
@injectable
class SharedPrefHelper {
  final SharedPreferences sharedPreferences;

  SharedPrefHelper(this.sharedPreferences);

  /// Saves [val] under [key] according to runtime type.
  Future<bool> saveData({required String key, required dynamic val}) {
    if (val is int) {
      return sharedPreferences.setInt(key, val);
    } else if (val is double) {
      return sharedPreferences.setDouble(key, val);
    } else if (val is String) {
      return sharedPreferences.setString(key, val);
    } else if (val is List<String>) {
      return sharedPreferences.setStringList(key, val);
    } else {
      return sharedPreferences.setBool(key, val as bool);
    }
  }

  /// Retrieves value stored under [key].
  Object? getData({required String key}) {
    return sharedPreferences.get(key);
  }

  /// Removes entry stored under [key].
  Future<bool> removeData({required String key}) async {
    return await sharedPreferences.remove(key);
  }

  /// Clears all preferences.
  Future<bool> clearData() async {
    return await sharedPreferences.clear();
  }
}
