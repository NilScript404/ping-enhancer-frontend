import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: AppColors.bunkerBg,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Ping Enhancer",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            Row(
              children: [
                Container(
                  height: 27,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.vulcanCard,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.mirageBorder90),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        "Vortex",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        "·",
                        style: TextStyle(color: AppColors.fiord, fontSize: 11),
                      ),
                      SizedBox(width: 6),
                      Text(
                        "22d",
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        "·",
                        style: TextStyle(color: AppColors.fiord, fontSize: 11),
                      ),
                      SizedBox(width: 6),
                      Text(
                        "42.5 GB",
                        style: TextStyle(
                          color: AppColors.caribbeanGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  height: 26,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.jade15,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.jade35),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "+Ad",
                    style: TextStyle(
                      color: AppColors.turquoiseBlue,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
