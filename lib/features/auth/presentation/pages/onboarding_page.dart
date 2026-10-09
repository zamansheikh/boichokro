import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/design/design.dart';
import '../../../../core/utils/constants.dart';
import '../../../../l10n/account/gen/account_l10n.dart';
import '../../../discover/domain/entities/book.dart';

/// Onboarding Page - Introduction slides
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const int _slideCount = 3;

  List<OnboardingSlide> _slidesFor(AccountL10n l) => [
    OnboardingSlide(
      title: l.onboardingSlide1Title,
      description: l.onboardingSlide1Body,
      illustration: const _NearbyIllustration(),
    ),
    OnboardingSlide(
      title: l.onboardingSlide2Title,
      description: l.onboardingSlide2Body,
      illustration: const _ExchangeIllustration(),
    ),
    OnboardingSlide(
      title: l.onboardingSlide3Title,
      description: l.onboardingSlide3Body,
      illustration: const _ConnectIllustration(),
    ),
  ];

  bool get _isLastPage => _currentPage == _slideCount - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _navigateToAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.hasSkippedOnboardingKey, true);
    if (mounted) {
      context.go('/auth');
    }
  }

  void _nextPage() {
    if (!_isLastPage) {
      _pageController.nextPage(
        duration: AppMotion.slow,
        curve: AppMotion.curve,
      );
    } else {
      _navigateToAuth();
    }
  }

  void _skip() {
    _navigateToAuth();
  }

  @override
  Widget build(BuildContext context) {
    final l = AccountL10n.of(context);
    final slides = _slidesFor(l);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Brand + skip
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.sm,
                AppSpacing.sm,
                0,
              ),
              child: Row(
                children: [
                  SizedBox.square(
                    dimension: 36,
                    child: Transform.scale(
                      scale: 1.6,
                      child: Image.asset(
                        'assets/icon/logo_splash.png',
                        semanticLabel: context.core.appName,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      context.core.appName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleMedium,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Language first: a new reader can switch before reading on.
                  const LanguageSwitch(),
                  AnimatedOpacity(
                    opacity: _isLastPage ? 0 : 1,
                    duration: AppMotion.fast,
                    child: IgnorePointer(
                      ignoring: _isLastPage,
                      child: TextButton(
                        onPressed: _skip,
                        style: TextButton.styleFrom(
                          minimumSize: const Size(48, 48),
                        ),
                        child: Text(l.onboardingSkip, maxLines: 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: slides.length,
                itemBuilder: (context, index) {
                  return _SlideView(slide: slides[index]);
                },
              ),
            ),
            // Page indicator
            Semantics(
              label: l.onboardingPageIndicator(_currentPage + 1, slides.length),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < slides.length; i++)
                    AnimatedContainer(
                      duration: AppMotion.medium,
                      curve: AppMotion.curve,
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                      ),
                      width: _currentPage == i ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == i
                            ? context.colors.primary
                            : context.colors.outline.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            // Next / Get started
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                0,
                AppSpacing.page,
                AppSpacing.xl,
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _nextPage,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          _isLastPage
                              ? l.onboardingGetStarted
                              : l.onboardingNext,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Icon(LucideIcons.arrowRight, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Content of one onboarding slide.
class OnboardingSlide {
  const OnboardingSlide({
    required this.title,
    required this.description,
    required this.illustration,
  });

  final String title;
  final String description;

  /// Composed illustration, laid out on a 300 x 240 canvas.
  final Widget illustration;
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});

  final OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final artHeight = (constraints.maxHeight * 0.52).clamp(140.0, 300.0);

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: artHeight,
                  child: FittedBox(
                    child: ExcludeSemantics(
                      child: SizedBox(
                        width: 300,
                        height: 240,
                        child: slide.illustration,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  slide.title,
                  textAlign: TextAlign.center,
                  style: context.text.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Text(
                    slide.description,
                    textAlign: TextAlign.center,
                    style: context.text.bodyLarge?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Soft tinted disc that sits behind every illustration.
class _Backdrop extends StatelessWidget {
  const _Backdrop({required this.tone});

  final AppTone tone;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          color: context.tone(tone).background.withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Small paper chip that floats over an illustration.
class _FloatingChip extends StatelessWidget {
  const _FloatingChip({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: child,
    );
  }
}

/// A fan of three books with a "nearby" chip.
class _NearbyIllustration extends StatelessWidget {
  const _NearbyIllustration();

  @override
  Widget build(BuildContext context) {
    final l = AccountL10n.of(context);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        const _Backdrop(tone: AppTone.primary),
        Positioned(
          left: 44,
          top: 58,
          child: Transform.rotate(
            angle: -0.2,
            child: const BookCover(
              imageUrl: null,
              width: 88,
              title: 'পথের পাঁচালী',
            ),
          ),
        ),
        Positioned(
          right: 44,
          top: 58,
          child: Transform.rotate(
            angle: 0.2,
            child: BookCover(
              imageUrl: null,
              width: 88,
              title: l.onboardingSampleBookFeluda,
            ),
          ),
        ),
        const Positioned(
          left: 102,
          top: 40,
          child: BookCover(imageUrl: null, width: 96, title: 'হাজার বছর ধরে'),
        ),
        Positioned(
          right: 14,
          top: 22,
          child: _FloatingChip(
            child: MetaItem(
              icon: LucideIcons.mapPin,
              label: l.onboardingChipDistanceAway(context.distance(650)),
            ),
          ),
        ),
        Positioned(
          left: 10,
          bottom: 14,
          child: _FloatingChip(
            child: MetaItem(
              icon: LucideIcons.library,
              label: l.onboardingChipBooksNearYou(12),
            ),
          ),
        ),
      ],
    );
  }
}

/// Two books travelling around the brand wheel, labelled swap and free.
class _ExchangeIllustration extends StatelessWidget {
  const _ExchangeIllustration();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const _Backdrop(tone: AppTone.exchange),
        Positioned(
          left: 18,
          top: 28,
          child: Transform.rotate(
            angle: -0.1,
            child: BookCover(
              imageUrl: null,
              width: 84,
              title: AccountL10n.of(context).onboardingSampleBookSapiens,
            ),
          ),
        ),
        Positioned(
          right: 18,
          bottom: 28,
          child: Transform.rotate(
            angle: 0.1,
            child: const BookCover(
              imageUrl: null,
              width: 84,
              title: 'শেষের কবিতা',
            ),
          ),
        ),
        const Center(child: ChokroMark(size: 104)),
        Positioned(
          left: 20,
          bottom: 22,
          child: StatusPill.mode(BookMode.exchange),
        ),
        Positioned(right: 20, top: 26, child: StatusPill.mode(BookMode.donate)),
      ],
    );
  }
}

/// A short conversation between two readers about a book.
class _ConnectIllustration extends StatelessWidget {
  const _ConnectIllustration();

  @override
  Widget build(BuildContext context) {
    final l = AccountL10n.of(context);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        const _Backdrop(tone: AppTone.donate),
        Positioned(
          left: 8,
          top: 30,
          right: 56,
          child: _Bubble(
            name: l.onboardingSampleSeekerName,
            text: l.onboardingSampleQuestion,
            mine: false,
          ),
        ),
        Positioned(
          left: 56,
          top: 104,
          right: 8,
          child: _Bubble(
            name: l.onboardingSampleOwnerName,
            text: l.onboardingSampleReply,
            mine: true,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 14,
          child: Center(
            child: _FloatingChip(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatusPill(
                    label: l.verifiedReader,
                    icon: LucideIcons.badgeCheck,
                    tone: AppTone.success,
                    dense: true,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const RatingBadge(rating: 4.9, swaps: 14),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.name, required this.text, required this.mine});

  final String name;
  final String text;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    const corner = Radius.circular(AppRadius.lg);
    const tail = Radius.circular(AppSpacing.xs);
    final avatar = UserAvatar(name: name, radius: 18, verified: mine);
    final bubble = Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: mine ? context.colors.primary : context.colors.surface,
          border: mine
              ? null
              : Border.all(color: context.colors.outlineVariant),
          borderRadius: BorderRadius.only(
            topLeft: corner,
            topRight: corner,
            bottomLeft: mine ? corner : tail,
            bottomRight: mine ? tail : corner,
          ),
        ),
        child: Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.text.bodyMedium?.copyWith(
            color: mine ? context.colors.onPrimary : context.colors.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );

    return Row(
      mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: mine
          ? [bubble, const SizedBox(width: AppSpacing.sm), avatar]
          : [avatar, const SizedBox(width: AppSpacing.sm), bubble],
    );
  }
}
