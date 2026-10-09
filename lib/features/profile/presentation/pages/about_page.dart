import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/design/design.dart';
import '../../../../l10n/account/gen/account_l10n.dart';
import 'settings_page.dart'
    show ProfileMenuGroup, ProfileMenuRow, appVersionLabel;

/// About Page
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final muted = context.colors.onSurfaceVariant;
    final l = AccountL10n.of(context);
    final appName = context.core.appName;

    return Scaffold(
      appBar: AppBar(title: Text(l.aboutTitle)),
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
                    appName,
                    textAlign: TextAlign.center,
                    style: context.text.headlineLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l.brandAltName,
                    textAlign: TextAlign.center,
                    style: context.text.titleMedium?.copyWith(color: muted),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    context.core.appTagline,
                    textAlign: TextAlign.center,
                    style: context.text.bodyLarge?.copyWith(color: muted),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: StatusPill(
                      label: l.aboutVersion(appVersionLabel),
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
                        Eyebrow(l.aboutMissionLabel),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          l.aboutMissionBody(appName),
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
                  ProfileMenuGroup(
                    label: l.aboutFeaturesLabel,
                    children: [
                      ProfileMenuRow(
                        icon: LucideIcons.mapPin,
                        title: l.aboutFeatureDiscoverTitle,
                        subtitle: l.aboutFeatureDiscoverBody,
                      ),
                      ProfileMenuRow(
                        icon: LucideIcons.repeat,
                        tone: AppTone.exchange,
                        title: l.aboutFeatureExchangeTitle,
                        subtitle: l.aboutFeatureExchangeBody,
                      ),
                      ProfileMenuRow(
                        icon: LucideIcons.messageCircle,
                        tone: AppTone.donate,
                        title: l.aboutFeatureConnectTitle,
                        subtitle: l.aboutFeatureConnectBody,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Contact
                  ProfileMenuGroup(
                    label: l.aboutContactLabel,
                    children: [
                      ProfileMenuRow(
                        icon: LucideIcons.mail,
                        title: l.aboutEmailUs,
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
                        title: l.aboutVisitWebsite,
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
                    l.aboutMadeWith,
                    textAlign: TextAlign.center,
                    style: context.text.bodySmall?.copyWith(color: muted),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l.aboutCopyright(appName),
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
      showAppSnack(context, AccountL10n.of(context).aboutNoEmailApp(email));
    }
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      showAppSnack(context, AccountL10n.of(context).aboutCouldNotOpen(url));
    }
  }
}
