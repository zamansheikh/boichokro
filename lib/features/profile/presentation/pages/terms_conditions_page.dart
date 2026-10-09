import 'package:flutter/material.dart';
import 'privacy_policy_page.dart' show LegalDocumentView, LegalSection;

/// Terms and Conditions Page
class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  static const List<LegalSection> _sections = [
    LegalSection(
      'Agreement to Terms',
      'By accessing and using Boichokro, you accept and agree to be bound by these Terms and Conditions. If you do not agree, please do not use our service.',
    ),
    LegalSection(
      'Use of Service',
      'You agree to use Boichokro only for lawful purposes and in accordance with these Terms. You must:\n\n'
          '• Be at least 13 years old\n'
          '• Provide accurate information\n'
          '• Keep your account credentials secure\n'
          '• Not impersonate others\n'
          '• Not engage in fraudulent activities',
    ),
    LegalSection(
      'Book Exchanges and Donations',
      'Boichokro is a platform to facilitate book exchanges and donations. We are not responsible for:\n\n'
          '• The condition or quality of books\n'
          '• Failed exchanges or disputes\n'
          '• Lost or damaged books\n'
          '• Interactions between users\n\n'
          'All exchanges are at your own risk.',
    ),
    LegalSection(
      'Content Ownership',
      'You retain ownership of content you post (book photos, descriptions, messages). By posting content, you grant us a license to use, display, and distribute it as necessary to provide our services.',
    ),
    LegalSection(
      'Prohibited Activities',
      'You may not:\n\n'
          '• Post false or misleading information\n'
          '• Sell counterfeit or illegal books\n'
          '• Harass or threaten other users\n'
          '• Spam or send unsolicited messages\n'
          '• Attempt to hack or disrupt the service\n'
          '• Violate any laws or regulations',
    ),
    LegalSection(
      'Account Termination',
      'We reserve the right to suspend or terminate your account at any time for violating these Terms or for any other reason at our discretion.',
    ),
    LegalSection(
      'Limitation of Liability',
      'Boichokro is provided "as is" without warranties. We are not liable for any damages arising from your use of the service, including but not limited to:\n\n'
          '• Loss or damage to books\n'
          '• Disputes with other users\n'
          '• Data loss or security breaches\n'
          '• Service interruptions',
    ),
    LegalSection(
      'Intellectual Property',
      'All rights, title, and interest in Boichokro (excluding user content) belong to us. You may not copy, modify, or distribute our intellectual property without permission.',
    ),
    LegalSection(
      'Changes to Terms',
      'We may modify these Terms at any time. We will notify you of significant changes. Continued use after changes constitutes acceptance.',
    ),
    LegalSection(
      'Contact Information',
      'For questions about these Terms, contact us at:\n\n'
          'Email: support@boichokro.com',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms & Conditions')),
      body: const LegalDocumentView(
        title: 'Terms and Conditions',
        lastUpdated: 'Last updated: December 2024',
        sections: _sections,
      ),
    );
  }
}
