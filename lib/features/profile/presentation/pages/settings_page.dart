import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/design/design.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/firebase_service.dart';
import '../../../../core/utils/constants.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

/// Version shown on the profile, settings and about screens.
const String appVersionLabel = '1.0.1';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
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
              label: 'Legal',
              children: [
                ProfileMenuRow(
                  icon: LucideIcons.shieldCheck,
                  title: 'Privacy policy',
                  subtitle: 'What we collect and how we use it',
                  onTap: () => context.push(RoutePaths.privacyPolicy),
                ),
                ProfileMenuRow(
                  icon: LucideIcons.fileText,
                  title: 'Terms & conditions',
                  subtitle: 'The rules for using Boichokro',
                  onTap: () => context.push(RoutePaths.termsConditions),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            ProfileMenuGroup(
              label: 'About',
              children: [
                ProfileMenuRow(
                  icon: LucideIcons.info,
                  title: 'About Boichokro',
                  onTap: () => context.push(RoutePaths.about),
                ),
                ProfileMenuRow(
                  icon: LucideIcons.smartphone,
                  tone: AppTone.neutral,
                  title: 'App version',
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
              label: 'Account',
              children: [
                ProfileMenuRow(
                  icon: LucideIcons.trash2,
                  tone: AppTone.danger,
                  title: 'Delete account',
                  subtitle: 'Permanently delete your account and data',
                  onTap: () => _showDeleteAccountDialog(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final danger = context.tone(AppTone.danger);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(LucideIcons.triangleAlert, color: danger.solid, size: 36),
        title: const Text('Delete your account?'),
        content: const Text(
          'This action cannot be undone. All your data including books, exchanges, and messages will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
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
            child: const Text('Delete account'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final authBloc = getIt<AuthBloc>();
    final currentUser = getIt<FirebaseService>().auth.currentUser;

    if (currentUser == null) return;

    // Show loading
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PopScope(
        canPop: false,
        child: Center(
          child: AppCard(
            padding: EdgeInsets.all(AppSpacing.xxl),
            child: SizedBox(
              width: 220,
              height: 96,
              child: AppLoading(message: 'Deleting your account…'),
            ),
          ),
        ),
      ),
    );

    try {
      // Delete user data from Firestore
      await getIt<FirebaseService>().firestore
          .collection('users')
          .doc(currentUser.uid)
          .delete();

      // Sign out and delete auth account
      await currentUser.delete();
      authBloc.add(const SignOut());

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading
        showAppSnack(
          context,
          'Your account has been deleted',
          tone: AppTone.success,
        );
        context.go(RoutePaths.auth);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading
        showAppSnack(
          context,
          'Failed to delete account: $e',
          tone: AppTone.danger,
        );
      }
    }
  }
}
