/// Firebase Constants
class FirebaseConstants {
  // Collection names
  static const String usersCollection = 'users';
  static const String booksCollection = 'books';
  static const String requestsCollection = 'requests';
  static const String chatRoomsCollection = 'chat_rooms';
  static const String messagesCollection = 'messages';

  // Storage paths
  static const String bookCoversPath = 'book_covers';
  static const String profilePhotosPath = 'profile_photos';

  // Field names (common)
  static const String createdAtField = 'createdAt';
  static const String updatedAtField = 'updatedAt';
}

/// App-wide constants
class AppConstants {
  // Location
  static const int geohashPrecision = 9;
  static const double defaultSearchRadius = 5.0; // km
  static const double maxSearchRadius = 50.0; // km

  // Preferences
  static const String hasSkippedOnboardingKey = 'has_skipped_onboarding';

  // Books
  static const List<String> bookConditions = [
    'Like New',
    'Very Good',
    'Good',
    'Fair',
    'Worn',
  ];

  static const List<String> bookGenres = [
    'Fiction',
    'Non-Fiction',
    'Science Fiction',
    'Fantasy',
    'Mystery',
    'Thriller',
    'Romance',
    'Biography',
    'History',
    'Self-Help',
    'Business',
    'Science',
    'Philosophy',
    'Poetry',
    'Comics',
    'Children',
    'Young Adult',
    'Other',
  ];

  // Chat
  static const int messagePageSize = 50;
  static const int chatRoomPreviewLength = 50;

  // User
  static const int minRatingForVerified = 1;
  static const double defaultUserRating = 0.0;

  // Safety
  static const int locationShareDurationHours = 2;
  static const int maxReportsBeforeBan = 3;

  // Validation
  static const int maxBookTitleLength = 200;
  static const int maxBookDescriptionLength = 500;
  static const int maxMessageLength = 1000;
  static const int minPhoneLength = 10;
}

/// Route paths
class RoutePaths {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String addBook = '/add-book';
  static const String bookDetail = '/book/:id';
  static const String myLibrary = '/library';
  static const String chat = '/chat';
  static const String chatRoom = '/chat/:roomId';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String editBook = '/book/:id/edit';
  static const String settings = '/settings';
  static const String privacyPolicy = '/privacy-policy';
  static const String termsConditions = '/terms-conditions';
  static const String about = '/about';
  static const String safety = '/safety';
  static const String request = '/request/:bookId';
}

/// Error Messages
class ErrorMessages {
  static const String noInternet = 'No internet connection';
  static const String serverError = 'Server error occurred';
  static const String unknownError = 'An unknown error occurred';
  static const String locationPermissionDenied = 'Location permission denied';
  static const String cameraPermissionDenied = 'Camera permission denied';
  static const String invalidCredentials = 'Invalid credentials';
  static const String userNotFound = 'User not found';
  static const String bookNotFound = 'Book not found';
}
