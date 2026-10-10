import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'routing/router.dart';

import 'home_feature/home.dart' as home;
import 'icmp_feature/icmp.dart' as icmp;

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        bottomNavigationBar: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              bottom: TabBar(
                tabs: [
                  Tab(text: "home"),
                  Tab(text: "icmp"),
                ],
              ),
            ),
            body: const TabBarView(
              children: [home.HomeScreen(), icmp.IcmpScreen()],
            ),
          ),
        ),
      ),
    );
  }
}
