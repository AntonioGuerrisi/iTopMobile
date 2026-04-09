import 'package:flutter/material.dart';
import 'package:itop_mobile/l10n/app_localizations.dart';
import 'ticket_list_screen.dart';
import 'asset_list_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const TicketListScreen(),
    const AssetListScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            activeIcon: Icon(Icons.confirmation_number_rounded),
            label: 'Ticket',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.devices_other),
            activeIcon: Icon(Icons.devices_other_rounded),
            label: 'Asset',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            activeIcon: const Icon(Icons.settings_rounded),
            label: AppLocalizations.of(context)!.settings,
          ),
        ],
      ),
    );
  }
}
