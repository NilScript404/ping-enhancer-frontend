import 'package:flutter/material.dart';

import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'widgets/top_bar/top_bar.dart';
import 'widgets/home/home.dart' as home;
import 'widgets/icmp/icmp.dart' as icmp;

void main() {
  runApp(const PingEnhancer());
}

class PingEnhancer extends StatefulWidget {
  const PingEnhancer({super.key});

  @override
  State<PingEnhancer> createState() => _PingEnhancerState();
}

class _PingEnhancerState extends State<PingEnhancer> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: Scaffold(
        appBar: const TopBar(),
        body: _AppBody(index: _currentIndex),
        bottomNavigationBar: _BottomNav(
          index: _currentIndex,
          onChanged: (i) => setState(() => _currentIndex = i),
        ),
      ),
    );
  }
}

class _AppBody extends StatelessWidget {
  final int index;
  const _AppBody({required this.index});

  static const _screens = [home.HomeScreen(), icmp.IcmpScreen()];

  @override
  Widget build(BuildContext context) {
    return IndexedStack(index: index, children: _screens);
  }
}

class _BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _BottomNav({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.mirageBorder80)),
      ),
      child: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: onChanged,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.network_ping), label: 'ICMP'),
        ],
      ),
    );
  }
}
