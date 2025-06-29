// NOTE: Tambahkan dependency shared_preferences di pubspec.yaml
import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static final PrefsService instance = PrefsService._init();
  static SharedPreferences? _prefs;

  PrefsService._init();

  Future<SharedPreferences> get prefs async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> setLogin(bool value) async {
    final p = await prefs;
    await p.setBool('isLogin', value);
  }

  Future<bool> isLogin() async {
    final p = await prefs;
    return p.getBool('isLogin') ?? false;
  }

  Future<void> setUsername(String name) async {
    final p = await prefs;
    await p.setString('username', name);
  }

  Future<String> getUsername() async {
    final p = await prefs;
    return p.getString('username') ?? '';
  }

  Future<void> setFavoriteCategory(String category) async {
    final p = await prefs;
    await p.setString('favoriteCategory', category);
  }

  Future<String> getFavoriteCategory() async {
    final p = await prefs;
    return p.getString('favoriteCategory') ?? '';
  }

  Future<void> setThemeMode(bool isDark) async {
    final p = await prefs;
    await p.setBool('isDark', isDark);
  }

  Future<bool> isDarkMode() async {
    final p = await prefs;
    return p.getBool('isDark') ?? false;
  }
} 