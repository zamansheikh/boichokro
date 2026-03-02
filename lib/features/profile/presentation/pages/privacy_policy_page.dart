import 'package:flutter/material.dart';

/// Privacy Policy Page
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy for Boichokro',
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
              'Introduction',
              'Boichokro ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and share your personal information when you use our book exchange platform.',
            ),

            _buildSection(
              context,
              'Information We Collect',
              'We collect information you provide directly to us, including:\n\n'
                  '• Account information (name, email, profile photo from Google Sign-In)\n'
                  '• Book information (title, author, photos, location)\n'
                  '• Messages and communications\n'
                  '• Location data (when you share books)\n'
                  '• Usage data and analytics',
            ),

            _buildSection(
              context,
              'How We Use Your Information',
              'We use the information we collect to:\n\n'
                  '• Provide, maintain, and improve our services\n'
                  '• Connect you with other book lovers\n'
                  '• Show you books available nearby\n'
                  '• Facilitate book exchanges and donations\n'
                  '• Send you updates and notifications\n'
                  '• Protect against fraud and abuse',
            ),

            _buildSection(
              context,
              'Information Sharing',
              'We share your information only:\n\n'
                  '• With other users for book exchanges (name, profile photo, location proximity)\n'
                  '• With service providers who assist our operations\n'
                  '• When required by law\n'
                  '• With your consent\n\n'
                  'We never sell your personal information.',
            ),

            _buildSection(
              context,
              'Data Security',
              'We implement appropriate security measures to protect your information. However, no method of transmission over the Internet is 100% secure.',
            ),

            _buildSection(
              context,
              'Your Rights',
              'You have the right to:\n\n'
                  '• Access your personal data\n'
                  '• Correct inaccurate data\n'
                  '• Delete your account and data\n'
                  '• Opt-out of certain data collection\n'
                  '• Export your data',
            ),

            _buildSection(
              context,
              'Children\'s Privacy',
              'Our service is not intended for children under 13. We do not knowingly collect information from children under 13.',
            ),

            _buildSection(
              context,
              'Changes to This Policy',
              'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new policy on this page.',
            ),

            _buildSection(
              context,
              'Contact Us',
              'If you have questions about this Privacy Policy, please contact us at:\n\n'
                  'Email: privacy@boichokro.com',
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
