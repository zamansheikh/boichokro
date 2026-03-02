import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// App Theme - Professional & Polished Design System
class AppTheme {
  // Brand Color Palette - Modern Clean Aesthetic (Emerald & Slate)
  static const Color _primaryLight = Color(0xFF059669); // Emerald 600
  static const Color _secondaryLight = Color(0xFF10B981); // Emerald 500
  static const Color _surfaceLight = Color(0xFFFFFFFF); // Pure White
  static const Color _backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color _errorLight = Color(0xFFEF4444); // Red 500

  // Dark Theme Colors
  static const Color _primaryDark = Color(0xFF10B981); // Emerald 500
  static const Color _secondaryDark = Color(0xFF34D399); // Emerald 400
  static const Color _surfaceDark = Color(0xFF1E293B); // Slate 800
  static const Color _backgroundDark = Color(0xFF0F172A); // Slate 900
  static const Color _errorDark = Color(0xFFF87171); // Red 400

  static TextTheme _buildTextTheme(TextTheme base) {
    // Inter provides a very clean, professional, and highly legible look used by many modern SaaS and premium apps.
    return GoogleFonts.notoSerifBengaliTextTheme(base).copyWith(
      displayLarge: GoogleFonts.notoSerifBengali(
        fontSize: 57,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
      ),
      displayMedium: GoogleFonts.notoSerifBengali(
        fontSize: 45,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.notoSerifBengali(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineLarge: GoogleFonts.notoSerifBengali(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.notoSerifBengali(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineSmall: GoogleFonts.notoSerifBengali(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      titleLarge: GoogleFonts.notoSerifBengali(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      titleMedium: GoogleFonts.notoSerifBengali(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
      titleSmall: GoogleFonts.notoSerifBengali(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
      bodyLarge: GoogleFonts.notoSerifBengali(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      bodyMedium: GoogleFonts.notoSerifBengali(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      bodySmall: GoogleFonts.notoSerifBengali(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      labelLarge: GoogleFonts.notoSerifBengali(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.notoSerifBengali(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelSmall: GoogleFonts.notoSerifBengali(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
    );
  }

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: _primaryLight,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFD1FAE5), // Emerald 100
      onPrimaryContainer: Color(0xFF064E3B), // Emerald 900
      secondary: _secondaryLight,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFA7F3D0), // Emerald 200
      onSecondaryContainer: Color(0xFF065F46), // Emerald 800
      tertiary: Color(0xFF0EA5E9), // Sky 500 for variety
      onTertiary: Colors.white,
      error: _errorLight,
      onError: Colors.white,
      surface: _surfaceLight,
      onSurface: Color(0xFF0F172A), // Slate 900
      onSurfaceVariant: Color(0xFF64748B), // Slate 500
      outline: Color(0xFFCBD5E1), // Slate 300
      outlineVariant: Color(0xFFE2E8F0), // Slate 200
      shadow: Colors.black,
      surfaceContainerHighest: Color(0xFFF1F5F9), // Slate 100
      surfaceContainerHigh: Color(0xFFF8FAFC), // Slate 50
      surfaceContainer: _surfaceLight,
      inverseSurface: Color(0xFF1E293B), // Slate 800
      onInverseSurface: Colors.white,
    ),
    scaffoldBackgroundColor: _backgroundLight,

    // Typography
    textTheme: _buildTextTheme(ThemeData.light().textTheme).apply(
      bodyColor: const Color(0xFF334155), // Slate 700
      displayColor: const Color(0xFF0F172A), // Slate 900
    ),

    // AppBar
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: _backgroundLight,
      foregroundColor: const Color(0xFF0F172A), // Slate 900
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: GoogleFonts.notoSerifBengali(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF0F172A),
        letterSpacing: -0.2,
      ),
      iconTheme: const IconThemeData(color: Color(0xFF0F172A), size: 22),
      actionsIconTheme: const IconThemeData(color: Color(0xFF0F172A), size: 22),
    ),

    // Cards
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1), // Slate 200
      ),
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      clipBehavior: Clip.antiAlias,
    ),

    // Input Fields
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)), // Slate 200
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)), // Slate 200
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _errorLight),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _errorLight, width: 2),
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC), // Slate 50
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: const TextStyle(color: Color(0xFF94A3B8)), // Slate 400
      labelStyle: const TextStyle(color: Color(0xFF64748B)), // Slate 500
      floatingLabelStyle: const TextStyle(color: _primaryLight),
    ),

    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        backgroundColor: _primaryLight,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.notoSerifBengali(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          letterSpacing: 0,
        ),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        backgroundColor: _primaryLight,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.notoSerifBengali(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          letterSpacing: 0,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        side: const BorderSide(
          color: Color(0xFFE2E8F0),
          width: 1.5,
        ), // Slate 200
        foregroundColor: const Color(0xFF334155), // Slate 700
        textStyle: GoogleFonts.notoSerifBengali(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          letterSpacing: 0,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primaryLight,
        textStyle: GoogleFonts.notoSerifBengali(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0,
        ),
      ),
    ),

    // Chips
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFF1F5F9), // Slate 100
      selectedColor: const Color(0xFFD1FAE5), // Emerald 100
      disabledColor: const Color(0xFFE2E8F0), // Slate 200
      labelStyle: GoogleFonts.notoSerifBengali(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF334155), // Slate 700
      ),
      secondaryLabelStyle: GoogleFonts.notoSerifBengali(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF064E3B), // Emerald 900
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      ), // Fully rounded
      side: BorderSide.none,
    ),

    // Bottom Navigation
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: const Color(0xFFD1FAE5), // Emerald 100
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      height: 70,
      elevation: 20,
      shadowColor: const Color(0x19000000), // 10% black
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.notoSerifBengali(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _primaryLight,
          );
        }
        return GoogleFonts.notoSerifBengali(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF64748B), // Slate 500
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: _primaryLight, size: 24);
        }
        return const IconThemeData(color: Color(0xFF64748B), size: 24);
      }),
    ),

    // FAB
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _primaryLight,
      foregroundColor: Colors.white,
      elevation: 8,
      focusElevation: 10,
      hoverElevation: 10,
      highlightElevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      extendedTextStyle: GoogleFonts.notoSerifBengali(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        letterSpacing: 0,
      ),
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
      titleTextStyle: GoogleFonts.notoSerifBengali(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF0F172A),
      ),
      contentTextStyle: GoogleFonts.notoSerifBengali(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF475569), // Slate 600
        height: 1.5,
      ),
    ),

    // Bottom Sheet
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      clipBehavior: Clip.antiAlias,
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: Color(0xFFF1F5F9), // Slate 100
      thickness: 1,
      space: 1,
    ),

    // List Tile
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      titleTextStyle: GoogleFonts.notoSerifBengali(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF0F172A),
      ),
      subtitleTextStyle: GoogleFonts.notoSerifBengali(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF64748B),
      ),
      iconColor: const Color(0xFF64748B),
    ),

    // Progress Indicator
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: _primaryLight,
      linearTrackColor: Color(0xFFE2E8F0),
      circularTrackColor: Color(0xFFE2E8F0),
    ),

    // Snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF0F172A), // Slate 900
      contentTextStyle: GoogleFonts.notoSerifBengali(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 10,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: _primaryDark,
      onPrimary: Color(0xFF022C22), // Emerald 950
      primaryContainer: Color(0xFF064E3B), // Emerald 900
      onPrimaryContainer: Color(0xFFD1FAE5), // Emerald 100
      secondary: _secondaryDark,
      onSecondary: Color(0xFF022C22), // Emerald 950
      secondaryContainer: Color(0xFF065F46), // Emerald 800
      onSecondaryContainer: Color(0xFFA7F3D0), // Emerald 200
      tertiary: Color(0xFF38BDF8), // Sky 400
      onTertiary: Color(0xFF0C4A6E), // Sky 900
      error: _errorDark,
      onError: Color(0xFF450A0A), // Red 950
      surface: _surfaceDark,
      onSurface: Color(0xFFF8FAFC), // Slate 50
      onSurfaceVariant: Color(0xFF94A3B8), // Slate 400
      outline: Color(0xFF475569), // Slate 600
      outlineVariant: Color(0xFF334155), // Slate 700
      shadow: Colors.black,
      surfaceContainerHighest: Color(0xFF334155), // Slate 700
      surfaceContainerHigh: Color(0xFF1E293B), // Slate 800
      surfaceContainer: _backgroundDark,
      inverseSurface: Color(0xFFF8FAFC), // Slate 50
      onInverseSurface: Color(0xFF0F172A), // Slate 900
    ),
    scaffoldBackgroundColor: _backgroundDark,

    textTheme: _buildTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: const Color(0xFFCBD5E1), // Slate 300
      displayColor: const Color(0xFFF8FAFC), // Slate 50
    ),

    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: _backgroundDark,
      foregroundColor: const Color(0xFFF8FAFC), // Slate 50
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: GoogleFonts.notoSerifBengali(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFF8FAFC),
        letterSpacing: -0.2,
      ),
      iconTheme: const IconThemeData(color: Color(0xFFF8FAFC), size: 22),
      actionsIconTheme: const IconThemeData(color: Color(0xFFF8FAFC), size: 22),
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF334155), width: 1), // Slate 700
      ),
      color: _surfaceDark,
      surfaceTintColor: Colors.transparent,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      clipBehavior: Clip.antiAlias,
    ),

    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF334155)), // Slate 700
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF334155)), // Slate 700
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _primaryDark, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _errorDark),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _errorDark, width: 2),
      ),
      filled: true,
      fillColor: const Color(0xFF0F172A), // Slate 900
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: const TextStyle(color: Color(0xFF64748B)), // Slate 500
      labelStyle: const TextStyle(color: Color(0xFF94A3B8)), // Slate 400
      floatingLabelStyle: const TextStyle(color: _primaryDark),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        backgroundColor: _primaryDark,
        foregroundColor: const Color(0xFF022C22), // Emerald 950
        textStyle: GoogleFonts.notoSerifBengali(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          letterSpacing: 0,
        ),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        backgroundColor: _primaryDark,
        foregroundColor: const Color(0xFF022C22), // Emerald 950
        textStyle: GoogleFonts.notoSerifBengali(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          letterSpacing: 0,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        side: const BorderSide(
          color: Color(0xFF475569),
          width: 1.5,
        ), // Slate 600
        foregroundColor: const Color(0xFFF8FAFC), // Slate 50
        textStyle: GoogleFonts.notoSerifBengali(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          letterSpacing: 0,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primaryDark,
        textStyle: GoogleFonts.notoSerifBengali(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0,
        ),
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF1E293B), // Slate 800
      selectedColor: const Color(0xFF064E3B), // Emerald 900
      disabledColor: const Color(0xFF334155), // Slate 700
      labelStyle: GoogleFonts.notoSerifBengali(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: const Color(0xFFCBD5E1), // Slate 300
      ),
      secondaryLabelStyle: GoogleFonts.notoSerifBengali(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFD1FAE5), // Emerald 100
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      side: BorderSide.none,
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: _surfaceDark,
      indicatorColor: const Color(0xFF064E3B), // Emerald 900
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      height: 70,
      elevation: 20,
      shadowColor: Colors.black,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.notoSerifBengali(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _primaryDark,
          );
        }
        return GoogleFonts.notoSerifBengali(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF94A3B8), // Slate 400
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: _primaryDark, size: 24);
        }
        return const IconThemeData(color: Color(0xFF94A3B8), size: 24);
      }),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _primaryDark,
      foregroundColor: const Color(0xFF022C22), // Emerald 950
      elevation: 8,
      focusElevation: 10,
      hoverElevation: 10,
      highlightElevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      extendedTextStyle: GoogleFonts.notoSerifBengali(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        letterSpacing: 0,
      ),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: _surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFF334155), width: 1),
      ),
      titleTextStyle: GoogleFonts.notoSerifBengali(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: const Color(0xFFF8FAFC),
      ),
      contentTextStyle: GoogleFonts.notoSerifBengali(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: const Color(0xFFCBD5E1),
        height: 1.5,
      ),
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: _surfaceDark,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      clipBehavior: Clip.antiAlias,
    ),

    dividerTheme: const DividerThemeData(
      color: Color(0xFF334155), // Slate 700
      thickness: 1,
      space: 1,
    ),

    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      titleTextStyle: GoogleFonts.notoSerifBengali(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFF8FAFC),
      ),
      subtitleTextStyle: GoogleFonts.notoSerifBengali(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF94A3B8),
      ),
      iconColor: const Color(0xFF94A3B8),
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: _primaryDark,
      linearTrackColor: Color(0xFF334155),
      circularTrackColor: Color(0xFF334155),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF334155), // Slate 700
      contentTextStyle: GoogleFonts.notoSerifBengali(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 10,
    ),
  );
}
