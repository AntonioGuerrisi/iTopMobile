import 'package:flutter/material.dart';
import 'package:itop_mobile/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final currentLocale = localeProvider.locale;
    final currentLocaleCode = LocaleProvider.supportedLanguageCodes
            .contains(currentLocale.languageCode)
        ? currentLocale.languageCode
        : AppLocalizations.supportedLocales.first.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info utente
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(
                      auth.username.isNotEmpty
                          ? auth.username[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.currentUser?['contactid_friendlyname']
                                  ?.toString() ??
                              auth.username,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          auth.username,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          auth.serverUrl,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Info app
          Card(
            child: Column(
              children: [
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    final version =
                        snapshot.hasData ? snapshot.data!.version : '...';
                    final buildNumber =
                        snapshot.hasData ? snapshot.data!.buildNumber : '...';
                    return Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.info_outline),
                          title: Text(AppLocalizations.of(context)!.version),
                          subtitle: Text(version),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.build_outlined),
                          title: Text(AppLocalizations.of(context)!.build),
                          subtitle: Text(buildNumber),
                        ),
                      ],
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(AppLocalizations.of(context)!.language),
                  subtitle: Text(_languageName(context, currentLocaleCode)),
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: currentLocaleCode,
                      items: [
                        DropdownMenuItem(
                          value: 'en',
                          child: Text(AppLocalizations.of(context)!.english),
                        ),
                        DropdownMenuItem(
                          value: 'it',
                          child: Text(AppLocalizations.of(context)!.italian),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          context
                              .read<LocaleProvider>()
                              .setLocale(Locale(value));
                        }
                      },
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.dns),
                  title: Text(AppLocalizations.of(context)!.server),
                  subtitle: Text(auth.serverUrl),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.api),
                  title: Text('API iTop'),
                  subtitle: Text('REST JSON v1.3'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Logout
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _confirmLogout(context),
              icon: const Icon(Icons.logout, color: Colors.red),
              label: Text(
                AppLocalizations.of(context)!.signOut,
                style: const TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _languageName(BuildContext context, String languageCode) {
    switch (languageCode) {
      case 'it':
        return AppLocalizations.of(context)!.italian;
      case 'en':
      default:
        return AppLocalizations.of(context)!.english;
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.confirm),
        content: Text(AppLocalizations.of(context)!.confirmSignOut),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthProvider>().logout();
            },
            child: Text(
              AppLocalizations.of(context)!.signOut,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
