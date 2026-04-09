import 'dart:io';
import 'package:crypto/crypto.dart';
import 'storage_service.dart';

/// Service for certificate pinning using TOFU (Trust On First Use).
///
/// On first connection, the server certificate SHA-256 fingerprint is validated
/// by the system CA chain and saved securely. On subsequent connections, the
/// current fingerprint is compared to the stored pin to protect against
/// Man-in-the-Middle attacks.
class CertificatePinningService {
  final StorageService _storageService;

  CertificatePinningService(this._storageService);

  /// Retrieves the server certificate SHA-256 fingerprint
  /// via a system-validated TLS connection.
  Future<String> _fetchServerFingerprint(String host) async {
    final socket = await SecureSocket.connect(host, 443);
    try {
      final cert = socket.peerCertificate;
      if (cert == null) {
        throw CertificatePinningException(
          'The server did not provide an SSL certificate.',
        );
      }
      return sha256.convert(cert.der).toString();
    } finally {
      socket.close();
    }
  }

  /// Verifies the server certificate against the stored pin.
  ///
  /// - First connection (TOFU): fetches the fingerprint via system CA and saves it.
  /// - Subsequent connections: compares the current fingerprint to the stored pin.
  ///   If they differ, throws [CertificatePinningException].
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
        'The server certificate has changed from the stored pin. '
        'Possible Man-in-the-Middle attack.',
      );
    }
  }

  /// Resets the stored pin for a host (e.g. after certificate renewal).
  Future<void> resetPin(String host) async {
    await _storageService.deleteCertificatePin(host);
  }

  /// Checks whether a stored pin exists for a host.
  Future<bool> hasPin(String host) async {
    final pin = await _storageService.loadCertificatePin(host);
    return pin != null;
  }
}

/// Exception for certificate pinning errors
class CertificatePinningException implements Exception {
  final String message;
  CertificatePinningException(this.message);

  @override
  String toString() => 'CertificatePinningException: $message';
}
