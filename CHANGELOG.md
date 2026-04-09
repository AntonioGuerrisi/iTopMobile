# Changelog

## [0.3.1] - 2026-04-10
### Added
- Added Flutter localization support with ARB files and generated `AppLocalizations` in `lib/l10n`
- Added Italian and English translations for all user-facing text in the app (login, tickets, assets, settings)
### Changed
- Updated `SettingsScreen` to allow switching between English and Italian languages

## [0.3.0] - 2026-04-09
### Changed
- Translated README to English for global publication
- Updated UI text and app strings to English across login, tickets, assets, and settings screens
- Centralized user-facing text in `lib/l10n/app_strings.dart`
- Converted Italian comments and error messages in services, models, and providers to English

## [0.2.1] - 2026-03-11
### Added
- Build number visible in the Settings screen

## [0.2.0] - 2026-03-11
### Changed
- Blocked HTTP connections: the app accepts only HTTPS URLs to protect credentials in transit
- Moved username from SharedPreferences to flutter_secure_storage (native OS encryption)
- Added HTTPS validation in the API service (`ITopApiService`) as extra protection
- Fully sanitized OQL input: escaped strings, numeric ID validation, and class name validation to prevent OQL injection
- TOFU certificate pinning: the certificate SHA-256 fingerprint is stored on first connection and verified on every following connection
- Added "Reset certificate pin" button on the login screen for SSL errors (e.g. certificate renewal)

## [0.1.14] - 2026-03-11
### Changed
- Updated README build section with complete iOS instructions (debug, release, IPA)
- Added note about macOS/Xcode requirements for iOS builds
