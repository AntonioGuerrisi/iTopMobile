import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servizio per salvare in modo sicuro le credenziali dell'utente
class StorageService {
  static const _keyServerUrl = 'itop_server_url';
  static const _keyUsername = 'itop_username';
  static const _keyPassword = 'itop_password';
  static const _keyRememberMe = 'itop_remember_me';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Salva le credenziali
  Future<void> saveCredentials({
    required String serverUrl,
    required String username,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyServerUrl, serverUrl);
    await prefs.setString(_keyUsername, username);
    await prefs.setBool(_keyRememberMe, true);
    await _secureStorage.write(key: _keyPassword, value: password);
  }

  /// Carica le credenziali salvate
  Future<Map<String, String>?> loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(_keyRememberMe) ?? false;

    if (!rememberMe) return null;

    final serverUrl = prefs.getString(_keyServerUrl);
    final username = prefs.getString(_keyUsername);
    final password = await _secureStorage.read(key: _keyPassword);

    if (serverUrl != null && username != null && password != null) {
      return {
        'serverUrl': serverUrl,
        'username': username,
        'password': password,
      };
    }
    return null;
  }

  /// Cancella le credenziali
  Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyServerUrl);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyRememberMe);
    await _secureStorage.delete(key: _keyPassword);
  }

  /// Controlla se ci sono credenziali salvate
  Future<bool> hasCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRememberMe) ?? false;
  }
}
