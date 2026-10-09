import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/design/design.dart';
import 'settings_page.dart'
    show ProfileMenuGroup, ProfileMenuRow, appVersionLabel;

/// About Page
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final muted = context.colors.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.lg,
            AppSpacing.page,
            AppSpacing.xxxl,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Identity
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      child: Image.asset(
                        'assets/icon/icon.png',
                        width: 88,
                        height: 88,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Boichokro',
                    textAlign: TextAlign.center,
                    style: context.text.headlineLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'বইচক্র',
                    textAlign: TextAlign.center,
                    style: context.text.titleMedium?.copyWith(color: muted),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Books that keep moving',
                    textAlign: TextAlign.center,
                    style: context.text.bodyLarge?.copyWith(color: muted),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Center(
                    child: StatusPill(
                      label: 'Version $appVersionLabel',
                      tone: AppTone.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),

                  // Mission
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Eyebrow('Our mission'),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Boichokro is a community-driven platform that connects book lovers to exchange and donate books. We believe in making knowledge accessible to everyone and reducing waste by giving books a second life.',
                          style: context.text.titleMedium?.copyWith(
                            height: 1.6,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Features
                  const ProfileMenuGroup(
                    label: 'What you can do',
                    children: [
                      ProfileMenuRow(
                        icon: LucideIcons.mapPin,
                        title: 'Discover nearby',
                        subtitle:
                            'Find books available for exchange or donation in your area',
                      ),
                      ProfileMenuRow(
                        icon: LucideIcons.repeat,
                        tone: AppTone.exchange,
                        title: 'Exchange & donate',
                        subtitle:
                            'Share your books with others through exchange or donation',
                      ),
                      ProfileMenuRow(
                        icon: LucideIcons.messageCircle,
                        tone: AppTone.donate,
                        title: 'Connect',
                        subtitle:
                            'Chat with book owners and build a reading community',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Contact
                  ProfileMenuGroup(
                    label: 'Get in touch',
                    children: [
                      ProfileMenuRow(
                        icon: LucideIcons.mail,
                        title: 'Email us',
                        subtitle: 'support@boichokro.com',
                        trailing: Icon(
                          LucideIcons.externalLink,
                          size: 16,
                          color: muted,
                        ),
                        onTap: () =>
                            _launchEmail(context, 'support@boichokro.com'),
                      ),
                      ProfileMenuRow(
                        icon: LucideIcons.globe,
                        title: 'Visit our website',
                        subtitle: 'www.boichokro.com',
                        trailing: Icon(
                          LucideIcons.externalLink,
                          size: 16,
                          color: muted,
                        ),
                        onTap: () =>
                            _launchUrl(context, 'https://www.boichokro.com'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxxl),

                  // Footer
                  Text(
                    'Made with ❤️ for book lovers',
                    textAlign: TextAlign.center,
                    style: context.text.bodySmall?.copyWith(color: muted),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '© 2024 Boichokro. All rights reserved.',
                    textAlign: TextAlign.center,
                    style: context.text.bodySmall?.copyWith(color: muted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchEmail(BuildContext context, String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      showAppSnack(context, 'No email app found. Write to us at $email');
    }
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      showAppSnack(context, 'Could not open $url');
    }
  }
}
