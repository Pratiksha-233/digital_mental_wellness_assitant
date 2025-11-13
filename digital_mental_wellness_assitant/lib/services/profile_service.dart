import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static const _kDisplayName = 'profile.displayName';
  static const _kPhotoPath = 'profile.photoPath';
  static const _kPhotoBytes = 'profile.photoBytesB64';
  static const _kLastSaved = 'profile.lastSaved';

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

  static Future<String?> getPhotoBytesB64() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kPhotoBytes);
  }

  static Future<void> setPhotoBytesB64(String b64) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPhotoBytes, b64);
  }

  static Future<String?> getLastSaved() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kLastSaved);
  }

  static Future<void> setLastSavedNow() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastSaved, DateTime.now().toIso8601String());
  }
}
