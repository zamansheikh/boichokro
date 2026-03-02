import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/firebase_service.dart';
import '../../../../core/utils/constants.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

/// Settings Page
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          // Legal Section
          _buildSectionHeader(context, 'Legal'),
          _buildSettingsTile(
            context,
            icon: LucideIcons.shieldAlert,
            title: 'Privacy Policy',
            onTap: () => context.push(RoutePaths.privacyPolicy),
          ),
          _buildSettingsTile(
            context,
            icon: LucideIcons.fileText,
            title: 'Terms & Conditions',
            onTap: () => context.push(RoutePaths.termsConditions),
          ),

          const SizedBox(height: 16),

          // About Section
          _buildSectionHeader(context, 'About'),
          _buildSettingsTile(
            context,
            icon: LucideIcons.info,
            title: 'About Boichokro',
            onTap: () => context.push(RoutePaths.about),
          ),
          _buildSettingsTile(
            context,
            icon: LucideIcons.code,
            title: 'App Version',
            subtitle: '1.0.0',
            onTap: null,
          ),

          const SizedBox(height: 16),

          // Account Section
          _buildSectionHeader(context, 'Account'),
          _buildSettingsTile(
            context,
            icon: LucideIcons.trash2,
            title: 'Delete Account',
            subtitle: 'Permanently delete your account and data',
            titleColor: colorScheme.error,
            iconColor: colorScheme.error,
            onTap: () => _showDeleteAccountDialog(context),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: textTheme.titleSmall?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    Color? iconColor,
    required VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor ?? colorScheme.primary, size: 20),
        ),
        title: Text(
          title,
          style: textTheme.titleSmall?.copyWith(color: titleColor),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        trailing: onTap != null
            ? Icon(
                LucideIcons.chevronRight,
                color: colorScheme.onSurfaceVariant,
              )
            : null,
        onTap: onTap,
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          LucideIcons.alertTriangle,
          color: colorScheme.error,
          size: 48,
        ),
        title: const Text('Delete Account?'),
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
            style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
            child: const Text('Delete Account'),
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deleted successfully')),
        );
        context.go(RoutePaths.auth);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete account: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
