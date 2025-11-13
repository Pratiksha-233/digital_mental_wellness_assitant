import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static const _kDisplayName = 'profile.displayName';
  static const _kPhotoPath = 'profile.photoPath';

  static Future<String?> getDisplayName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kDisplayName);
  }

  static Future<void> setDisplayName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDisplayName, name);
  }

  static Future<String?> getPhotoPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kPhotoPath);
  }

  static Future<void> setPhotoPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPhotoPath, path);
  }
}
