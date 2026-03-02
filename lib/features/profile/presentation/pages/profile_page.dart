import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/firebase_service.dart';
import '../../../../core/utils/constants.dart';
import '../../../discover/domain/entities/book.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../discover/presentation/bloc/book/book_bloc.dart';
import '../../../discover/presentation/bloc/book/book_event.dart';
import '../../../discover/presentation/bloc/book/book_state.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

/// Profile Page - User profile
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.settings),
            onPressed: () => context.push(RoutePaths.settings),
          ),
        ],
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          // After profile update, reload to show latest data
          if (state is ProfileUpdated || state is ProfilePhotoUpdated) {
            context.read<ProfileBloc>().add(const LoadProfile());
          }
        },
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            if (profileState is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (profileState is ProfileError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      LucideIcons.alertCircle,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(profileState.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<ProfileBloc>().add(const LoadProfile()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // Get user data from ProfileBloc
            final userData = profileState is ProfileLoaded
                ? profileState.user
                : profileState is ProfileUpdated
                ? profileState.user
                : null;

            if (userData == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.userX,
                      size: 80,
                      color: colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text('Not signed in', style: textTheme.headlineSmall),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => context.go(RoutePaths.auth),
                      icon: const Icon(LucideIcons.logIn),
                      label: const Text('Sign In'),
                    ),
                  ],
                ),
              );
            }

            return BlocBuilder<BookBloc, BookState>(
              builder: (context, bookState) {
                // Get user's books for stats
                final myBooks = bookState is BookLoaded
                    ? bookState.books
                          .where((b) => b.ownerId == userData.id)
                          .toList()
                    : <Book>[];

                final totalBooks = myBooks.length;
                final donations = myBooks
                    .where((b) => b.mode == BookMode.donate)
                    .length;
                final exchanges = myBooks
                    .where((b) => b.mode == BookMode.exchange)
                    .length;

                return RefreshIndicator(
                  onRefresh: _refreshProfile,
                  child: ListView(
                    padding: const EdgeInsets.only(top: 16, bottom: 120),
                    children: [
                      // Profile Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            // Profile Photo
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: colorScheme.primary,
                              backgroundImage: userData.photoUrl != null
                                  ? NetworkImage(userData.photoUrl!)
                                  : null,
                              child: userData.photoUrl == null
                                  ? Icon(
                                      LucideIcons.user,
                                      size: 50,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 12),

                            // Name
                            Text(
                              userData.name,
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            // Phone
                            if (userData.phone.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                userData.phone,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],

                            const SizedBox(height: 12),

                            // Rating
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    LucideIcons.star,
                                    color: Colors.orange.shade700,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    userData.ratingAvg.toStringAsFixed(1),
                                    style: textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange.shade900,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '(${userData.totalSwaps} swaps)',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Statistics Cards
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    context,
                                    LucideIcons.library,
                                    totalBooks.toString(),
                                    'Books',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    context,
                                    LucideIcons.repeat,
                                    exchanges.toString(),
                                    'Exchanges',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    context,
                                    LucideIcons.gift,
                                    donations.toString(),
                                    'Donations',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    context,
                                    LucideIcons.badgeCheck,
                                    userData.verifiedBadge == true
                                        ? 'Yes'
                                        : 'No',
                                    'Verified',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Profile Actions
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            _buildActionTile(
                              context,
                              LucideIcons.pencil,
                              'Edit Profile',
                              () => context.push(
                                RoutePaths.editProfile,
                                extra: userData,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildActionTile(
                              context,
                              LucideIcons.history,
                              'Exchange History',
                              () => context.push(
                                RoutePaths.myLibrary,
                                extra: 3, // index 3 = History tab
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildActionTile(
                              context,
                              LucideIcons.star,
                              'My Reviews',
                              () => context.push(
                                RoutePaths.myLibrary,
                                extra: 3, // History tab shows reviews
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Sign Out Button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => _showSignOutDialog(context),
                                icon: Icon(LucideIcons.logOut),
                                label: Text('Sign Out'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: colorScheme.error,
                                  side: BorderSide(color: colorScheme.error),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // App Version
                            Text(
                              'Version 1.0.0',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: colorScheme.primary),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 20),
        ),
        title: Text(title, style: textTheme.titleSmall),
        trailing: Icon(
          LucideIcons.chevronRight,
          color: colorScheme.onSurfaceVariant,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(LucideIcons.logOut, color: colorScheme.error, size: 32),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              // Sign out from Firebase and Google
              final authBloc = getIt<AuthBloc>();
              authBloc.add(const SignOut());

              // Show confirmation and navigate
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Signed out successfully')),
              );

              // Navigate to auth
              context.go(RoutePaths.auth);
            },
            style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
