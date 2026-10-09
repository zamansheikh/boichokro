import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/design/design.dart';
import '../../../../l10n/account/gen/account_l10n.dart';

/// One titled section of a legal document.
class LegalSection {
  const LegalSection(this.title, this.content);

  final String title;
  final String content;
}

/// Comfortable reading layout shared by the privacy policy and the terms:
/// serif headings, generous line height and a capped line length.
class LegalDocumentView extends StatelessWidget {
  const LegalDocumentView({
    super.key,
    required this.title,
    required this.lastUpdated,
    required this.sections,
  });

  /// Heading of the document itself, kept in its approved English wording.
  final String title;

  /// Month the document was last revised; shown in the reader's language.
  final DateTime lastUpdated;

  /// The approved English clauses. These are never translated.
  final List<LegalSection> sections;

  @override
  Widget build(BuildContext context) {
    final l = AccountL10n.of(context);
    final showEnglishOnlyNotice =
        Localizations.localeOf(context).languageCode !=
        LocaleController.english.languageCode;

    return SafeArea(
      top: false,
      child: SelectionArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.sm,
            AppSpacing.page,
            AppSpacing.xxxl,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showEnglishOnlyNotice) ...[
                    AppBanner(
                      tone: AppTone.neutral,
                      icon: LucideIcons.languages,
                      message: l.legalEnglishOnlyNotice,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                  Eyebrow(l.legalLabel),
                  const SizedBox(height: AppSpacing.sm),
                  Text(title, style: context.text.headlineMedium),
                  const SizedBox(height: AppSpacing.md),
                  MetaItem(
                    icon: LucideIcons.calendarDays,
                    label: l.legalLastUpdated(
                      context.date(lastUpdated, 'MMMM yyyy'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  for (int i = 0; i < sections.length; i++) ...[
                    if (i > 0) ...[
                      const SizedBox(height: AppSpacing.xxl),
                      const Divider(),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                    _LegalSectionView(section: sections[i]),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LegalSectionView extends StatelessWidget {
  const _LegalSectionView({required this.section});

  final LegalSection section;

  @override
  Widget build(BuildContext context) {
    final body = context.text.bodyLarge?.copyWith(fontSize: 15, height: 1.6);
    final lines = section.content.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(section.title, style: context.text.titleLarge),
        const SizedBox(height: AppSpacing.md),
        for (final line in lines)
          if (line.isEmpty)
            const SizedBox(height: AppSpacing.md)
          else if (line.startsWith('• '))
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: AppSpacing.xl,
                    child: Text(
                      '•',
                      style: body?.copyWith(color: context.colors.primary),
                    ),
                  ),
                  Expanded(child: Text(line.substring(2), style: body)),
                ],
              ),
            )
          else
            Text(line, style: body),
      ],
    );
  }
}

/// Privacy Policy Page
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const List<LegalSection> _sections = [
    LegalSection(
      'Introduction',
      'Boichokro ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and share your personal information when you use our book exchange platform.',
    ),
    LegalSection(
      'Information We Collect',
      'We collect information you provide directly to us, including:\n\n'
          '• Account information (name, email, profile photo from Google Sign-In)\n'
          '• Book information (title, author, photos, location)\n'
          '• Messages and communications\n'
          '• Location data (when you share books)\n'
          '• Usage data and analytics',
    ),
    LegalSection(
      'How We Use Your Information',
      'We use the information we collect to:\n\n'
          '• Provide, maintain, and improve our services\n'
          '• Connect you with other book lovers\n'
          '• Show you books available nearby\n'
          '• Facilitate book exchanges and donations\n'
          '• Send you updates and notifications\n'
          '• Protect against fraud and abuse',
    ),
    LegalSection(
      'Information Sharing',
      'We share your information only:\n\n'
          '• With other users for book exchanges (name, profile photo, location proximity)\n'
          '• With service providers who assist our operations\n'
          '• When required by law\n'
          '• With your consent\n\n'
          'We never sell your personal information.',
    ),
    LegalSection(
      'Data Security',
      'We implement appropriate security measures to protect your information. However, no method of transmission over the Internet is 100% secure.',
    ),
    LegalSection(
      'Your Rights',
      'You have the right to:\n\n'
          '• Access your personal data\n'
          '• Correct inaccurate data\n'
          '• Delete your account and data\n'
          '• Opt-out of certain data collection\n'
          '• Export your data',
    ),
    LegalSection(
      'Children\'s Privacy',
      'Our service is not intended for children under 13. We do not knowingly collect information from children under 13.',
    ),
    LegalSection(
      'Changes to This Policy',
      'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new policy on this page.',
    ),
    LegalSection(
      'Contact Us',
      'If you have questions about this Privacy Policy, please contact us at:\n\n'
          'Email: privacy@boichokro.com',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AccountL10n.of(context).legalPrivacyTitle)),
      body: LegalDocumentView(
        title: 'Privacy Policy for Boichokro',
        lastUpdated: DateTime(2024, 12),
        sections: _sections,
      ),
    );
  }
}
