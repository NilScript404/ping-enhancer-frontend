import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class IcmpScreen extends StatefulWidget {
  const IcmpScreen({super.key});

  @override
  State<IcmpScreen> createState() => _IcmpScreenState();
}

class _IcmpScreenState extends State<IcmpScreen> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 16),
      children: [
        // ICMP Ping Test Top Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.vulcanCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.mirageBorder80),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ICMP Server Test",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Gathering & testing server routes",
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
              Text(
                "Best: TR (24 ms)",
                style: TextStyle(color: AppColors.caribbeanGreen, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
