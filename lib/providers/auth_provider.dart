import 'package:flutter/foundation.dart';
import '../services/itop_api_service.dart';
import '../services/storage_service.dart';
import '../services/certificate_pinning_service.dart';

/// Provider for authentication management
class AuthProvider with ChangeNotifier {
  ITopApiService? _apiService;
  final StorageService _storageService = StorageService();
  late final CertificatePinningService _pinningService =
      CertificatePinningService(_storageService);

  bool _isAuthenticated = false;
  bool _isLoading = false;
  bool _isCertificateError = false;
  String? _errorMessage;
  String _serverUrl = 'https://example.domain.tld';
  String _username = '';
  Map<String, dynamic>? _currentUser;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get isCertificateError => _isCertificateError;
  String? get errorMessage => _errorMessage;
  String get serverUrl => _serverUrl;
  String get username => _username;
  ITopApiService? get apiService => _apiService;
  Map<String, dynamic>? get currentUser => _currentUser;

  AuthProvider() {
    _tryAutoLogin();
  }

  /// Attempts auto-login with saved credentials
  Future<void> _tryAutoLogin() async {
    _isLoading = true;
    notifyListeners();

    try {
      final creds = await _storageService.loadCredentials();
      if (creds != null) {
        await login(
          serverUrl: creds['serverUrl']!,
          username: creds['username']!,
          password: creds['password']!,
          rememberMe: true,
          isAutoLogin: true,
        );
      }
    } catch (_) {
      // Auto-login failed; the user must log in manually
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Performs login to iTop
  Future<bool> login({
    required String serverUrl,
    required String username,
    required String password,
    bool rememberMe = false,
    bool isAutoLogin = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Normalizza l'URL (rimuovi trailing slash)
      final normalizedUrl = serverUrl.endsWith('/')
          ? serverUrl.substring(0, serverUrl.length - 1)
          : serverUrl;

      // Verify the server certificate (TOFU pinning)
      await _pinningService.verifyServerCertificate(normalizedUrl);

      _apiService = ITopApiService(
        baseUrl: normalizedUrl,
        username: username,
        password: password,
      );

      final success = await _apiService!.testLogin();

      if (success) {
        _isAuthenticated = true;
        _serverUrl = normalizedUrl;
        _username = username;

        // Fetch current user info
        _currentUser = await _apiService!.getCurrentUser();

        // Save credentials if requested
        if (rememberMe) {
          await _storageService.saveCredentials(
            serverUrl: normalizedUrl,
            username: username,
            password: password,
          );
        }
      } else {
        _errorMessage = 'Invalid credentials or server unavailable';
        _apiService = null;
      }

      return success;
    } catch (e) {
      if (e.toString().contains('HandshakeException') ||
          e.toString().contains('CertificatePinningException')) {
        _isCertificateError = true;
        _errorMessage =
            'SSL certificate error: the server certificate may have changed. '
            'Try resetting the certificate pin.';
      } else {
        _errorMessage = 'Connection error: $e';
      }
      _apiService = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Performs logout
  Future<void> logout() async {
    _isAuthenticated = false;
    _apiService = null;
    _currentUser = null;
    _username = '';
    _errorMessage = null;
    _isCertificateError = false;
    await _storageService.clearCredentials();
    notifyListeners();
  }

  /// Resets the certificate pin for the current server
  Future<void> resetCertificatePin() async {
    final uri = Uri.parse(_serverUrl);
    await _pinningService.resetPin(uri.host);
    _isCertificateError = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clears the error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
