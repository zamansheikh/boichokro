import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/design/design.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/firebase_service.dart';
import '../../../../core/utils/constants.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../discover/domain/entities/book.dart';
import '../../../discover/domain/entities/user.dart';
import '../../../discover/presentation/bloc/book/book_bloc.dart';
import '../../../discover/presentation/bloc/book/book_event.dart';
import '../../../discover/presentation/bloc/book/book_state.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import 'settings_page.dart'
    show ProfileMenuGroup, ProfileMenuRow, appVersionLabel;

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
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(LucideIcons.settings),
            onPressed: () => context.push(RoutePaths.settings),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
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
                      onEdit: () =>
                          context.push(RoutePaths.editProfile, extra: userData),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    ProfileMenuGroup(
                      label: 'Library',
                      children: [
                        ProfileMenuRow(
                          icon: LucideIcons.history,
                          tone: AppTone.exchange,
                          title: 'Exchange history',
                          subtitle: 'Books you have swapped or given away',
                          onTap: () => context.push(
                            RoutePaths.myLibrary,
                            extra: 3, // index 3 = History tab
                          ),
                        ),
                        ProfileMenuRow(
                          icon: LucideIcons.star,
                          tone: AppTone.exchange,
                          title: 'My reviews',
                          subtitle: 'Ratings from your past exchanges',
                          onTap: () => context.push(
                            RoutePaths.myLibrary,
                            extra: 3, // History tab shows reviews
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    ProfileMenuGroup(
                      label: 'App',
                      children: [
                        ProfileMenuRow(
                          icon: LucideIcons.settings,
                          title: 'Settings',
                          onTap: () => context.push(RoutePaths.settings),
                        ),
                        ProfileMenuRow(
                          icon: LucideIcons.shieldCheck,
                          title: 'Privacy policy',
                          onTap: () => context.push(RoutePaths.privacyPolicy),
                        ),
                        ProfileMenuRow(
                          icon: LucideIcons.fileText,
                          title: 'Terms & conditions',
                          onTap: () => context.push(RoutePaths.termsConditions),
                        ),
                        ProfileMenuRow(
                          icon: LucideIcons.info,
                          title: 'About Boichokro',
                          onTap: () => context.push(RoutePaths.about),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    ProfileMenuGroup(
                      label: 'Account',
                      children: [
                        ProfileMenuRow(
                          icon: LucideIcons.logOut,
                          tone: AppTone.danger,
                          title: 'Sign out',
                          onTap: () => _showSignOutDialog(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      'Boichokro · Version $appVersionLabel',
                      textAlign: TextAlign.center,
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
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

  void _showSignOutDialog(BuildContext context) {
    final danger = context.tone(AppTone.danger);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(LucideIcons.logOut, color: danger.solid, size: 32),
        title: const Text('Sign out?'),
        content: const Text(
          'You will need to sign in again to see your books and messages.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);

              // Sign out from Firebase and Google
              final authBloc = getIt<AuthBloc>();
              authBloc.add(const SignOut());

              // Show confirmation and navigate
              showAppSnack(context, 'You have been signed out');

              // Navigate to auth
              context.go(RoutePaths.auth);
            },
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.error,
              foregroundColor: context.colors.onError,
            ),
            child: const Text('Sign out'),
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
