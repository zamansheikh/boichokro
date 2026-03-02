import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/utils/constants.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/auth/presentation/pages/onboarding_page.dart';
import 'features/auth/presentation/pages/auth_page.dart';
import 'features/discover/presentation/pages/home_page.dart';
import 'features/discover/presentation/pages/add_book_page.dart';
import 'features/discover/presentation/pages/book_detail_page.dart';
import 'features/chats/presentation/pages/chat_room_page.dart';
import 'features/profile/presentation/pages/settings_page.dart';
import 'features/profile/presentation/pages/privacy_policy_page.dart';
import 'features/profile/presentation/pages/terms_conditions_page.dart';
import 'features/profile/presentation/pages/about_page.dart';
import 'features/discover/presentation/pages/edit_book_page.dart';
import 'features/discover/domain/entities/book.dart' as book_entity;
import 'features/discover/domain/entities/user.dart';
import 'features/profile/presentation/pages/edit_profile_page.dart';
import 'features/library/presentation/pages/my_library_page.dart';

/// App router configuration using GoRouter
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    routes: [
      // Splash Screen
      GoRoute(
        path: RoutePaths.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),

      // Onboarding
      GoRoute(
        path: RoutePaths.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),

      // Authentication
      GoRoute(
        path: RoutePaths.auth,
        name: 'auth',
        builder: (context, state) => const AuthPage(),
      ),

      // Home (Map + List view)
      GoRoute(
        path: RoutePaths.home,
        name: 'home',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final initialIndex = extra?['initialIndex'] as int?;
          return HomePage(initialIndex: initialIndex);
        },
      ),

      // Add Book
      GoRoute(
        path: RoutePaths.addBook,
        name: 'addBook',
        builder: (context, state) => const AddBookPage(),
      ),

      // Book Detail
      GoRoute(
        path: RoutePaths.bookDetail,
        name: 'bookDetail',
        builder: (context, state) {
          final bookId = state.pathParameters['id']!;
          return BookDetailPage(bookId: bookId);
        },
      ),

      // Chat Room
      GoRoute(
        path: RoutePaths.chatRoom,
        name: 'chatRoom',
        builder: (context, state) {
          final roomId = state.pathParameters['roomId']!;
          return ChatRoomPage(roomId: roomId);
        },
      ),

      // Settings
      GoRoute(
        path: RoutePaths.settings,
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),

      // Privacy Policy
      GoRoute(
        path: RoutePaths.privacyPolicy,
        name: 'privacyPolicy',
        builder: (context, state) => const PrivacyPolicyPage(),
      ),

      // Terms & Conditions
      GoRoute(
        path: RoutePaths.termsConditions,
        name: 'termsConditions',
        builder: (context, state) => const TermsConditionsPage(),
      ),

      // About
      GoRoute(
        path: RoutePaths.about,
        name: 'about',
        builder: (context, state) => const AboutPage(),
      ),

      // Edit Profile
      GoRoute(
        path: RoutePaths.editProfile,
        name: 'editProfile',
        builder: (context, state) {
          final user = state.extra as User?;
          return EditProfilePage(user: user);
        },
      ),

      // My Library
      GoRoute(
        path: RoutePaths.myLibrary,
        name: 'myLibrary',
        builder: (context, state) {
          final tabIndex = state.extra is int ? state.extra as int : 0;
          return MyLibraryPage(initialTabIndex: tabIndex);
        },
      ),

      // Edit Book
      GoRoute(
        path: RoutePaths.editBook,
        name: 'editBook',
        builder: (context, state) {
          final book = state.extra as book_entity.Book;
          return EditBookPage(book: book);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.uri}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(RoutePaths.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
