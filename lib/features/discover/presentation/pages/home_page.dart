import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/constants.dart';
import '../bloc/book/book_bloc.dart';
import '../bloc/user/user_bloc.dart';
import 'discover_page.dart';
import '../../../library/presentation/pages/my_library_page.dart';
import '../../../chats/presentation/pages/chat_list_page.dart';
import '../../../chats/presentation/bloc/chat_bloc.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';

/// Main Home Page with Bottom Navigation
class HomePage extends StatefulWidget {
  final int? initialIndex;

  const HomePage({super.key, this.initialIndex});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex ?? 0;
  }

  final List<Widget> _pages = [
    const DiscoverPage(),
    const MyLibraryPage(),
    const ChatListPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MultiBlocProvider(
      providers: [
        BlocProvider<BookBloc>(create: (context) => getIt<BookBloc>()),
        BlocProvider<UserBloc>(create: (context) => getIt<UserBloc>()),
        BlocProvider<ChatBloc>(create: (context) => getIt<ChatBloc>()),
        BlocProvider<ProfileBloc>(create: (context) => getIt<ProfileBloc>()),
      ],
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: SafeArea(
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    context,
                    icon: LucideIcons.compass,
                    label: 'Discover',
                    index: 0,
                  ),
                  _buildNavItem(
                    context,
                    icon: LucideIcons.library,
                    label: 'Library',
                    index: 1,
                  ),
                  _buildNavItem(
                    context,
                    icon: LucideIcons.messageSquare,
                    label: 'Chats',
                    index: 2,
                  ),
                  _buildNavItem(
                    context,
                    icon: LucideIcons.user,
                    label: 'Profile',
                    index: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: _currentIndex == 0 || _currentIndex == 1
            ? FloatingActionButton.extended(
                onPressed: () => context.push(RoutePaths.addBook),
                icon: const Icon(LucideIcons.plus),
                label: const Text(
                  'Add Book',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isSelected = _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: isSelected
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
