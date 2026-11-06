import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 16),
      children: [
        Container(
          height: 195,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.vulcanCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.mirageBorder80),
          ),
          child: const Center(
            child: Text(
              "Connected",
              style: TextStyle(
                color: AppColors.turquoiseBlue,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
