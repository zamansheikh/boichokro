// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'account_l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AccountL10nEn extends AccountL10n {
  AccountL10nEn([String locale = 'en']) : super(locale);

  @override
  String get splashMotto => 'Give  ·  Swap  ·  Read';

  @override
  String get brandAltName => 'বইচক্র';

  @override
  String get verifiedReader => 'Verified reader';

  @override
  String get readerFallback => 'Reader';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String onboardingPageIndicator(int current, int total) {
    final intl.NumberFormat currentNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String currentString = currentNumberFormat.format(current);
    final intl.NumberFormat totalNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Page $currentString of $totalString';
  }

  @override
  String get onboardingSlide1Title => 'Discover books nearby';

  @override
  String get onboardingSlide1Body => 'Browse the shelves of readers around you and find your next read a short walk away.';

  @override
  String get onboardingSlide2Title => 'Exchange or donate';

  @override
  String get onboardingSlide2Body => 'Swap a book you have finished for one you want, or simply give it away for free.';

  @override
  String get onboardingSlide3Title => 'Connect with readers';

  @override
  String get onboardingSlide3Body => 'Chat with the owner, agree on a place to meet, and pass the book on.';

  @override
  String onboardingChipDistanceAway(String distance) {
    return '$distance away';
  }

  @override
  String onboardingChipBooksNearYou(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString books near you',
      one: '1 book near you',
    );
    return '$_temp0';
  }

  @override
  String get onboardingSampleBookFeluda => 'Feluda Samagra';

  @override
  String get onboardingSampleBookSapiens => 'Sapiens';

  @override
  String get onboardingSampleSeekerName => 'Nusrat Jahan';

  @override
  String get onboardingSampleOwnerName => 'Arif Rahman';

  @override
  String get onboardingSampleQuestion => 'Is the book still available?';

  @override
  String get onboardingSampleReply => 'Yes! Meet at the library gate?';

  @override
  String authWelcome(String name) {
    return 'Welcome $name!';
  }

  @override
  String get authErrorTitle => 'We couldn\'t sign you in';

  @override
  String get authHeadline => 'Pass a book on.\nPick one up.';

  @override
  String get authSubhead => 'Exchange and donate books with readers in your neighbourhood.';

  @override
  String get authTrustFreeTitle => 'Always free';

  @override
  String get authTrustFreeBody => 'No fees and no selling, only swaps and gifts.';

  @override
  String get authTrustNearbyTitle => 'Close to you';

  @override
  String get authTrustNearbyBody => 'See books from readers in your own area.';

  @override
  String get authTrustVerifiedTitle => 'Verified readers';

  @override
  String get authTrustVerifiedBody => 'Ratings and badges show who you can rely on.';

  @override
  String get authSigningIn => 'Signing you in…';

  @override
  String get authContinueWithGoogle => 'Continue with Google';

  @override
  String get authLegalPrefix => 'By continuing, you agree to our';

  @override
  String get authLegalTerms => 'Terms of Service';

  @override
  String get authLegalAnd => 'and';

  @override
  String get authLegalPrivacy => 'Privacy Policy';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileLoadErrorTitle => 'We couldn\'t load your profile';

  @override
  String get profileSignedOutTitle => 'Not signed in';

  @override
  String get profileSignedOutBody => 'Sign in to see your profile and manage your books.';

  @override
  String get profileSignIn => 'Sign in';

  @override
  String get profileHistoryTitle => 'History & reviews';

  @override
  String get profileHistorySubtitle => 'Past hand-offs and the ratings you got';

  @override
  String get profileSettingsSubtitle => 'Account, privacy, terms and about';

  @override
  String profileMemberSince(String date) {
    return 'Member since $date';
  }

  @override
  String profileToExchange(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString to exchange';
  }

  @override
  String profileToDonate(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString to donate';
  }

  @override
  String get profileEdit => 'Edit profile';

  @override
  String get statRating => 'Rating';

  @override
  String statSwaps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Swaps',
      one: 'Swap',
    );
    return '$_temp0';
  }

  @override
  String statBooks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Books',
      one: 'Book',
    );
    return '$_temp0';
  }

  @override
  String statHandoffs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hand-offs',
      one: 'Hand-off',
    );
    return '$_temp0';
  }

  @override
  String get journeyTitle => 'Join the circle';

  @override
  String journeyProgress(int done, int total) {
    final intl.NumberFormat doneNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String doneString = doneNumberFormat.format(done);
    final intl.NumberFormat totalNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$doneString of $totalString steps done';
  }

  @override
  String get journeyStep1Title => 'Share your first book';

  @override
  String get journeyStep1Hint => 'Put a book you have finished into the circle';

  @override
  String get journeyStep2Title => 'Complete a hand-off';

  @override
  String get journeyStep2Hint => 'Give a book away or swap one with a reader';

  @override
  String get journeyStep3Title => 'Earn your first rating';

  @override
  String get journeyStep3Hint => 'Readers rate each other after a hand-off';

  @override
  String get journeyShareBook => 'Share a book';

  @override
  String get shelfYours => 'Your shelf';

  @override
  String get shelfEmptySubtitle => 'Books you share show up here';

  @override
  String shelfCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString books in the circle',
      one: '1 book in the circle',
    );
    return '$_temp0';
  }

  @override
  String get shelfOpenLibrary => 'Open library';

  @override
  String get shelfEmptyTitle => 'Your shelf is empty';

  @override
  String get shelfEmptyBody => 'Tap to add a book you have finished reading.';

  @override
  String get inviteTitle => 'Bring a friend into the circle';

  @override
  String get inviteBody => 'More readers nearby means more books to choose from.';

  @override
  String get inviteButton => 'Invite';

  @override
  String inviteShareText(String appName, String url) {
    return 'I am sharing and finding books for free on $appName. Join me: $url';
  }

  @override
  String get userThisReader => 'this reader';

  @override
  String get userMore => 'More';

  @override
  String get userReport => 'Report';

  @override
  String get userReportSubtitle => 'Tell us about a problem with this reader';

  @override
  String get userBlock => 'Block';

  @override
  String get userBlockSubtitle => 'Stop them contacting you';

  @override
  String userReportTitle(String name) {
    return 'Report $name';
  }

  @override
  String get userReportQuestion => 'What is the problem?';

  @override
  String get userReportReasonSpam => 'Spam';

  @override
  String get userReportReasonHarassment => 'Harassment';

  @override
  String get userReportReasonInappropriate => 'Inappropriate Content';

  @override
  String get userReportReasonOther => 'Other';

  @override
  String userBlockConfirmTitle(String name) {
    return 'Block $name?';
  }

  @override
  String get userBlockConfirmBody => 'You will no longer receive messages from them, and they will not be able to interact with your books.';

  @override
  String get userBlockedSnack => 'User blocked successfully';

  @override
  String get userReportedSnack => 'User reported successfully';

  @override
  String get userNotFoundTitle => 'Reader not found';

  @override
  String get userNotFoundBody => 'This profile could not be loaded right now.';

  @override
  String get userOwnPreviewBanner => 'This is how other readers see your profile.';

  @override
  String userReaderSince(String date) {
    return 'Reader since $date';
  }

  @override
  String get shelfTheirs => 'On their shelf';

  @override
  String shelfOfName(String name) {
    return 'On $name\'s shelf';
  }

  @override
  String get shelfNothingAvailable => 'Nothing available right now';

  @override
  String shelfAvailableCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString books you can ask for',
      one: '1 book you can ask for',
    );
    return '$_temp0';
  }

  @override
  String get shelfNoBooksTitle => 'No books on the shelf';

  @override
  String get shelfNoBooksBody => 'This reader has not shared a book yet.';

  @override
  String get trustVerifiedBody => 'This reader carries the verified badge.';

  @override
  String get trustNotVerifiedTitle => 'Not verified yet';

  @override
  String get trustNotVerifiedBody => 'Meet in a busy public place, as with any new reader.';

  @override
  String trustHandoffsTitle(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString completed hand-offs',
      one: '1 completed hand-off',
    );
    return '$_temp0';
  }

  @override
  String get trustHandoffsBody => 'Books given, received or swapped through the app.';

  @override
  String get trustNewTitle => 'New to the circle';

  @override
  String get trustNewBody => 'No completed hand-offs yet. Everyone starts here.';

  @override
  String get reviewsTitle => 'What readers say';

  @override
  String reviewsCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString reviews after hand-offs',
      one: '1 review after a hand-off',
    );
    return '$_temp0';
  }

  @override
  String get reviewsEmptyTitle => 'No reviews yet';

  @override
  String get reviewsEmptyWithHandoffs => 'Readers have not left a note about their hand-offs.';

  @override
  String get reviewsEmptyNoHandoffs => 'Reviews appear after a completed hand-off.';

  @override
  String reviewReceivedBook(String name) {
    return '$name · received a book';
  }

  @override
  String reviewGaveBook(String name) {
    return '$name · gave a book';
  }

  @override
  String get editCameraError => 'We couldn\'t open the camera. Check the app\'s permissions.';

  @override
  String get editGalleryError => 'We couldn\'t open your photos. Check the app\'s permissions.';

  @override
  String get editPhotoSheetTitle => 'Profile photo';

  @override
  String get editPhotoSheetSubtitle => 'Other readers see this when you exchange books.';

  @override
  String get editTakePhoto => 'Take a photo';

  @override
  String get editChooseGallery => 'Choose from gallery';

  @override
  String get editKeepCurrentPhoto => 'Keep my current photo';

  @override
  String get editKeepCurrentPhotoSubtitle => 'Discard the photo you just picked';

  @override
  String get editStillLoading => 'Your profile is still loading. Try again in a moment.';

  @override
  String get editDiscardTitle => 'Discard changes?';

  @override
  String get editDiscardBody => 'You have changes that are not saved yet. If you leave now they will be lost.';

  @override
  String get editKeepEditing => 'Keep editing';

  @override
  String get editDiscard => 'Discard';

  @override
  String get editProfileUpdated => 'Profile updated';

  @override
  String get editPhotoUpdated => 'Photo updated';

  @override
  String get editUploadingPhoto => 'Uploading photo…';

  @override
  String get editChangePhoto => 'Change photo';

  @override
  String get editChangePhotoSemantics => 'Change profile photo';

  @override
  String get editNameLabel => 'Display name';

  @override
  String get editNameHint => 'Enter your name';

  @override
  String get editNameHelper => 'This is how other readers will see you.';

  @override
  String get editNameRequired => 'Please enter your name';

  @override
  String get editNameTooShort => 'Name must be at least 2 characters';

  @override
  String get editNameTooLong => 'Name must be less than 50 characters';

  @override
  String get editPhotoNotice => 'Your profile picture will be visible to other users when you share or exchange books.';

  @override
  String get editSaving => 'Saving…';

  @override
  String get editSaveChanges => 'Save changes';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsGroupPreferences => 'Preferences';

  @override
  String get settingsGroupAbout => 'About';

  @override
  String get settingsGroupAccount => 'Account';

  @override
  String get settingsPrivacyTitle => 'Privacy policy';

  @override
  String get settingsPrivacySubtitle => 'What we collect and how we use it';

  @override
  String get settingsTermsTitle => 'Terms & conditions';

  @override
  String settingsTermsSubtitle(String appName) {
    return 'The rules for using $appName';
  }

  @override
  String settingsAboutTitle(String appName) {
    return 'About $appName';
  }

  @override
  String get settingsAboutSubtitle => 'What it is for and how to reach us';

  @override
  String get settingsAppVersion => 'App version';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsSignOutSubtitle => 'Your books and chats stay safe';

  @override
  String get settingsDeleteAccount => 'Delete account';

  @override
  String get settingsDeleteAccountSubtitle => 'Permanently delete your account and data';

  @override
  String get settingsSignOutTitle => 'Sign out?';

  @override
  String get settingsSignOutBody => 'You will need to sign in again to see your books and messages.';

  @override
  String get settingsSignedOutSnack => 'You have been signed out';

  @override
  String get settingsDeleteAccountTitle => 'Delete your account?';

  @override
  String get settingsDeleteAccountBody => 'This action cannot be undone. All your data including books, exchanges, and messages will be permanently deleted.';

  @override
  String get settingsDeletingAccount => 'Deleting your account…';

  @override
  String get settingsAccountDeleted => 'Your account has been deleted';

  @override
  String get settingsDeleteNeedsLogin => 'For your security, sign out, sign in again and then delete your account.';

  @override
  String get settingsDeleteFailed => 'We could not delete your account. Please try again.';

  @override
  String get aboutTitle => 'About';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutMissionLabel => 'Our mission';

  @override
  String aboutMissionBody(String appName) {
    return '$appName is a community-driven platform that connects book lovers to exchange and donate books. We believe in making knowledge accessible to everyone and reducing waste by giving books a second life.';
  }

  @override
  String get aboutFeaturesLabel => 'What you can do';

  @override
  String get aboutFeatureDiscoverTitle => 'Discover nearby';

  @override
  String get aboutFeatureDiscoverBody => 'Find books available for exchange or donation in your area';

  @override
  String get aboutFeatureExchangeTitle => 'Exchange & donate';

  @override
  String get aboutFeatureExchangeBody => 'Share your books with others through exchange or donation';

  @override
  String get aboutFeatureConnectTitle => 'Connect';

  @override
  String get aboutFeatureConnectBody => 'Chat with book owners and build a reading community';

  @override
  String get aboutContactLabel => 'Get in touch';

  @override
  String get aboutEmailUs => 'Email us';

  @override
  String get aboutVisitWebsite => 'Visit our website';

  @override
  String get aboutMadeWith => 'Made with ❤️ for book lovers';

  @override
  String aboutCopyright(String appName) {
    return '© 2024 $appName. All rights reserved.';
  }

  @override
  String aboutNoEmailApp(String email) {
    return 'No email app found. Write to us at $email';
  }

  @override
  String aboutCouldNotOpen(String url) {
    return 'Could not open $url';
  }

  @override
  String get legalLabel => 'Legal';

  @override
  String get legalPrivacyTitle => 'Privacy Policy';

  @override
  String get legalTermsTitle => 'Terms & Conditions';

  @override
  String legalLastUpdated(String date) {
    return 'Last updated: $date';
  }

  @override
  String get legalEnglishOnlyNotice => 'This document is currently available in English only.';
}
