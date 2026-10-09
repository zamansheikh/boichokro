import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/design/design.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../l10n/account/gen/account_l10n.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Auth Page - Google Sign-In authentication
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthBloc>(),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: Scaffold(
          body: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                showAppSnack(
                  context,
                  AccountL10n.of(context).authWelcome(state.user.name),
                  tone: AppTone.success,
                );
                context.go('/home');
              }
            },
            builder: (context, state) {
              return _SignInView(
                // Stay busy once authenticated: the app is navigating home.
                isBusy: state is AuthLoading || state is AuthAuthenticated,
                errorMessage: state is AuthError ? state.message : null,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SignInView extends StatelessWidget {
  const _SignInView({required this.isBusy, required this.errorMessage});

  final bool isBusy;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _BrandHeader(),
                  Expanded(
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.page,
                          AppSpacing.xxl,
                          AppSpacing.page,
                          AppSpacing.lg,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 480),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const _TrustPoints(),
                                const Spacer(),
                                const SizedBox(height: AppSpacing.xxl),
                                if (errorMessage != null) ...[
                                  AppBanner(
                                    tone: AppTone.danger,
                                    icon: LucideIcons.circleAlert,
                                    title: AccountL10n.of(
                                      context,
                                    ).authErrorTitle,
                                    message: errorMessage!,
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                ],
                                _GoogleButton(isBusy: isBusy),
                                const SizedBox(height: AppSpacing.md),
                                const _LegalNote(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Brand gradient with the mark, wordmark and headline.
class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final onHero = palette.onHero;
    final compact = MediaQuery.sizeOf(context).height < 700;
    final l = AccountL10n.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.heroStart, palette.heroEnd],
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            // The language switch sits in what used to be empty top padding.
            compact ? AppSpacing.sm : AppSpacing.md,
            AppSpacing.xxl,
            compact ? AppSpacing.xxl : AppSpacing.xxxl + AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Align(
                alignment: AlignmentDirectional.centerEnd,
                child: LanguageSwitch(onDark: true),
              ),
              SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
              Row(
                children: [
                  Container(
                    width: compact ? 60 : 76,
                    height: compact ? 60 : 76,
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Transform.scale(
                      scale: 1.5,
                      child: Image.asset(
                        'assets/icon/logo_splash.png',
                        semanticLabel: context.core.appName,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.core.appName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.headlineSmall?.copyWith(
                            color: onHero,
                          ),
                        ),
                        Text(
                          l.brandAltName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.titleMedium?.copyWith(
                            color: onHero.withValues(alpha: 0.75),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: compact ? AppSpacing.xxl : AppSpacing.xxxl),
              Text(
                l.authHeadline,
                style:
                    (compact
                            ? context.text.headlineLarge
                            : context.text.displaySmall)
                        ?.copyWith(color: onHero),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l.authSubhead,
                style: context.text.bodyLarge?.copyWith(
                  color: onHero.withValues(alpha: 0.78),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Three short reasons to trust the app.
class _TrustPoints extends StatelessWidget {
  const _TrustPoints();

  @override
  Widget build(BuildContext context) {
    final l = AccountL10n.of(context);

    return Column(
      children: [
        _TrustPoint(
          icon: LucideIcons.gift,
          tone: AppTone.donate,
          title: l.authTrustFreeTitle,
          message: l.authTrustFreeBody,
        ),
        const SizedBox(height: AppSpacing.lg),
        _TrustPoint(
          icon: LucideIcons.mapPin,
          tone: AppTone.exchange,
          title: l.authTrustNearbyTitle,
          message: l.authTrustNearbyBody,
        ),
        const SizedBox(height: AppSpacing.lg),
        _TrustPoint(
          icon: LucideIcons.badgeCheck,
          tone: AppTone.primary,
          title: l.authTrustVerifiedTitle,
          message: l.authTrustVerifiedBody,
        ),
      ],
    );
  }
}

class _TrustPoint extends StatelessWidget {
  const _TrustPoint({
    required this.icon,
    required this.tone,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final AppTone tone;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.tone(tone);
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, size: 20, color: colors.foreground),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.text.titleSmall),
              const SizedBox(height: 2),
              Text(
                message,
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.isBusy});

  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return OutlinedButton(
      onPressed: isBusy
          ? null
          : () => context.read<AuthBloc>().add(const SignInWithGoogle()),
      style: OutlinedButton.styleFrom(
        backgroundColor: colors.surface,
        disabledBackgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        minimumSize: const Size.fromHeight(56),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox.square(
            dimension: 22,
            child: isBusy
                ? CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: colors.primary,
                  )
                : Image.network(
                    'https://www.google.com/favicon.ico',
                    errorBuilder: (context, error, stackTrace) => Icon(
                      LucideIcons.logIn,
                      size: 20,
                      color: colors.primary,
                    ),
                  ),
          ),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              isBusy
                  ? AccountL10n.of(context).authSigningIn
                  : AccountL10n.of(context).authContinueWithGoogle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small print with links to the terms and the privacy policy.
class _LegalNote extends StatelessWidget {
  const _LegalNote();

  @override
  Widget build(BuildContext context) {
    final style = context.text.bodySmall?.copyWith(
      color: context.colors.onSurfaceVariant,
    );
    final linkStyle = TextButton.styleFrom(
      minimumSize: const Size(44, 44),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      textStyle: context.text.labelMedium?.copyWith(
        decoration: TextDecoration.underline,
      ),
    );

    final l = AccountL10n.of(context);

    return Column(
      children: [
        Text(l.authLegalPrefix, textAlign: TextAlign.center, style: style),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            TextButton(
              style: linkStyle,
              onPressed: () => context.push('/terms-conditions'),
              child: Text(l.authLegalTerms),
            ),
            Text(l.authLegalAnd, style: style),
            TextButton(
              style: linkStyle,
              onPressed: () => context.push('/privacy-policy'),
              child: Text(l.authLegalPrivacy),
            ),
          ],
        ),
      ],
    );
  }
}
