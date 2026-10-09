import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/design/design.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/constants.dart';
import '../../../../l10n/account/gen/account_l10n.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Splash Page - Initial loading screen
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  static const String _logoAsset = 'assets/icon/logo_splash.png';

  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _rings;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    );

    // The logo starts almost in place so the hand-over from the native launch
    // screen (same logo, same paper colour) reads as one continuous image.
    _logoScale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6, curve: Curves.easeOutBack),
      ),
    );
    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.3, curve: Curves.easeOut),
    );
    _rings = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.1, 1, curve: Curves.easeOutCubic),
    );
    final text = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 1, curve: Curves.easeOutCubic),
    );
    _textFade = text;
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(text);

    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(_logoAsset), context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocProvider(
      create: (context) => getIt<AuthBloc>()..add(const AuthStarted()),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthAuthenticated) {
            context.go('/home');
          } else if (state is AuthUnauthenticated) {
            final prefs = await SharedPreferences.getInstance();
            final hasSkipped =
                prefs.getBool(AppConstants.hasSkippedOnboardingKey) ?? false;
            if (context.mounted) {
              if (hasSkipped) {
                context.go('/auth');
              } else {
                context.go('/onboarding');
              }
            }
          }
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
          ),
          child: Scaffold(
            body: LayoutBuilder(
              builder: (context, constraints) {
                final logoSize = math.min(
                  constraints.maxWidth * 0.72,
                  constraints.maxHeight * 0.4,
                );

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Faint wheel rings radiating from the logo.
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _rings,
                        builder: (context, _) => CustomPaint(
                          painter: _RingsPainter(
                            progress: _rings.value,
                            color: colors.primary,
                            baseRadius: logoSize * 0.44,
                          ),
                        ),
                      ),
                    ),
                    FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: Image.asset(
                          _logoAsset,
                          width: logoSize,
                          height: logoSize,
                          filterQuality: FilterQuality.medium,
                          semanticLabel: context.core.appName,
                        ),
                      ),
                    ),
                    Align(
                      alignment: const Alignment(0, 0.62),
                      child: FadeTransition(
                        opacity: _textFade,
                        child: SlideTransition(
                          position: _textSlide,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xxxl,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  context.core.appName,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.text.headlineMedium,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  context.core.appTagline,
                                  textAlign: TextAlign.center,
                                  style: context.text.bodyLarge?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: SafeArea(
                        minimum: const EdgeInsets.only(bottom: AppSpacing.xxxl),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 56,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                                child: const LinearProgressIndicator(
                                  minHeight: 3,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              AccountL10n.of(context).splashMotto,
                              textAlign: TextAlign.center,
                              style: context.text.labelSmall?.copyWith(
                                color: colors.onSurfaceVariant,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Concentric rings that open out from the logo once, then rest.
class _RingsPainter extends CustomPainter {
  _RingsPainter({
    required this.progress,
    required this.color,
    required this.baseRadius,
  });

  final double progress;
  final Color color;
  final double baseRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (int i = 0; i < 4; i++) {
      final spread = baseRadius * (0.2 + 0.42 * i) * progress;
      final alpha = (0.13 - 0.028 * i) * progress;
      canvas.drawCircle(
        center,
        baseRadius + spread,
        paint..color = color.withValues(alpha: alpha.clamp(0.0, 1.0)),
      );
    }
  }

  @override
  bool shouldRepaint(_RingsPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.baseRadius != baseRadius;
  }
}
