import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/design/design.dart';
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

  /// Switches the bottom-navigation tab (0 Discover, 1 Library, 2 Chats,
  /// 3 Profile). Works from inside a tab and from pushed routes.
  static void goToTab(BuildContext context, int index) {
    final home = context.findAncestorStateOfType<_HomePageState>();
    if (home != null) {
      home._select(index);
    } else {
      context.go(RoutePaths.home, extra: {'initialIndex': index});
    }
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = (widget.initialIndex ?? 0).clamp(0, _pages.length - 1);
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // `context.go(RoutePaths.home, extra: {'initialIndex': n})` from inside a
    // tab rebuilds this page rather than recreating it.
    final index = widget.initialIndex;
    if (index != null && index != oldWidget.initialIndex) {
      _currentIndex = index.clamp(0, _pages.length - 1);
    }
  }

  final List<Widget> _pages = [
    const DiscoverPage(),
    const MyLibraryPage(),
    const ChatListPage(),
    const ProfilePage(),
  ];

  void _select(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BookBloc>(create: (context) => getIt<BookBloc>()),
        BlocProvider<UserBloc>(create: (context) => getIt<UserBloc>()),
        BlocProvider<ChatBloc>(create: (context) => getIt<ChatBloc>()),
        BlocProvider<ProfileBloc>(create: (context) => getIt<ProfileBloc>()),
      ],
      child: PopScope(
        // Back from any other tab returns to Discover before leaving the app.
        canPop: _currentIndex == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _select(0);
        },
        child: Scaffold(
          extendBody: true,
          body: IndexedStack(index: _currentIndex, children: _pages),
          bottomNavigationBar: _HomeNavBar(
            currentIndex: _currentIndex,
            onSelect: _select,
            onAdd: () => context.push(RoutePaths.addBook),
          ),
        ),
      ),
    );
  }
}

/// Floating pill navigation with the "share a book" action at its centre.
class _HomeNavBar extends StatelessWidget {
  const _HomeNavBar({
    required this.currentIndex,
    required this.onSelect,
    required this.onAdd,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SafeArea(
      minimum: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: colors.outlineVariant),
            boxShadow: context.softShadow,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Row(
            children: [
              _NavItem(
                icon: LucideIcons.compass,
                label: 'Discover',
                selected: currentIndex == 0,
                onTap: () => onSelect(0),
              ),
              _NavItem(
                icon: LucideIcons.library,
                label: 'Library',
                selected: currentIndex == 1,
                onTap: () => onSelect(1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: Tooltip(
                  message: 'Share a book',
                  child: Material(
                    color: colors.primary,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: onAdd,
                      child: SizedBox.square(
                        dimension: 50,
                        child: Icon(
                          LucideIcons.plus,
                          color: colors.onPrimary,
                          size: 24,
                          semanticLabel: 'Share a book',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _NavItem(
                icon: LucideIcons.messageSquare,
                label: 'Chats',
                selected: currentIndex == 2,
                onTap: () => onSelect(2),
              ),
              _NavItem(
                icon: LucideIcons.user,
                label: 'Profile',
                selected: currentIndex == 3,
                onTap: () => onSelect(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = selected ? colors.primary : colors.onSurfaceVariant;

    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        label: label,
        excludeSemantics: true,
        child: InkResponse(
          onTap: onTap,
          radius: 36,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: AppMotion.medium,
                curve: AppMotion.curve,
                width: selected ? 44 : 32,
                height: 30,
                decoration: BoxDecoration(
                  color: selected
                      ? colors.primaryContainer
                      : colors.primaryContainer.withValues(alpha: 0),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.labelSmall?.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
