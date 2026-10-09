import 'package:flutter/material.dart';

import '../design/tokens.dart';
import 'l10n.dart';

/// Two-way language pill: বাংলা first, then English. Changes the whole app
/// immediately and remembers the choice.
///
/// Set [onDark] when it sits on the brand gradient.
class LanguageSwitch extends StatelessWidget {
  const LanguageSwitch({super.key, this.onDark = false});

  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final controller = LocaleController.instance;
    final track = onDark
        ? Colors.white.withValues(alpha: 0.14)
        : colors.surface;
    final border = onDark
        ? Colors.white.withValues(alpha: 0.22)
        : colors.outlineVariant;
    final selectedFill = onDark ? context.palette.onHero : colors.primary;
    final selectedText = onDark ? context.palette.heroEnd : colors.onPrimary;
    final idleText = onDark
        ? context.palette.onHero.withValues(alpha: 0.85)
        : colors.onSurfaceVariant;

    Widget segment(Locale locale, String label) {
      final selected = controller.value == locale;
      return Material(
        color: selected ? selectedFill : Colors.transparent,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: selected ? null : () => controller.setLocale(locale),
          child: Container(
            constraints: const BoxConstraints(minWidth: 62, minHeight: 36),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              label,
              style: context.text.labelMedium?.copyWith(
                color: selected ? selectedText : idleText,
                fontSize: 13,
              ),
            ),
          ),
        ),
      );
    }

    return ValueListenableBuilder<Locale>(
      valueListenable: controller,
      builder: (context, _, _) => Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: track,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            segment(LocaleController.bangla, context.core.languageBangla),
            segment(LocaleController.english, context.core.languageEnglish),
          ],
        ),
      ),
    );
  }
}
