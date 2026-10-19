import 'package:flutter/material.dart';

import 'dj_screen.dart';
import 'favorites_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _i = 0;
  static const _pages = [HomeScreen(), FavoritesScreen(), HistoryScreen(), DjScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _i, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _i,
        onDestinationSelected: (v) => setState(() => _i = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.radio), label: 'Radyo'),
          NavigationDestination(icon: Icon(Icons.favorite_border), label: 'Favoriler'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Geçmiş'),
          NavigationDestination(icon: Icon(Icons.mic), label: 'DJ'),
        ],
      ),
    );
  }
}
