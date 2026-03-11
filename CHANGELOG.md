# Changelog

## [0.2.0] - 2026-03-11
### Changed
- Connessioni HTTP bloccate: l'app accetta esclusivamente URL HTTPS per proteggere le credenziali in transito
- Username spostato da SharedPreferences a flutter_secure_storage (cifratura nativa OS)
- Validazione HTTPS aggiunta anche nel servizio API (ITopApiService) come ulteriore protezione
- Sanitizzazione completa input OQL: escape stringhe, validazione ID numerici e nomi classe per prevenire OQL injection

## [0.1.14] - 2026-03-11
### Changed
- Aggiornata sezione build nel README con istruzioni iOS complete (debug, release, IPA)
- Aggiunta nota sui requisiti macOS/Xcode per i build iOS
