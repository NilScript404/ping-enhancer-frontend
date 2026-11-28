import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bunkerBg,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.vulcanCard,
      primary: AppColors.caribbeanGreen,
      secondary: AppColors.dodgerBlue,
      error: AppColors.watermelonRed,
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 64,
      backgroundColor: AppColors.navBarBg,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.caribbeanGreen20,
      indicatorShape: const StadiumBorder(),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final color = states.contains(WidgetState.selected)
            ? AppColors.caribbeanGreen
            : AppColors.textMuted;
        return IconThemeData(color: color, size: 18);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final color = states.contains(WidgetState.selected)
            ? AppColors.textPrimary
            : AppColors.textMuted;
        return TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
        );
      }),
    ),
  );
}
