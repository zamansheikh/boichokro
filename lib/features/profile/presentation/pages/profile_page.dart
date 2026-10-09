import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/design/design.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/firebase_service.dart';
import '../../../../core/utils/constants.dart';
import '../../../discover/domain/entities/book.dart';
import '../../../discover/domain/entities/user.dart';
import '../../../discover/presentation/bloc/book/book_bloc.dart';
import '../../../discover/presentation/bloc/book/book_event.dart';
import '../../../discover/presentation/bloc/book/book_state.dart';
import '../../../discover/presentation/pages/home_page.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import 'settings_page.dart' show ProfileMenuGroup, ProfileMenuRow;

/// Profile Page - User profile
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  /// Last profile that loaded, kept on screen while a refresh is in flight.
  User? _lastUser;

  bool get _isSignedIn => getIt<FirebaseService>().auth.currentUser != null;

  @override
  void initState() {
    super.initState();
    final currentUser = getIt<FirebaseService>().auth.currentUser;
    if (currentUser != null) {
      context.read<ProfileBloc>().add(const LoadProfile());
      context.read<BookBloc>().add(LoadMyBooks(currentUser.uid));
    }
  }

  Future<void> _refreshProfile() async {
    final currentUser = getIt<FirebaseService>().auth.currentUser;
    if (currentUser != null) {
      context.read<ProfileBloc>().add(const LoadProfile());
      context.read<BookBloc>().add(LoadMyBooks(currentUser.uid));
    }
  }

  User? _userFrom(ProfileState state) {
    if (state is ProfileLoaded) return state.user;
    if (state is ProfileUpdated) return state.user;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          // After profile update, reload to show latest data
          if (state is ProfileUpdated || state is ProfilePhotoUpdated) {
            context.read<ProfileBloc>().add(const LoadProfile());
          }
        },
        builder: (context, profileState) {
          if (profileState is ProfileError) {
            return AppErrorState(
              title: 'We couldn\'t load your profile',
              message: profileState.message,
              onRetry: () =>
                  context.read<ProfileBloc>().add(const LoadProfile()),
            );
          }

          final userData = _userFrom(profileState) ?? _lastUser;
          _lastUser = userData;

          if (userData == null) {
            // Loading, or about to load because someone is signed in.
            if (profileState is ProfileLoading || _isSignedIn) {
              return const _ProfileSkeleton();
            }
            return AppEmptyState(
              icon: LucideIcons.userX,
              title: 'Not signed in',
              message: 'Sign in to see your profile and manage your books.',
              actionLabel: 'Sign in',
              actionIcon: LucideIcons.logIn,
              onAction: () => context.go(RoutePaths.auth),
            );
          }

          return BlocBuilder<BookBloc, BookState>(
            builder: (context, bookState) {
              // Get user's books for stats
              final myBooks = bookState is BookLoaded
                  ? bookState.books
                        .where((b) => b.ownerId == userData.id)
                        .toList()
                  : null;

              return RefreshIndicator(
                onRefresh: _refreshProfile,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.sm,
                    AppSpacing.page,
                    AppSpacing.navClearance,
                  ),
                  children: [
                    _ProfileHeader(
                      user: userData,
                      books: myBooks,
                      onEdit: () async {
                        await context.push(
                          RoutePaths.editProfile,
                          extra: userData,
                        );
                        // The edit screen saves through its own bloc, so pull
                        // the fresh name and photo when it closes.
                        if (context.mounted) {
                          context.read<ProfileBloc>().add(const LoadProfile());
                        }
                      },
                    ),
                    if (!_JourneyCard.isComplete(userData, myBooks)) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _JourneyCard(user: userData, books: myBooks),
                    ],
                    const SizedBox(height: AppSpacing.xxl),
                    _ShelfSection(books: myBooks),
                    const SizedBox(height: AppSpacing.xxl),
                    const _InviteCard(),
                    const SizedBox(height: AppSpacing.xxl),
                    // Legal pages, about, sign out and account deletion all
                    // live in Settings so each has exactly one home.
                    ProfileMenuGroup(
                      children: [
                        ProfileMenuRow(
                          icon: LucideIcons.history,
                          tone: AppTone.exchange,
                          title: 'History & reviews',
                          subtitle: 'Past hand-offs and the ratings you got',
                          onTap: () => context.push(
                            RoutePaths.myLibrary,
                            extra: 3, // index 3 = History tab
                          ),
                        ),
                        ProfileMenuRow(
                          icon: LucideIcons.settings,
                          title: 'Settings',
                          subtitle: 'Account, privacy, terms and about',
                          onTap: () => context.push(RoutePaths.settings),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// "Getting started" card: three milestones around a progress wheel. Hidden
/// once all three are done.
class _JourneyCard extends StatelessWidget {
  const _JourneyCard({required this.user, required this.books});

  final User user;
  final List<Book>? books;

  static bool _shared(User user, List<Book>? books) =>
      (books?.isNotEmpty ?? false) || user.totalSwaps > 0;

  static bool isComplete(User user, List<Book>? books) =>
      _shared(user, books) && user.totalSwaps > 0 && user.ratingAvg > 0;

  @override
  Widget build(BuildContext context) {
    final steps = [
      (
        done: _shared(user, books),
        title: 'Share your first book',
        hint: 'Put a book you have finished into the circle',
      ),
      (
        done: user.totalSwaps > 0,
        title: 'Complete a hand-off',
        hint: 'Give a book away or swap one with a reader',
      ),
      (
        done: user.ratingAvg > 0,
        title: 'Earn your first rating',
        hint: 'Readers rate each other after a hand-off',
      ),
    ];
    final doneCount = steps.where((s) => s.done).length;
    final nextIndex = steps.indexWhere((s) => !s.done);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ChokroMark(
                size: 56,
                icon: LucideIcons.sprout,
                progress: doneCount / steps.length,
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Join the circle', style: context.text.titleLarge),
                    const SizedBox(height: 2),
                    Text(
                      '$doneCount of ${steps.length} steps done',
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          for (int i = 0; i < steps.length; i++)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    steps[i].done
                        ? LucideIcons.circleCheck
                        : LucideIcons.circle,
                    size: 20,
                    color: steps[i].done
                        ? context.palette.success
                        : i == nextIndex
                        ? context.colors.primary
                        : context.colors.outline,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          steps[i].title,
                          style: context.text.titleSmall?.copyWith(
                            color: steps[i].done
                                ? context.colors.onSurfaceVariant
                                : context.colors.onSurface,
                            decoration: steps[i].done
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        if (i == nextIndex) ...[
                          const SizedBox(height: 2),
                          Text(
                            steps[i].hint,
                            style: context.text.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (nextIndex == 0) ...[
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: () => context.push(RoutePaths.addBook),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('Share a book'),
            ),
          ],
        ],
      ),
    );
  }
}

/// The reader's own books as a row of covers.
class _ShelfSection extends StatelessWidget {
  const _ShelfSection({required this.books});

  /// Null while the books are still loading.
  final List<Book>? books;

  static const double _coverWidth = 84;

  @override
  Widget build(BuildContext context) {
    final listed = books;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Your shelf',
          subtitle: listed == null || listed.isEmpty
              ? 'Books you share show up here'
              : listed.length == 1
              ? '1 book in the circle'
              : '${listed.length} books in the circle',
          actionLabel: listed != null && listed.isNotEmpty
              ? 'Open library'
              : null,
          onAction: () => HomePage.goToTab(context, 1),
        ),
        const SizedBox(height: AppSpacing.md),
        if (listed == null)
          const Row(
            children: [
              Skeleton(width: _coverWidth, height: 126),
              SizedBox(width: AppSpacing.md),
              Skeleton(width: _coverWidth, height: 126),
              SizedBox(width: AppSpacing.md),
              Skeleton(width: _coverWidth, height: 126),
            ],
          )
        else if (listed.isEmpty)
          const _EmptyShelf()
        else
          SizedBox(
            height: 186,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: listed.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.lg),
              itemBuilder: (context, index) {
                final book = listed[index];
                return InkWell(
                  onTap: () => context.push('/book/${book.id}'),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: SizedBox(
                    width: _coverWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BookCover(
                          imageUrl: book.coverUrl,
                          title: book.title,
                          width: _coverWidth,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.labelMedium?.copyWith(
                            color: context.colors.onSurface,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

/// Placeholder shelf: three faded book spines waiting to be filled.
class _EmptyShelf extends StatelessWidget {
  const _EmptyShelf();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Widget slot(double height) {
      return Container(
        width: 46,
        height: height,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(2),
            right: Radius.circular(6),
          ),
          border: Border.all(color: colors.outlineVariant),
        ),
      );
    }

    return AppCard(
      color: colors.surfaceContainerLow,
      onTap: () => context.push(RoutePaths.addBook),
      child: Row(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              slot(62),
              const SizedBox(width: 6),
              slot(74),
              const SizedBox(width: 6),
              Container(
                width: 46,
                height: 68,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(2),
                    right: Radius.circular(6),
                  ),
                ),
                child: Icon(
                  LucideIcons.plus,
                  size: 20,
                  color: colors.onPrimaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your shelf is empty', style: context.text.titleMedium),
                const SizedBox(height: 2),
                Text(
                  'Tap to add a book you have finished reading.',
                  style: context.text.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Invite banner: opens the system share sheet with the store link.
class _InviteCard extends StatelessWidget {
  const _InviteCard();

  static const String _storeUrl =
      'https://play.google.com/store/apps/details?id=com.programmernexus.boichokro';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      color: colors.primaryContainer,
      borderColor: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bring a friend into the circle',
                  style: context.text.titleMedium?.copyWith(
                    color: colors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'More readers nearby means more books to choose from.',
                  style: context.text.bodySmall?.copyWith(
                    color: colors.onPrimaryContainer.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          FilledButton.icon(
            onPressed: () => SharePlus.instance.share(
              ShareParams(
                text:
                    'I am sharing and finding books for free on Boichokro. '
                    'Join me: $_storeUrl',
              ),
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            ),
            icon: const Icon(LucideIcons.share2, size: 16),
            label: const Text('Invite'),
          ),
        ],
      ),
    );
  }
}

/// Header card: avatar, name, membership facts, stats and the edit action.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.user,
    required this.books,
    required this.onEdit,
  });

  final User user;

  /// The user's listed books, or null while they are not loaded.
  final List<Book>? books;
  final VoidCallback onEdit;

  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context) {
    final muted = context.colors.onSurfaceVariant;
    final joined = user.createdAt;
    final listed = books;
    final toSwap =
        listed?.where((b) => b.mode == BookMode.exchange).length ?? 0;
    final toGive = listed?.where((b) => b.mode == BookMode.donate).length ?? 0;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          UserAvatar(
            photoUrl: user.photoUrl,
            name: user.name,
            radius: 46,
            verified: user.verifiedBadge,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            user.name.trim().isEmpty ? 'Reader' : user.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.text.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Member since ${_months[joined.month - 1]} ${joined.year}',
            textAlign: TextAlign.center,
            style: context.text.bodyMedium?.copyWith(color: muted),
          ),
          if (user.phone.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            MetaItem(icon: LucideIcons.phone, label: user.phone),
          ],
          if (user.verifiedBadge || toSwap > 0 || toGive > 0) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                if (user.verifiedBadge)
                  const StatusPill(
                    label: 'Verified reader',
                    icon: LucideIcons.badgeCheck,
                    tone: AppTone.success,
                  ),
                if (toSwap > 0)
                  StatusPill(
                    label: '$toSwap to exchange',
                    icon: BookMode.exchange.icon,
                    tone: BookMode.exchange.tone,
                  ),
                if (toGive > 0)
                  StatusPill(
                    label: '$toGive to donate',
                    icon: BookMode.donate.icon,
                    tone: BookMode.donate.tone,
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          const Divider(),
          const SizedBox(height: AppSpacing.lg),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _Stat(
                    value: user.ratingAvg > 0
                        ? user.ratingAvg.toStringAsFixed(1)
                        : '–',
                    label: 'Rating',
                    icon: Icons.star_rounded,
                    iconColor: context.palette.star,
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: _Stat(
                    value: '${user.totalSwaps}',
                    label: user.totalSwaps == 1 ? 'Swap' : 'Swaps',
                  ),
                ),
                if (listed != null) ...[
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: _Stat(
                      value: '${listed.length}',
                      label: listed.length == 1 ? 'Book' : 'Books',
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(LucideIcons.pencil, size: 18),
              label: const Text('Edit profile'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.value,
    required this.label,
    this.icon,
    this.iconColor,
  });

  final String value;
  final String label;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: iconColor),
                const SizedBox(width: AppSpacing.xs),
              ],
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.headlineSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading placeholder shaped like the header card and the first menu group.
class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.sm,
        AppSpacing.page,
        AppSpacing.navClearance,
      ),
      children: [
        const AppCard(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              Skeleton(width: 92, height: 92, radius: AppRadius.pill),
              SizedBox(height: AppSpacing.lg),
              Skeleton(width: 180, height: 22),
              SizedBox(height: AppSpacing.md),
              Skeleton(width: 140, height: 12),
              SizedBox(height: AppSpacing.xxl),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Skeleton(width: 56, height: 40),
                  Skeleton(width: 56, height: 40),
                  Skeleton(width: 56, height: 40),
                ],
              ),
              SizedBox(height: AppSpacing.xl),
              Skeleton(height: 52, radius: AppRadius.lg),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        const Padding(
          padding: EdgeInsets.only(left: AppSpacing.xs),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Skeleton(width: 72, height: 10),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            children: [
              for (int i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.xl),
                const Row(
                  children: [
                    Skeleton(width: 36, height: 36, radius: AppRadius.md),
                    SizedBox(width: AppSpacing.lg),
                    Expanded(child: Skeleton(height: 14)),
                    SizedBox(width: AppSpacing.xxxl),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
