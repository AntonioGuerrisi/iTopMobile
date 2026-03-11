import 'dart:io';
import 'package:crypto/crypto.dart';
import 'storage_service.dart';

/// Servizio per il certificate pinning con approccio TOFU (Trust On First Use).
///
/// Al primo collegamento verso un server, il fingerprint SHA-256 del certificato
/// viene validato tramite le CA di sistema e poi memorizzato in modo sicuro.
/// Alle connessioni successive, il fingerprint viene verificato contro il pin
/// memorizzato, proteggendo da attacchi Man-in-the-Middle.
class CertificatePinningService {
  final StorageService _storageService;

  CertificatePinningService(this._storageService);

  /// Recupera il fingerprint SHA-256 del certificato del server
  /// tramite connessione validata dalle CA di sistema.
  Future<String> _fetchServerFingerprint(String host) async {
    final socket = await SecureSocket.connect(host, 443);
    try {
      final cert = socket.peerCertificate;
      if (cert == null) {
        throw CertificatePinningException(
          'Il server non ha fornito un certificato SSL.',
        );
      }
      return sha256.convert(cert.der).toString();
    } finally {
      socket.close();
    }
  }

  /// Verifica il certificato del server rispetto al pin memorizzato.
  ///
  /// - Prima connessione (TOFU): recupera il fingerprint tramite CA di sistema
  ///   e lo salva nel secure storage.
  /// - Connessioni successive: confronta il fingerprint attuale con il pin
  ///   memorizzato. Se non corrispondono, lancia [CertificatePinningException].
  Future<void> verifyServerCertificate(String serverUrl) async {
    final uri = Uri.parse(serverUrl);
    final host = uri.host;

    final currentFingerprint = await _fetchServerFingerprint(host);
    final storedPin = await _storageService.loadCertificatePin(host);

    if (storedPin == null) {
      // TOFU: prima connessione — salva il pin
      await _storageService.saveCertificatePin(host, currentFingerprint);
      return;
    }

    if (currentFingerprint != storedPin) {
      throw CertificatePinningException(
        'Il certificato del server è cambiato rispetto al pin memorizzato. '
        'Possibile attacco Man-in-the-Middle.',
      );
    }
  }

  /// Resetta il pin memorizzato per un host (es. dopo rinnovo certificato).
  Future<void> resetPin(String host) async {
    await _storageService.deleteCertificatePin(host);
  }

  /// Verifica se esiste un pin memorizzato per un host.
  Future<bool> hasPin(String host) async {
    final pin = await _storageService.loadCertificatePin(host);
    return pin != null;
  }
}

/// Eccezione per errori di certificate pinning
class CertificatePinningException implements Exception {
  final String message;
  CertificatePinningException(this.message);

  @override
  String toString() => 'CertificatePinningException: $message';
}
