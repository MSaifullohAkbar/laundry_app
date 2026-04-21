import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xFF006590);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF00B5FF);
  static const Color onPrimaryContainer = Color(0xFF004362);
  static const Color primaryFixed = Color(0xFFC8E6FF);
  static const Color primaryFixedDim = Color(0xFF88CEFF);

  // Secondary
  static const Color secondary = Color(0xFF38637F);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFB2DCFD);
  static const Color onSecondaryContainer = Color(0xFF37627E);
  static const Color secondaryFixed = Color(0xFFCFE5FF);

  // Tertiary
  static const Color tertiary = Color(0xFF8A5100);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFF39413);
  static const Color onTertiaryContainer = Color(0xFF5E3500);
  static const Color tertiaryFixed = Color(0xFFFFDCBD);

  // Error
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Surface
  static const Color surface = Color(0xFFF6FAFF);
  static const Color onSurface = Color(0xFF171C21);
  static const Color surfaceVariant = Color(0xFFDEE3E9);
  static const Color onSurfaceVariant = Color(0xFF3E4851);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFEFF4FA);
  static const Color surfaceContainer = Color(0xFFE9EEF5);
  static const Color surfaceContainerHigh = Color(0xFFE4E9EF);
  static const Color surfaceContainerHighest = Color(0xFFDEE3E9);
  static const Color surfaceDim = Color(0xFFD5DAE1);

  // Outline
  static const Color outline = Color(0xFF6E7882);
  static const Color outlineVariant = Color(0xFFBDC8D2);
  static const Color inverseSurface = Color(0xFF2B3136);
  static const Color inverseOnSurface = Color(0xFFECF1F7);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryButtonGradient = LinearGradient(
    colors: [primary, Color(0xFF0085B4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppRadius {
  static const double card = 16.0;
  static const double cardLarge = 32.0;
  static const double cardXL = 48.0;
  static const double pill = 999.0;
  static const double button = 999.0;
  static const double input = 999.0;
}

class AppShadows {
  static List<BoxShadow> cardLight = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 24,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> cardFocused = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 32,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> primaryButton = [
    BoxShadow(
      color: const Color(0xFF00B5FF).withValues(alpha: 0.5),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
  ];
}

class AppTheme {
  static ThemeData get lightTheme {
    final colorScheme = const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      inverseSurface: AppColors.inverseSurface,
      onInverseSurface: AppColors.inverseOnSurface,
      surfaceContainerLowest: AppColors.surfaceContainerLowest,
      surfaceContainerLow: AppColors.surfaceContainerLow,
      surfaceContainer: AppColors.surfaceContainer,
      surfaceContainerHigh: AppColors.surfaceContainerHigh,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
    );

    final textTheme = GoogleFonts.plusJakartaSansTextTheme().copyWith(
      displayLarge: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800, color: AppColors.onSurface),
      displayMedium: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700, color: AppColors.onSurface),
      displaySmall: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700, color: AppColors.onSurface),
      headlineLarge: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700, color: AppColors.onSurface),
      headlineMedium: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600, color: AppColors.onSurface),
      headlineSmall: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600, color: AppColors.onSurface),
      titleLarge: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600, color: AppColors.onSurface),
      titleMedium: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w500, color: AppColors.onSurface),
      titleSmall: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w500, color: AppColors.onSurface),
      bodyLarge: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w400, color: AppColors.onSurface),
      bodyMedium: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w400, color: AppColors.onSurface),
      bodySmall: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w400, color: AppColors.onSurfaceVariant),
      labelLarge: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600, color: AppColors.onSurface),
      labelMedium: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w500, color: AppColors.onSurface),
      labelSmall: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w400, color: AppColors.onSurfaceVariant),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.onPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainerLow,
        selectedColor: AppColors.primaryContainer,
        labelStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
    );
  }
}
