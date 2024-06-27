import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String jwtKey = 'jwt';

  Future<void> saveJwt(String jwt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(jwtKey, jwt);
  }

  Future<String?> getJwt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(jwtKey);
  }

  Future<void> deleteJwt() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(jwtKey);
  }
}
