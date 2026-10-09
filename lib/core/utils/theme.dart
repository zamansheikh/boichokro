import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../design/tokens.dart';

/// App Theme - "paper & ink" design system.
///
/// Warm paper surfaces, forest-green ink as the brand colour, marigold for
/// exchanges and terracotta for donations. Headings use a serif that covers
/// both Bengali and Latin; body copy uses a matching sans for legibility.
class AppTheme {
  static TextStyle _serif({
    required double size,
    required FontWeight weight,
    double height = 1.25,
    double spacing = 0,
    Color? color,
  }) {
    return GoogleFonts.notoSerifBengali(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: spacing,
      color: color,
    );
  }

  static TextStyle _sans({
    required double size,
    required FontWeight weight,
    double height = 1.45,
    double spacing = 0,
    Color? color,
  }) {
    return GoogleFonts.hindSiliguri(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: spacing,
      color: color,
    );
  }

  static TextTheme _buildTextTheme(Color display, Color body) {
    return TextTheme(
      displayLarge: _serif(size: 48, weight: FontWeight.w700, height: 1.1),
      displayMedium: _serif(size: 40, weight: FontWeight.w700, height: 1.12),
      displaySmall: _serif(size: 34, weight: FontWeight.w700, height: 1.15),
      headlineLarge: _serif(size: 30, weight: FontWeight.w700, height: 1.2),
      headlineMedium: _serif(size: 26, weight: FontWeight.w700, height: 1.2),
      headlineSmall: _serif(size: 22, weight: FontWeight.w700),
      titleLarge: _serif(size: 20, weight: FontWeight.w600),
      titleMedium: _serif(size: 16, weight: FontWeight.w600, height: 1.3),
      titleSmall: _sans(size: 14, weight: FontWeight.w600, height: 1.35),
      bodyLarge: _sans(size: 16, weight: FontWeight.w400, height: 1.5),
      bodyMedium: _sans(size: 14, weight: FontWeight.w400),
      bodySmall: _sans(size: 12.5, weight: FontWeight.w400, height: 1.4),
      labelLarge: _sans(size: 14, weight: FontWeight.w600, height: 1.2),
      labelMedium: _sans(size: 12.5, weight: FontWeight.w600, height: 1.2),
      labelSmall: _sans(
        size: 11,
        weight: FontWeight.w600,
        height: 1.2,
        spacing: 0.3,
      ),
    ).apply(bodyColor: body, displayColor: display);
  }

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required Color background,
    required Color bodyColor,
    required Color hintColor,
    required SystemUiOverlayStyle overlay,
    required AppPalette palette,
  }) {
    final textTheme = _buildTextTheme(scheme.onSurface, bodyColor);
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
    );
    const buttonPadding = EdgeInsets.symmetric(vertical: 15, horizontal: 22);
    final buttonText = _sans(size: 15, weight: FontWeight.w600, height: 1.2);

    OutlineInputBorder inputBorder(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      extensions: [palette],
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,

      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        systemOverlayStyle: overlay.copyWith(
          statusBarColor: Colors.transparent,
        ),
        titleTextStyle: _serif(
          size: 20,
          weight: FontWeight.w700,
          color: scheme.onSurface,
        ),
        iconTheme: IconThemeData(color: scheme.onSurface, size: 22),
        actionsIconTheme: IconThemeData(color: scheme.onSurface, size: 22),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: inputBorder(scheme.outlineVariant),
        enabledBorder: inputBorder(scheme.outlineVariant),
        focusedBorder: inputBorder(scheme.primary, 1.8),
        errorBorder: inputBorder(scheme.error),
        focusedErrorBorder: inputBorder(scheme.error, 1.8),
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        hintStyle: _sans(size: 14.5, weight: FontWeight.w400, color: hintColor),
        labelStyle: _sans(
          size: 14.5,
          weight: FontWeight.w500,
          color: scheme.onSurfaceVariant,
        ),
        floatingLabelStyle: _sans(
          size: 14.5,
          weight: FontWeight.w600,
          color: scheme.primary,
        ),
        helperStyle: _sans(
          size: 12.5,
          weight: FontWeight.w400,
          color: scheme.onSurfaceVariant,
        ),
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: buttonShape,
          padding: buttonPadding,
          minimumSize: const Size(0, 52),
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          textStyle: buttonText,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          shape: buttonShape,
          padding: buttonPadding,
          minimumSize: const Size(0, 52),
          textStyle: buttonText,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: buttonShape,
          padding: buttonPadding,
          minimumSize: const Size(0, 52),
          side: BorderSide(color: scheme.outline, width: 1.2),
          foregroundColor: scheme.onSurface,
          textStyle: buttonText,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: _sans(size: 14, weight: FontWeight.w600, height: 1.2),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: scheme.onSurface),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: scheme.surface,
        selectedColor: scheme.primary,
        disabledColor: scheme.surfaceContainerHigh,
        checkmarkColor: scheme.onPrimary,
        showCheckmark: false,
        labelStyle: _sans(
          size: 13,
          weight: FontWeight.w600,
          height: 1.2,
          color: scheme.onSurface,
        ),
        secondaryLabelStyle: _sans(
          size: 13,
          weight: FontWeight.w600,
          height: 1.2,
          color: scheme.onPrimary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        side: BorderSide(color: scheme.outlineVariant),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        surfaceTintColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 68,
        elevation: 0,
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: scheme.primary,
        unselectedLabelColor: scheme.onSurfaceVariant,
        indicatorColor: scheme.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: scheme.outlineVariant,
        labelStyle: _sans(size: 14, weight: FontWeight.w700, height: 1.2),
        unselectedLabelStyle: _sans(
          size: 14,
          weight: FontWeight.w500,
          height: 1.2,
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 3,
        focusElevation: 4,
        hoverElevation: 4,
        highlightElevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        extendedTextStyle: buttonText,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
        titleTextStyle: _serif(
          size: 20,
          weight: FontWeight.w700,
          color: scheme.onSurface,
        ),
        contentTextStyle: _sans(
          size: 14.5,
          weight: FontWeight.w400,
          height: 1.5,
          color: bodyColor,
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        showDragHandle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xxl),
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        titleTextStyle: _sans(
          size: 15,
          weight: FontWeight.w600,
          height: 1.3,
          color: scheme.onSurface,
        ),
        subtitleTextStyle: _sans(
          size: 13,
          weight: FontWeight.w400,
          height: 1.4,
          color: scheme.onSurfaceVariant,
        ),
        iconColor: scheme.onSurfaceVariant,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return scheme.onPrimary;
          return scheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return scheme.primary;
          return scheme.surfaceContainerHighest;
        }),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.surfaceContainerHighest,
        thumbColor: scheme.primary,
        overlayColor: scheme.primary.withValues(alpha: 0.12),
        trackHeight: 5,
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
        circularTrackColor: Colors.transparent,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: _sans(
          size: 14,
          weight: FontWeight.w500,
          color: scheme.onInverseSurface,
        ),
        actionTextColor: scheme.inversePrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        elevation: 4,
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        textStyle: _sans(
          size: 14,
          weight: FontWeight.w500,
          color: scheme.onSurface,
        ),
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: _sans(
          size: 12,
          weight: FontWeight.w500,
          color: scheme.onInverseSurface,
        ),
      ),
    );
  }

  static final ThemeData lightTheme = _build(
    brightness: Brightness.light,
    scheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF1F5C4A),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFD5EADF),
      onPrimaryContainer: Color(0xFF0C3327),
      secondary: Color(0xFFB8690F),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFFBE7C9),
      onSecondaryContainer: Color(0xFF5A3306),
      tertiary: Color(0xFFB4493A),
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFFF9DFD8),
      onTertiaryContainer: Color(0xFF5C1D14),
      error: Color(0xFFB3261E),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFF9DEDC),
      onErrorContainer: Color(0xFF5F1410),
      surface: Color(0xFFFFFDF8),
      onSurface: Color(0xFF1D2A26),
      onSurfaceVariant: Color(0xFF5F6B66),
      outline: Color(0xFFB9B09C),
      outlineVariant: Color(0xFFE4DCCB),
      shadow: Colors.black,
      scrim: Colors.black,
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFFBF8F1),
      surfaceContainer: Color(0xFFF4EFE3),
      surfaceContainerHigh: Color(0xFFEFE8D9),
      surfaceContainerHighest: Color(0xFFE9E1CF),
      inverseSurface: Color(0xFF26332E),
      onInverseSurface: Color(0xFFF4F1E8),
      inversePrimary: Color(0xFF8FD6B8),
    ),
    background: const Color(0xFFF7F3EA),
    bodyColor: const Color(0xFF36423E),
    hintColor: const Color(0xFF8E968F),
    overlay: SystemUiOverlayStyle.dark,
    palette: AppPalette.light,
  );

  static final ThemeData darkTheme = _build(
    brightness: Brightness.dark,
    scheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF7FD1B0),
      onPrimary: Color(0xFF06382A),
      primaryContainer: Color(0xFF174A3B),
      onPrimaryContainer: Color(0xFFC9EEDD),
      secondary: Color(0xFFF0B062),
      onSecondary: Color(0xFF45290A),
      secondaryContainer: Color(0xFF5A3A0E),
      onSecondaryContainer: Color(0xFFFCE5C2),
      tertiary: Color(0xFFF09A8B),
      onTertiary: Color(0xFF4A160E),
      tertiaryContainer: Color(0xFF5E2319),
      onTertiaryContainer: Color(0xFFFBDAD3),
      error: Color(0xFFF2B8B5),
      onError: Color(0xFF601410),
      errorContainer: Color(0xFF8C1D18),
      onErrorContainer: Color(0xFFF9DEDC),
      surface: Color(0xFF1A2420),
      onSurface: Color(0xFFEDF2EC),
      onSurfaceVariant: Color(0xFF9DAAA3),
      outline: Color(0xFF5A6961),
      outlineVariant: Color(0xFF2F3B35),
      shadow: Colors.black,
      scrim: Colors.black,
      surfaceContainerLowest: Color(0xFF0E1512),
      surfaceContainerLow: Color(0xFF18211D),
      surfaceContainer: Color(0xFF1F2A25),
      surfaceContainerHigh: Color(0xFF26332D),
      surfaceContainerHighest: Color(0xFF2E3C35),
      inverseSurface: Color(0xFFEDF2EC),
      onInverseSurface: Color(0xFF1D2A26),
      inversePrimary: Color(0xFF1F5C4A),
    ),
    background: const Color(0xFF121A17),
    bodyColor: const Color(0xFFC9D2CC),
    hintColor: const Color(0xFF74817A),
    overlay: SystemUiOverlayStyle.light,
    palette: AppPalette.dark,
  );
}
