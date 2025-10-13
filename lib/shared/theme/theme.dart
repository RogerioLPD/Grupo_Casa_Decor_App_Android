import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LightModeColors {
  static const lightPrimary = Color(0xFF465455); // cor principal escura
  static const lightOnPrimary = Colors.white;
  static const lightPrimaryContainer = Color(0xFF6D7B7C); // variação mais clara
  static const lightOnPrimaryContainer = Colors.white;
  static const lightSecondary = Color(0xFFD9B255); // amarelo dourado
  static const lightOnSecondary = Color(0xFF1C1C1C);
  static const lightTertiary = Color(0xFFBDBDBD);
  static const lightOnTertiary = Colors.black;
  static const lightError = Color(0xFFBA1A1A);
  static const lightOnError = Color(0xFFFFFFFF);
  static const lightErrorContainer = Color(0xFFFFDAD6);
  static const lightOnErrorContainer = Color(0xFF410002);
  static const lightInversePrimary = Color(0xFF2D3A3A);
  static const lightShadow = Color(0x33000000);
  static const lightSurface = Color(0xFFF3F4F4); // fundo claro
  static const lightOnSurface = Color(0xFF2C2C2C);
  static const lightAppBarBackground = Color(0xFFE8E9E9);
}

class DarkModeColors {
  static const darkPrimary = Color(0xFF2D3A3A); // tom escuro da cor principal
  static const darkOnPrimary = Colors.white;
  static const darkPrimaryContainer = Color(0xFF3A494A);
  static const darkOnPrimaryContainer = Colors.white;
  static const darkSecondary = Color(0xFFD9B255); // amarelo dourado
  static const darkOnSecondary = Color(0xFF1C1C1C);
  static const darkTertiary = Color(0xFF616161);
  static const darkOnTertiary = Colors.white;
  static const darkError = Color(0xFFFFB4AB);
  static const darkOnError = Color(0xFF690005);
  static const darkErrorContainer = Color(0xFF93000A);
  static const darkOnErrorContainer = Color(0xFFFFDAD6);
  static const darkInversePrimary = Color(0xFF6D7B7C);
  static const darkShadow = Color(0xFF000000);
  static const darkSurface = Color(0xFF1C1C1C);
  static const darkOnSurface = Color(0xFFE0E0E0);
  static const darkAppBarBackground = Color(0xFF2E2E2E);
}

class FontSizes {
  static const double displayLarge = 57.0;
  static const double displayMedium = 45.0;
  static const double displaySmall = 36.0;
  static const double headlineLarge = 32.0;
  static const double headlineMedium = 24.0;
  static const double headlineSmall = 22.0;
  static const double titleLarge = 22.0;
  static const double titleMedium = 18.0;
  static const double titleSmall = 16.0;
  static const double labelLarge = 16.0;
  static const double labelMedium = 14.0;
  static const double labelSmall = 12.0;
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
}

ThemeData get lightTheme => ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary: LightModeColors.lightPrimary,
    onPrimary: LightModeColors.lightOnPrimary,
    primaryContainer: LightModeColors.lightPrimaryContainer,
    onPrimaryContainer: LightModeColors.lightOnPrimaryContainer,
    secondary: LightModeColors.lightSecondary,
    onSecondary: LightModeColors.lightOnSecondary,
    tertiary: LightModeColors.lightTertiary,
    onTertiary: LightModeColors.lightOnTertiary,
    error: LightModeColors.lightError,
    onError: LightModeColors.lightOnError,
    errorContainer: LightModeColors.lightErrorContainer,
    onErrorContainer: LightModeColors.lightOnErrorContainer,
    inversePrimary: LightModeColors.lightInversePrimary,
    shadow: LightModeColors.lightShadow,
    surface: LightModeColors.lightSurface,
    onSurface: LightModeColors.lightOnSurface,
  ),
  brightness: Brightness.light,
  scaffoldBackgroundColor: LightModeColors.lightSurface,
  appBarTheme: const AppBarTheme(
    backgroundColor: LightModeColors.lightAppBarBackground,
    foregroundColor: LightModeColors.lightOnPrimaryContainer,
    elevation: 0,
  ),
  textTheme: GoogleFonts.interTextTheme().apply(
    bodyColor: LightModeColors.lightOnSurface,
    displayColor: LightModeColors.lightOnSurface,
  ),
);

ThemeData get darkTheme => ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    primary: DarkModeColors.darkPrimary,
    onPrimary: DarkModeColors.darkOnPrimary,
    primaryContainer: DarkModeColors.darkPrimaryContainer,
    onPrimaryContainer: DarkModeColors.darkOnPrimaryContainer,
    secondary: DarkModeColors.darkSecondary,
    onSecondary: DarkModeColors.darkOnSecondary,
    tertiary: DarkModeColors.darkTertiary,
    onTertiary: DarkModeColors.darkOnTertiary,
    error: DarkModeColors.darkError,
    onError: DarkModeColors.darkOnError,
    errorContainer: DarkModeColors.darkErrorContainer,
    onErrorContainer: DarkModeColors.darkOnErrorContainer,
    inversePrimary: DarkModeColors.darkInversePrimary,
    shadow: DarkModeColors.darkShadow,
    surface: DarkModeColors.darkSurface,
    onSurface: DarkModeColors.darkOnSurface,
  ),
  brightness: Brightness.dark,
  scaffoldBackgroundColor: DarkModeColors.darkSurface,
  appBarTheme: const AppBarTheme(
    backgroundColor: DarkModeColors.darkAppBarBackground,
    foregroundColor: DarkModeColors.darkOnPrimaryContainer,
    elevation: 0,
  ),
  textTheme: TextTheme(
    displayLarge: GoogleFonts.inter(
      fontSize: FontSizes.displayLarge,
      fontWeight: FontWeight.normal,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: FontSizes.displayMedium,
      fontWeight: FontWeight.normal,
    ),
    displaySmall: GoogleFonts.inter(fontSize: FontSizes.displaySmall, fontWeight: FontWeight.w600),
    headlineLarge: GoogleFonts.inter(
      fontSize: FontSizes.headlineLarge,
      fontWeight: FontWeight.normal,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: FontSizes.headlineMedium,
      fontWeight: FontWeight.w500,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: FontSizes.headlineSmall,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: GoogleFonts.inter(fontSize: FontSizes.titleLarge, fontWeight: FontWeight.w500),
    titleMedium: GoogleFonts.inter(fontSize: FontSizes.titleMedium, fontWeight: FontWeight.w500),
    titleSmall: GoogleFonts.inter(fontSize: FontSizes.titleSmall, fontWeight: FontWeight.w500),
    labelLarge: GoogleFonts.inter(fontSize: FontSizes.labelLarge, fontWeight: FontWeight.w500),
    labelMedium: GoogleFonts.inter(fontSize: FontSizes.labelMedium, fontWeight: FontWeight.w500),
    labelSmall: GoogleFonts.inter(fontSize: FontSizes.labelSmall, fontWeight: FontWeight.w500),
    bodyLarge: GoogleFonts.inter(fontSize: FontSizes.bodyLarge, fontWeight: FontWeight.normal),
    bodyMedium: GoogleFonts.inter(fontSize: FontSizes.bodyMedium, fontWeight: FontWeight.normal),
    bodySmall: GoogleFonts.inter(fontSize: FontSizes.bodySmall, fontWeight: FontWeight.normal),
  ),
);
