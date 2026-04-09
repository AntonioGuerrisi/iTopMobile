import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for securely storing user credentials
class StorageService {
  static const _keyServerUrl = 'itop_server_url';
  static const _keyUsername = 'itop_username';
  static const _keyPassword = 'itop_password';
  static const _keyRememberMe = 'itop_remember_me';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Saves credentials
  Future<void> saveCredentials({
    required String serverUrl,
    required String username,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyServerUrl, serverUrl);
    await prefs.setBool(_keyRememberMe, true);
    await _secureStorage.write(key: _keyUsername, value: username);
    await _secureStorage.write(key: _keyPassword, value: password);
  }

  /// Loads saved credentials
  Future<Map<String, String>?> loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(_keyRememberMe) ?? false;

    if (!rememberMe) return null;

    final serverUrl = prefs.getString(_keyServerUrl);
    final username = await _secureStorage.read(key: _keyUsername);
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

  /// Clears credentials
  Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyServerUrl);
    await prefs.remove(_keyRememberMe);
    await _secureStorage.delete(key: _keyUsername);
    await _secureStorage.delete(key: _keyPassword);
  }

  /// Checks whether saved credentials exist
  Future<bool> hasCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRememberMe) ?? false;
  }

  // ==================== CERTIFICATE PINNING ====================

  static const _pinPrefix = 'cert_pin_';

  /// Saves the SHA-256 certificate fingerprint for a host
  Future<void> saveCertificatePin(String host, String fingerprint) async {
    await _secureStorage.write(key: '$_pinPrefix$host', value: fingerprint);
  }

  /// Loads the stored fingerprint for a host
  Future<String?> loadCertificatePin(String host) async {
    return await _secureStorage.read(key: '$_pinPrefix$host');
  }

  /// Deletes the stored pin for a host (e.g. after certificate renewal)
  Future<void> deleteCertificatePin(String host) async {
    await _secureStorage.delete(key: '$_pinPrefix$host');
  }
}
