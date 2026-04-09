import 'package:flutter/material.dart';
import 'package:itop_mobile/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/ticket_provider.dart';
import 'providers/asset_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ITopMobileApp());
}

class ITopMobileApp extends StatelessWidget {
  const ITopMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProxyProvider<AuthProvider, TicketProvider>(
          create: (_) => TicketProvider(),
          update: (_, auth, tickets) => tickets!..updateAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, AssetProvider>(
          create: (_) => AssetProvider(),
          update: (_, auth, assets) => assets!..updateAuth(auth),
        ),
      ],
      child: Consumer2<AuthProvider, LocaleProvider>(
        builder: (context, auth, localeProvider, _) {
          return MaterialApp(
            title: 'iTop Mobile',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home:
                auth.isAuthenticated ? const HomeScreen() : const LoginScreen(),
          );
        },
      ),
    );
  }
}
