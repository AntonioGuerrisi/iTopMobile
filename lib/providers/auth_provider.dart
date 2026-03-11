import 'package:flutter/foundation.dart';
import '../services/itop_api_service.dart';
import '../services/storage_service.dart';
import '../services/certificate_pinning_service.dart';

/// Provider per la gestione dell'autenticazione
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

  /// Tenta il login automatico con credenziali salvate
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
      // Auto-login fallito, l'utente dovrà fare login manualmente
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Effettua il login a iTop
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

      // Verifica il certificato del server (TOFU pinning)
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

        // Recupera info utente corrente
        _currentUser = await _apiService!.getCurrentUser();

        // Salva credenziali se richiesto
        if (rememberMe) {
          await _storageService.saveCredentials(
            serverUrl: normalizedUrl,
            username: username,
            password: password,
          );
        }
      } else {
        _errorMessage = 'Credenziali non valide o server non raggiungibile';
        _apiService = null;
      }

      return success;
    } catch (e) {
      if (e.toString().contains('HandshakeException') ||
          e.toString().contains('CertificatePinningException')) {
        _isCertificateError = true;
        _errorMessage =
            'Errore certificato SSL: il certificato del server potrebbe '
            'essere cambiato. Prova a resettare il pin del certificato.';
      } else {
        _errorMessage = 'Errore di connessione: $e';
      }
      _apiService = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Effettua il logout
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

  /// Resetta il pin del certificato per il server corrente
  Future<void> resetCertificatePin() async {
    final uri = Uri.parse(_serverUrl);
    await _pinningService.resetPin(uri.host);
    _isCertificateError = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Pulisce il messaggio di errore
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
