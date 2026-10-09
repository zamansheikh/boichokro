import 'package:flutter/material.dart';

/// Spacing scale (4pt grid).
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Horizontal page gutter used by every screen.
  static const double page = 20;

  /// Bottom padding that clears the floating navigation bar.
  static const double navClearance = 112;
}

/// Corner radius scale.
class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double pill = 999;
}

/// Motion durations.
class AppMotion {
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration medium = Duration(milliseconds: 260);
  static const Duration slow = Duration(milliseconds: 420);
  static const Curve curve = Curves.easeOutCubic;
}

/// Semantic tone shared by badges, pills, banners and snackbars.
enum AppTone { neutral, primary, donate, exchange, success, warning, danger }

/// Foreground / background pair resolved from an [AppTone].
class ToneColors {
  const ToneColors({
    required this.foreground,
    required this.background,
    required this.solid,
  });

  /// Text and icon colour on top of [background].
  final Color foreground;

  /// Soft container colour.
  final Color background;

  /// Saturated colour for dots, icons on plain surfaces and filled shapes.
  final Color solid;
}

/// Brand colours that Material's [ColorScheme] has no slot for.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.donate,
    required this.donateContainer,
    required this.onDonateContainer,
    required this.exchange,
    required this.exchangeContainer,
    required this.onExchangeContainer,
    required this.success,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.star,
    required this.softShadow,
    required this.heroStart,
    required this.heroEnd,
    required this.onHero,
  });

  final Color donate;
  final Color donateContainer;
  final Color onDonateContainer;
  final Color exchange;
  final Color exchangeContainer;
  final Color onExchangeContainer;
  final Color success;
  final Color successContainer;
  final Color onSuccessContainer;
  final Color warning;
  final Color warningContainer;
  final Color onWarningContainer;
  final Color star;
  final Color softShadow;

  /// Gradient used by brand hero surfaces (splash, auth, profile header).
  final Color heroStart;
  final Color heroEnd;
  final Color onHero;

  static const AppPalette light = AppPalette(
    donate: Color(0xFFB4493A),
    donateContainer: Color(0xFFF9DFD8),
    onDonateContainer: Color(0xFF5C1D14),
    exchange: Color(0xFFB8690F),
    exchangeContainer: Color(0xFFFBE7C9),
    onExchangeContainer: Color(0xFF5A3306),
    success: Color(0xFF1F7A55),
    successContainer: Color(0xFFD6EFE2),
    onSuccessContainer: Color(0xFF0C3A27),
    warning: Color(0xFFA9700F),
    warningContainer: Color(0xFFFAEBC8),
    onWarningContainer: Color(0xFF4F3403),
    star: Color(0xFFE0A106),
    softShadow: Color(0x1A3B2F1A),
    heroStart: Color(0xFF1F5C4A),
    heroEnd: Color(0xFF123B30),
    onHero: Color(0xFFFFFDF8),
  );

  static const AppPalette dark = AppPalette(
    donate: Color(0xFFF09A8B),
    donateContainer: Color(0xFF5E2319),
    onDonateContainer: Color(0xFFFBDAD3),
    exchange: Color(0xFFF0B062),
    exchangeContainer: Color(0xFF5A3A0E),
    onExchangeContainer: Color(0xFFFCE5C2),
    success: Color(0xFF7FD1B0),
    successContainer: Color(0xFF174A3B),
    onSuccessContainer: Color(0xFFC9EEDD),
    warning: Color(0xFFEDC062),
    warningContainer: Color(0xFF523A08),
    onWarningContainer: Color(0xFFFBE9C0),
    star: Color(0xFFF2C14B),
    softShadow: Color(0x66000000),
    heroStart: Color(0xFF1C4A3C),
    heroEnd: Color(0xFF0F2A22),
    onHero: Color(0xFFEDF2EC),
  );

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      donate: mix(donate, other.donate),
      donateContainer: mix(donateContainer, other.donateContainer),
      onDonateContainer: mix(onDonateContainer, other.onDonateContainer),
      exchange: mix(exchange, other.exchange),
      exchangeContainer: mix(exchangeContainer, other.exchangeContainer),
      onExchangeContainer: mix(onExchangeContainer, other.onExchangeContainer),
      success: mix(success, other.success),
      successContainer: mix(successContainer, other.successContainer),
      onSuccessContainer: mix(onSuccessContainer, other.onSuccessContainer),
      warning: mix(warning, other.warning),
      warningContainer: mix(warningContainer, other.warningContainer),
      onWarningContainer: mix(onWarningContainer, other.onWarningContainer),
      star: mix(star, other.star),
      softShadow: mix(softShadow, other.softShadow),
      heroStart: mix(heroStart, other.heroStart),
      heroEnd: mix(heroEnd, other.heroEnd),
      onHero: mix(onHero, other.onHero),
    );
  }
}

/// Shorthand accessors so widgets read `context.colors.primary` instead of
/// `Theme.of(context).colorScheme.primary`.
extension AppThemeContext on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;

  ToneColors tone(AppTone tone) {
    final c = colors;
    final p = palette;
    switch (tone) {
      case AppTone.neutral:
        return ToneColors(
          foreground: c.onSurfaceVariant,
          background: c.surfaceContainerHighest,
          solid: c.onSurfaceVariant,
        );
      case AppTone.primary:
        return ToneColors(
          foreground: c.onPrimaryContainer,
          background: c.primaryContainer,
          solid: c.primary,
        );
      case AppTone.donate:
        return ToneColors(
          foreground: p.onDonateContainer,
          background: p.donateContainer,
          solid: p.donate,
        );
      case AppTone.exchange:
        return ToneColors(
          foreground: p.onExchangeContainer,
          background: p.exchangeContainer,
          solid: p.exchange,
        );
      case AppTone.success:
        return ToneColors(
          foreground: p.onSuccessContainer,
          background: p.successContainer,
          solid: p.success,
        );
      case AppTone.warning:
        return ToneColors(
          foreground: p.onWarningContainer,
          background: p.warningContainer,
          solid: p.warning,
        );
      case AppTone.danger:
        return ToneColors(
          foreground: c.onErrorContainer,
          background: c.errorContainer,
          solid: c.error,
        );
    }
  }

  /// Soft, warm elevation used by cards and floating surfaces.
  List<BoxShadow> get softShadow => [
    BoxShadow(
      color: palette.softShadow,
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];
}
