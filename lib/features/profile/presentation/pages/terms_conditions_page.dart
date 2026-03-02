import 'package:flutter/material.dart';

/// Terms and Conditions Page
class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Terms & Conditions')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms and Conditions',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: December 2024',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              'Agreement to Terms',
              'By accessing and using Boichokro, you accept and agree to be bound by these Terms and Conditions. If you do not agree, please do not use our service.',
            ),

            _buildSection(
              context,
              'Use of Service',
              'You agree to use Boichokro only for lawful purposes and in accordance with these Terms. You must:\n\n'
                  '• Be at least 13 years old\n'
                  '• Provide accurate information\n'
                  '• Keep your account credentials secure\n'
                  '• Not impersonate others\n'
                  '• Not engage in fraudulent activities',
            ),

            _buildSection(
              context,
              'Book Exchanges and Donations',
              'Boichokro is a platform to facilitate book exchanges and donations. We are not responsible for:\n\n'
                  '• The condition or quality of books\n'
                  '• Failed exchanges or disputes\n'
                  '• Lost or damaged books\n'
                  '• Interactions between users\n\n'
                  'All exchanges are at your own risk.',
            ),

            _buildSection(
              context,
              'Content Ownership',
              'You retain ownership of content you post (book photos, descriptions, messages). By posting content, you grant us a license to use, display, and distribute it as necessary to provide our services.',
            ),

            _buildSection(
              context,
              'Prohibited Activities',
              'You may not:\n\n'
                  '• Post false or misleading information\n'
                  '• Sell counterfeit or illegal books\n'
                  '• Harass or threaten other users\n'
                  '• Spam or send unsolicited messages\n'
                  '• Attempt to hack or disrupt the service\n'
                  '• Violate any laws or regulations',
            ),

            _buildSection(
              context,
              'Account Termination',
              'We reserve the right to suspend or terminate your account at any time for violating these Terms or for any other reason at our discretion.',
            ),

            _buildSection(
              context,
              'Limitation of Liability',
              'Boichokro is provided "as is" without warranties. We are not liable for any damages arising from your use of the service, including but not limited to:\n\n'
                  '• Loss or damage to books\n'
                  '• Disputes with other users\n'
                  '• Data loss or security breaches\n'
                  '• Service interruptions',
            ),

            _buildSection(
              context,
              'Intellectual Property',
              'All rights, title, and interest in Boichokro (excluding user content) belong to us. You may not copy, modify, or distribute our intellectual property without permission.',
            ),

            _buildSection(
              context,
              'Changes to Terms',
              'We may modify these Terms at any time. We will notify you of significant changes. Continued use after changes constitutes acceptance.',
            ),

            _buildSection(
              context,
              'Contact Information',
              'For questions about these Terms, contact us at:\n\n'
                  'Email: support@boichokro.com',
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(content, style: textTheme.bodyMedium?.copyWith(height: 1.6)),
        ],
      ),
    );
  }
}
