import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/design/design.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/firebase_service.dart';
import '../../../../core/utils/constants.dart';
import '../../../../l10n/account/gen/account_l10n.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

/// Version shown on the profile, settings and about screens.
const String appVersionLabel = '1.1.0';

/// A labelled group of [ProfileMenuRow]s inside one paper card.
///
/// Shared by the profile, settings and about screens.
class ProfileMenuGroup extends StatelessWidget {
  const ProfileMenuGroup({super.key, this.label, required this.children});

  final String? label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.xs,
              bottom: AppSpacing.sm,
            ),
            child: Eyebrow(label!),
          ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                if (i > 0) const Divider(indent: 68, endIndent: AppSpacing.lg),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// One row in a [ProfileMenuGroup]: tinted icon, title, optional subtitle and
/// a chevron when it navigates somewhere.
class ProfileMenuRow extends StatelessWidget {
  const ProfileMenuRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.tone = AppTone.primary,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final AppTone tone;

  /// Replaces the chevron, e.g. a value or an external-link icon.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final toneColors = context.tone(tone);
    final isDanger = tone == AppTone.danger;

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 60),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: toneColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, size: 18, color: toneColors.foreground),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleSmall?.copyWith(
                        fontSize: 15,
                        color: isDanger
                            ? toneColors.solid
                            : context.colors.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.md),
                trailing!,
              ] else if (onTap != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  LucideIcons.chevronRight,
                  size: 18,
                  color: context.colors.onSurfaceVariant,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Settings Page
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AccountL10n.of(context);
    final appName = context.core.appName;

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.sm,
            AppSpacing.page,
            AppSpacing.xxxl,
          ),
          children: [
            ProfileMenuGroup(
              label: l.settingsGroupPreferences,
              children: const [_LanguageRow()],
            ),
            const SizedBox(height: AppSpacing.xxl),
            ProfileMenuGroup(
              label: l.legalLabel,
              children: [
                ProfileMenuRow(
                  icon: LucideIcons.shieldCheck,
                  title: l.settingsPrivacyTitle,
                  subtitle: l.settingsPrivacySubtitle,
                  onTap: () => context.push(RoutePaths.privacyPolicy),
                ),
                ProfileMenuRow(
                  icon: LucideIcons.fileText,
                  title: l.settingsTermsTitle,
                  subtitle: l.settingsTermsSubtitle(appName),
                  onTap: () => context.push(RoutePaths.termsConditions),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            ProfileMenuGroup(
              label: l.settingsGroupAbout,
              children: [
                ProfileMenuRow(
                  icon: LucideIcons.info,
                  title: l.settingsAboutTitle(appName),
                  subtitle: l.settingsAboutSubtitle,
                  onTap: () => context.push(RoutePaths.about),
                ),
                ProfileMenuRow(
                  icon: LucideIcons.smartphone,
                  tone: AppTone.neutral,
                  title: l.settingsAppVersion,
                  trailing: Text(
                    appVersionLabel,
                    style: context.text.labelLarge?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            ProfileMenuGroup(
              label: l.settingsGroupAccount,
              children: [
                ProfileMenuRow(
                  icon: LucideIcons.logOut,
                  tone: AppTone.neutral,
                  title: l.settingsSignOut,
                  subtitle: l.settingsSignOutSubtitle,
                  onTap: () => _showSignOutDialog(context),
                ),
                ProfileMenuRow(
                  icon: LucideIcons.trash2,
                  tone: AppTone.danger,
                  title: l.settingsDeleteAccount,
                  subtitle: l.settingsDeleteAccountSubtitle,
                  onTap: () => _showDeleteAccountDialog(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    final l = AccountL10n.of(context);
    final cancelLabel = context.core.commonCancel;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(LucideIcons.logOut, color: context.colors.primary, size: 32),
        title: Text(l.settingsSignOutTitle),
        content: Text(l.settingsSignOutBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(cancelLabel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);

              // Sign out from Firebase and Google
              final authBloc = getIt<AuthBloc>();
              authBloc.add(const SignOut());

              // Show confirmation and navigate
              showAppSnack(context, l.settingsSignedOutSnack);

              // Navigate to auth
              context.go(RoutePaths.auth);
            },
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
            child: Text(l.settingsSignOut),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final danger = context.tone(AppTone.danger);
    final l = AccountL10n.of(context);
    final cancelLabel = context.core.commonCancel;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(LucideIcons.triangleAlert, color: danger.solid, size: 36),
        title: Text(l.settingsDeleteAccountTitle),
        content: Text(l.settingsDeleteAccountBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(cancelLabel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _deleteAccount(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.error,
              foregroundColor: context.colors.onError,
            ),
            child: Text(l.settingsDeleteAccount),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final authBloc = getIt<AuthBloc>();
    final currentUser = getIt<FirebaseService>().auth.currentUser;

    if (currentUser == null) return;

    // Read before the awaits below; the messages are shown afterwards.
    final l = AccountL10n.of(context);

    // Show loading
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Center(
          child: AppCard(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: SizedBox(
              width: 220,
              height: 96,
              child: AppLoading(message: l.settingsDeletingAccount),
            ),
          ),
        ),
      ),
    );

    final userDoc = getIt<FirebaseService>().firestore
        .collection('users')
        .doc(currentUser.uid);
    Map<String, dynamic>? backup;

    try {
      // The profile has to go first: once the auth account is deleted the
      // user can no longer touch their own document. Keep a copy so it can be
      // put back if the auth deletion is refused.
      backup = (await userDoc.get()).data();
      await userDoc.delete();

      // Sign out and delete auth account
      await currentUser.delete();
      authBloc.add(const SignOut());

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading
        showAppSnack(context, l.settingsAccountDeleted, tone: AppTone.success);
        context.go(RoutePaths.auth);
      }
    } catch (e) {
      // Firebase refuses to delete an account that signed in long ago; restore
      // the profile so nothing is half-deleted.
      final restore = backup;
      if (restore != null) {
        try {
          await userDoc.set(restore);
        } catch (_) {}
      }
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading
        final needsLogin = e.toString().contains('requires-recent-login');
        showAppSnack(
          context,
          needsLogin ? l.settingsDeleteNeedsLogin : l.settingsDeleteFailed,
          tone: AppTone.danger,
        );
      }
    }
  }
}

/// Language choice: the usual icon, title and subtitle, with the switch
/// beneath them so the text keeps its full width on narrow phones.
class _LanguageRow extends StatelessWidget {
  const _LanguageRow();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ProfileMenuRow(
          icon: LucideIcons.languages,
          title: context.core.languageTitle,
          subtitle: context.core.languageSubtitle,
        ),
        const Padding(
          // Lines the switch up with the row's text.
          padding: EdgeInsets.only(
            left: AppSpacing.lg + 36 + AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.lg,
          ),
          child: LanguageSwitch(),
        ),
      ],
    );
  }
}
