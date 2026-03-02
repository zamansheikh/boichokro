/**
 * PROJECT: Boichokro – Free Book Exchange & Donation App
 * TECH STACK:
 *   - Flutter 3.24+
 *   - Clean Architecture (3 layers: presentation, domain, data)
 *   - State Management: flutter_bloc
 *   - Dependency Injection: get_it + injectable
 *   - Navigation: go_router (typed routes, deep linking)
 *   - Backend: Appwrite (Auth, Database, Storage, Functions)
 *   - Maps: openmaps free + geolocator
 *   - Image: image_picker + google_ml_kit_text_recognition (ISBN scan)
 *
 * CORE FEATURES (MVP):
 * 1. Phone OTP Auth (Appwrite)
 * 2. Add Book: Scan cover → auto-fill title/author, set condition, choose "Donate" or "Exchange"
 * 3. Home: Map + List view with distance, search by title/author, radius filter
 * 4. Book Detail + Request (with optional swap book)
 * 5. In-app Chat (Appwrite Realtime)
 * 6. Meet-up safety: location share, public place suggestions, check-in
 * 7. Ratings, Reports, Verified Badge
 *
 * FOLDER STRUCTURE (Clean Architecture):
 *
 * lib/
 ├── core/
 │   ├── di/                → GetIt + Injectable setup
 │   ├── error/             → Failure, exceptions
 │   ├── network/           → Appwrite client
 │   ├── utils/             → constants, extensions
 │   └── usecase.dart
 │
 ├── features/
 │   └── book_exchange/
 │       ├── data/
 │       │   ├── datasources/        → remote (Appwrite), local
 │       │   ├── models/             → Appwrite ↔ Domain mappers
 │       │   └── repositories/       → impl
 │       │
 │       ├── domain/
 │       │   ├── entities/           → Book, User, Request
 │       │   ├── repositories/       → abstract
 │       │   └── usecases/           → AddBook, SearchBooks, etc.
 │       │
 │       └── presentation/
 │           ├── bloc/               → BookBloc, AuthBloc, ChatBloc
 │           ├── pages/              → home_page, add_book_page, book_detail_page
 │           ├── widgets/            → book_card, map_pin, chat_bubble
 │           └── routes.dart          → GoRouter config
 │
 ├── main.dart                  → GetIt.init(), runApp(MyApp())
 └── app_router.dart            → GoRouter with typed routes
 *
 * APPWRITE SETUP:
 * - Collections:
 *   - users: uid, phone, name, photo, rating, verified
 *   - books: bookId, ownerId, title, author, isbn, coverUrl, condition, genre[], mode (donate/exchange), location (lat,lng,geohash), status
 *   - requests: requestId, bookId, seekerId, offeredBookId, status, chatRoomId
 *   - chat_rooms: participants[], messages[] (realtime)
 * - Storage: book_covers/
 * - Functions: geohash generator, nearby search (index + query)
 *
 * INSTRUCTIONS FOR COPILOT:
 * 1. Generate full Clean Architecture layer-by-layer when I ask for a feature.
 * 2. Use BLoC for state: Freezed for states/events.
 * 3. All navigation via GoRouter with const routes and path params.
 * 4. Appwrite SDK: appwrite package, singleton via GetIt.
 * 5. Use geohash for location: geohash.encode(lat,lng,precision:9)
 * 6. Map search: query books where geohash startsWith(prefix) + distance calc
 * 7. Auto-fill book: Google ML Kit → extract ISBN → mock API or manual entry
 * 8. Always include error handling (Failure) and loading states.
 * 9. Use Riverpod/Bloc only where needed — prefer BLoC.
 *
 * START BY GENERATING:
 * → main.dart with GetIt + Appwrite client + GoRouter
 * → core/di/injectable.dart
 * → app_router.dart with routes: /home, /add-book, /book/:id, /chat/:roomId
 * → features/book_exchange/domain/entities/book.dart
 *
 * Let's begin. Generate the setup files first.
 */