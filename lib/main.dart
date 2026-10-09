import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_router.dart';
import 'core/di/injection_container.dart';
import 'core/l10n/l10n.dart';
import 'core/utils/theme.dart';
import 'l10n/account/gen/account_l10n.dart';
import 'l10n/book/gen/book_l10n.dart';
import 'l10n/browse/gen/browse_l10n.dart';
import 'l10n/chat/gen/chat_l10n.dart';
import 'l10n/library/gen/library_l10n.dart';
import 'l10n/listing/gen/listing_l10n.dart';
import 'features/discover/presentation/bloc/book/book_bloc.dart';
import 'features/discover/presentation/bloc/user/user_bloc.dart';
import 'features/chats/presentation/bloc/chat_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize dependency injection
  await configureDependencies();

  // Restore the reader's language (Bangla unless they chose otherwise)
  await LocaleController.instance.load();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<BookBloc>()),
        BlocProvider(create: (_) => getIt<UserBloc>()),
        BlocProvider(create: (_) => getIt<ChatBloc>()),
        BlocProvider(create: (_) => getIt<ProfileBloc>()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LocaleController.instance,
      builder: (context, locale, _) => MaterialApp.router(
        title: 'Boichokro',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        locale: locale,
        localizationsDelegates: const [
          CoreL10n.delegate,
          AccountL10n.delegate,
          BookL10n.delegate,
          BrowseL10n.delegate,
          ChatL10n.delegate,
          LibraryL10n.delegate,
          ListingL10n.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: LocaleController.supported,
        routerConfig: AppRouter.router,
        // Screens without an AppBar still need dark status-bar icons on paper.
        builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
          ),
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
