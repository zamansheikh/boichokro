import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'account_l10n_bn.dart';
import 'account_l10n_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AccountL10n
/// returned by `AccountL10n.of(context)`.
///
/// Applications need to include `AccountL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/account_l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AccountL10n.localizationsDelegates,
///   supportedLocales: AccountL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AccountL10n.supportedLocales
/// property.
abstract class AccountL10n {
  AccountL10n(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AccountL10n of(BuildContext context) {
    return Localizations.of<AccountL10n>(context, AccountL10n)!;
  }

  static const LocalizationsDelegate<AccountL10n> delegate = _AccountL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en')
  ];

  /// No description provided for @splashMotto.
  ///
  /// In en, this message translates to:
  /// **'Give  ·  Swap  ·  Read'**
  String get splashMotto;

  /// No description provided for @brandAltName.
  ///
  /// In en, this message translates to:
  /// **'বইচক্র'**
  String get brandAltName;

  /// No description provided for @verifiedReader.
  ///
  /// In en, this message translates to:
  /// **'Verified reader'**
  String get verifiedReader;

  /// No description provided for @readerFallback.
  ///
  /// In en, this message translates to:
  /// **'Reader'**
  String get readerFallback;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingPageIndicator.
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String onboardingPageIndicator(int current, int total);

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In en, this message translates to:
  /// **'Discover books nearby'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Body.
  ///
  /// In en, this message translates to:
  /// **'Browse the shelves of readers around you and find your next read a short walk away.'**
  String get onboardingSlide1Body;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In en, this message translates to:
  /// **'Exchange or donate'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Body.
  ///
  /// In en, this message translates to:
  /// **'Swap a book you have finished for one you want, or simply give it away for free.'**
  String get onboardingSlide2Body;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In en, this message translates to:
  /// **'Connect with readers'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Body.
  ///
  /// In en, this message translates to:
  /// **'Chat with the owner, agree on a place to meet, and pass the book on.'**
  String get onboardingSlide3Body;

  /// No description provided for @onboardingChipDistanceAway.
  ///
  /// In en, this message translates to:
  /// **'{distance} away'**
  String onboardingChipDistanceAway(String distance);

  /// No description provided for @onboardingChipBooksNearYou.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 book near you} other{{count} books near you}}'**
  String onboardingChipBooksNearYou(int count);

  /// No description provided for @onboardingSampleBookFeluda.
  ///
  /// In en, this message translates to:
  /// **'Feluda Samagra'**
  String get onboardingSampleBookFeluda;

  /// No description provided for @onboardingSampleBookSapiens.
  ///
  /// In en, this message translates to:
  /// **'Sapiens'**
  String get onboardingSampleBookSapiens;

  /// No description provided for @onboardingSampleSeekerName.
  ///
  /// In en, this message translates to:
  /// **'Nusrat Jahan'**
  String get onboardingSampleSeekerName;

  /// No description provided for @onboardingSampleOwnerName.
  ///
  /// In en, this message translates to:
  /// **'Arif Rahman'**
  String get onboardingSampleOwnerName;

  /// No description provided for @onboardingSampleQuestion.
  ///
  /// In en, this message translates to:
  /// **'Is the book still available?'**
  String get onboardingSampleQuestion;

  /// No description provided for @onboardingSampleReply.
  ///
  /// In en, this message translates to:
  /// **'Yes! Meet at the library gate?'**
  String get onboardingSampleReply;

  /// No description provided for @authWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome {name}!'**
  String authWelcome(String name);

  /// No description provided for @authErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t sign you in'**
  String get authErrorTitle;

  /// No description provided for @authHeadline.
  ///
  /// In en, this message translates to:
  /// **'Pass a book on.\nPick one up.'**
  String get authHeadline;

  /// No description provided for @authSubhead.
  ///
  /// In en, this message translates to:
  /// **'Exchange and donate books with readers in your neighbourhood.'**
  String get authSubhead;

  /// No description provided for @authTrustFreeTitle.
  ///
  /// In en, this message translates to:
  /// **'Always free'**
  String get authTrustFreeTitle;

  /// No description provided for @authTrustFreeBody.
  ///
  /// In en, this message translates to:
  /// **'No fees and no selling, only swaps and gifts.'**
  String get authTrustFreeBody;

  /// No description provided for @authTrustNearbyTitle.
  ///
  /// In en, this message translates to:
  /// **'Close to you'**
  String get authTrustNearbyTitle;

  /// No description provided for @authTrustNearbyBody.
  ///
  /// In en, this message translates to:
  /// **'See books from readers in your own area.'**
  String get authTrustNearbyBody;

  /// No description provided for @authTrustVerifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Verified readers'**
  String get authTrustVerifiedTitle;

  /// No description provided for @authTrustVerifiedBody.
  ///
  /// In en, this message translates to:
  /// **'Ratings and badges show who you can rely on.'**
  String get authTrustVerifiedBody;

  /// No description provided for @authSigningIn.
  ///
  /// In en, this message translates to:
  /// **'Signing you in…'**
  String get authSigningIn;

  /// No description provided for @authContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueWithGoogle;

  /// No description provided for @authLegalPrefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our'**
  String get authLegalPrefix;

  /// No description provided for @authLegalTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get authLegalTerms;

  /// No description provided for @authLegalAnd.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get authLegalAnd;

  /// No description provided for @authLegalPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get authLegalPrivacy;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your profile'**
  String get profileLoadErrorTitle;

  /// No description provided for @profileSignedOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Not signed in'**
  String get profileSignedOutTitle;

  /// No description provided for @profileSignedOutBody.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see your profile and manage your books.'**
  String get profileSignedOutBody;

  /// No description provided for @profileSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get profileSignIn;

  /// No description provided for @profileHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'History & reviews'**
  String get profileHistoryTitle;

  /// No description provided for @profileHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Past hand-offs and the ratings you got'**
  String get profileHistorySubtitle;

  /// No description provided for @profileSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Account, privacy, terms and about'**
  String get profileSettingsSubtitle;

  /// No description provided for @profileMemberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since {date}'**
  String profileMemberSince(String date);

  /// No description provided for @profileToExchange.
  ///
  /// In en, this message translates to:
  /// **'{count} to exchange'**
  String profileToExchange(int count);

  /// No description provided for @profileToDonate.
  ///
  /// In en, this message translates to:
  /// **'{count} to donate'**
  String profileToDonate(int count);

  /// No description provided for @profileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEdit;

  /// No description provided for @statRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get statRating;

  /// Label under a number that is shown separately, so the count only picks the plural form.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Swap} other{Swaps}}'**
  String statSwaps(int count);

  /// Label under a number that is shown separately, so the count only picks the plural form.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Book} other{Books}}'**
  String statBooks(int count);

  /// Label under a number that is shown separately, so the count only picks the plural form.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Hand-off} other{Hand-offs}}'**
  String statHandoffs(int count);

  /// No description provided for @journeyTitle.
  ///
  /// In en, this message translates to:
  /// **'Join the circle'**
  String get journeyTitle;

  /// No description provided for @journeyProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} steps done'**
  String journeyProgress(int done, int total);

  /// No description provided for @journeyStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Share your first book'**
  String get journeyStep1Title;

  /// No description provided for @journeyStep1Hint.
  ///
  /// In en, this message translates to:
  /// **'Put a book you have finished into the circle'**
  String get journeyStep1Hint;

  /// No description provided for @journeyStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Complete a hand-off'**
  String get journeyStep2Title;

  /// No description provided for @journeyStep2Hint.
  ///
  /// In en, this message translates to:
  /// **'Give a book away or swap one with a reader'**
  String get journeyStep2Hint;

  /// No description provided for @journeyStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Earn your first rating'**
  String get journeyStep3Title;

  /// No description provided for @journeyStep3Hint.
  ///
  /// In en, this message translates to:
  /// **'Readers rate each other after a hand-off'**
  String get journeyStep3Hint;

  /// No description provided for @journeyShareBook.
  ///
  /// In en, this message translates to:
  /// **'Share a book'**
  String get journeyShareBook;

  /// No description provided for @shelfYours.
  ///
  /// In en, this message translates to:
  /// **'Your shelf'**
  String get shelfYours;

  /// No description provided for @shelfEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Books you share show up here'**
  String get shelfEmptySubtitle;

  /// No description provided for @shelfCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 book in the circle} other{{count} books in the circle}}'**
  String shelfCount(int count);

  /// No description provided for @shelfOpenLibrary.
  ///
  /// In en, this message translates to:
  /// **'Open library'**
  String get shelfOpenLibrary;

  /// No description provided for @shelfEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your shelf is empty'**
  String get shelfEmptyTitle;

  /// No description provided for @shelfEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap to add a book you have finished reading.'**
  String get shelfEmptyBody;

  /// No description provided for @inviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Bring a friend into the circle'**
  String get inviteTitle;

  /// No description provided for @inviteBody.
  ///
  /// In en, this message translates to:
  /// **'More readers nearby means more books to choose from.'**
  String get inviteBody;

  /// No description provided for @inviteButton.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get inviteButton;

  /// No description provided for @inviteShareText.
  ///
  /// In en, this message translates to:
  /// **'I am sharing and finding books for free on {appName}. Join me: {url}'**
  String inviteShareText(String appName, String url);

  /// No description provided for @userThisReader.
  ///
  /// In en, this message translates to:
  /// **'this reader'**
  String get userThisReader;

  /// No description provided for @userMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get userMore;

  /// No description provided for @userReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get userReport;

  /// No description provided for @userReportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about a problem with this reader'**
  String get userReportSubtitle;

  /// No description provided for @userBlock.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get userBlock;

  /// No description provided for @userBlockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stop them contacting you'**
  String get userBlockSubtitle;

  /// No description provided for @userReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report {name}'**
  String userReportTitle(String name);

  /// No description provided for @userReportQuestion.
  ///
  /// In en, this message translates to:
  /// **'What is the problem?'**
  String get userReportQuestion;

  /// No description provided for @userReportReasonSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get userReportReasonSpam;

  /// No description provided for @userReportReasonHarassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment'**
  String get userReportReasonHarassment;

  /// No description provided for @userReportReasonInappropriate.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate Content'**
  String get userReportReasonInappropriate;

  /// No description provided for @userReportReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get userReportReasonOther;

  /// No description provided for @userBlockConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Block {name}?'**
  String userBlockConfirmTitle(String name);

  /// No description provided for @userBlockConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You will no longer receive messages from them, and they will not be able to interact with your books.'**
  String get userBlockConfirmBody;

  /// No description provided for @userBlockedSnack.
  ///
  /// In en, this message translates to:
  /// **'User blocked successfully'**
  String get userBlockedSnack;

  /// No description provided for @userReportedSnack.
  ///
  /// In en, this message translates to:
  /// **'User reported successfully'**
  String get userReportedSnack;

  /// No description provided for @userNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Reader not found'**
  String get userNotFoundTitle;

  /// No description provided for @userNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'This profile could not be loaded right now.'**
  String get userNotFoundBody;

  /// No description provided for @userOwnPreviewBanner.
  ///
  /// In en, this message translates to:
  /// **'This is how other readers see your profile.'**
  String get userOwnPreviewBanner;

  /// No description provided for @userReaderSince.
  ///
  /// In en, this message translates to:
  /// **'Reader since {date}'**
  String userReaderSince(String date);

  /// No description provided for @shelfTheirs.
  ///
  /// In en, this message translates to:
  /// **'On their shelf'**
  String get shelfTheirs;

  /// No description provided for @shelfOfName.
  ///
  /// In en, this message translates to:
  /// **'On {name}\'s shelf'**
  String shelfOfName(String name);

  /// No description provided for @shelfNothingAvailable.
  ///
  /// In en, this message translates to:
  /// **'Nothing available right now'**
  String get shelfNothingAvailable;

  /// No description provided for @shelfAvailableCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 book you can ask for} other{{count} books you can ask for}}'**
  String shelfAvailableCount(int count);

  /// No description provided for @shelfNoBooksTitle.
  ///
  /// In en, this message translates to:
  /// **'No books on the shelf'**
  String get shelfNoBooksTitle;

  /// No description provided for @shelfNoBooksBody.
  ///
  /// In en, this message translates to:
  /// **'This reader has not shared a book yet.'**
  String get shelfNoBooksBody;

  /// No description provided for @trustVerifiedBody.
  ///
  /// In en, this message translates to:
  /// **'This reader carries the verified badge.'**
  String get trustVerifiedBody;

  /// No description provided for @trustNotVerifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Not verified yet'**
  String get trustNotVerifiedTitle;

  /// No description provided for @trustNotVerifiedBody.
  ///
  /// In en, this message translates to:
  /// **'Meet in a busy public place, as with any new reader.'**
  String get trustNotVerifiedBody;

  /// No description provided for @trustHandoffsTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 completed hand-off} other{{count} completed hand-offs}}'**
  String trustHandoffsTitle(int count);

  /// No description provided for @trustHandoffsBody.
  ///
  /// In en, this message translates to:
  /// **'Books given, received or swapped through the app.'**
  String get trustHandoffsBody;

  /// No description provided for @trustNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New to the circle'**
  String get trustNewTitle;

  /// No description provided for @trustNewBody.
  ///
  /// In en, this message translates to:
  /// **'No completed hand-offs yet. Everyone starts here.'**
  String get trustNewBody;

  /// No description provided for @reviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'What readers say'**
  String get reviewsTitle;

  /// No description provided for @reviewsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 review after a hand-off} other{{count} reviews after hand-offs}}'**
  String reviewsCount(int count);

  /// No description provided for @reviewsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get reviewsEmptyTitle;

  /// No description provided for @reviewsEmptyWithHandoffs.
  ///
  /// In en, this message translates to:
  /// **'Readers have not left a note about their hand-offs.'**
  String get reviewsEmptyWithHandoffs;

  /// No description provided for @reviewsEmptyNoHandoffs.
  ///
  /// In en, this message translates to:
  /// **'Reviews appear after a completed hand-off.'**
  String get reviewsEmptyNoHandoffs;

  /// No description provided for @reviewReceivedBook.
  ///
  /// In en, this message translates to:
  /// **'{name} · received a book'**
  String reviewReceivedBook(String name);

  /// No description provided for @reviewGaveBook.
  ///
  /// In en, this message translates to:
  /// **'{name} · gave a book'**
  String reviewGaveBook(String name);

  /// No description provided for @editCameraError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t open the camera. Check the app\'s permissions.'**
  String get editCameraError;

  /// No description provided for @editGalleryError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t open your photos. Check the app\'s permissions.'**
  String get editGalleryError;

  /// No description provided for @editPhotoSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get editPhotoSheetTitle;

  /// No description provided for @editPhotoSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Other readers see this when you exchange books.'**
  String get editPhotoSheetSubtitle;

  /// No description provided for @editTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get editTakePhoto;

  /// No description provided for @editChooseGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get editChooseGallery;

  /// No description provided for @editKeepCurrentPhoto.
  ///
  /// In en, this message translates to:
  /// **'Keep my current photo'**
  String get editKeepCurrentPhoto;

  /// No description provided for @editKeepCurrentPhotoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discard the photo you just picked'**
  String get editKeepCurrentPhotoSubtitle;

  /// No description provided for @editStillLoading.
  ///
  /// In en, this message translates to:
  /// **'Your profile is still loading. Try again in a moment.'**
  String get editStillLoading;

  /// No description provided for @editDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get editDiscardTitle;

  /// No description provided for @editDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'You have changes that are not saved yet. If you leave now they will be lost.'**
  String get editDiscardBody;

  /// No description provided for @editKeepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get editKeepEditing;

  /// No description provided for @editDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get editDiscard;

  /// No description provided for @editProfileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get editProfileUpdated;

  /// No description provided for @editPhotoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Photo updated'**
  String get editPhotoUpdated;

  /// No description provided for @editUploadingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Uploading photo…'**
  String get editUploadingPhoto;

  /// No description provided for @editChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get editChangePhoto;

  /// No description provided for @editChangePhotoSemantics.
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get editChangePhotoSemantics;

  /// No description provided for @editNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get editNameLabel;

  /// No description provided for @editNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get editNameHint;

  /// No description provided for @editNameHelper.
  ///
  /// In en, this message translates to:
  /// **'This is how other readers will see you.'**
  String get editNameHelper;

  /// No description provided for @editNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get editNameRequired;

  /// No description provided for @editNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get editNameTooShort;

  /// No description provided for @editNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Name must be less than 50 characters'**
  String get editNameTooLong;

  /// No description provided for @editPhotoNotice.
  ///
  /// In en, this message translates to:
  /// **'Your profile picture will be visible to other users when you share or exchange books.'**
  String get editPhotoNotice;

  /// No description provided for @editSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get editSaving;

  /// No description provided for @editSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get editSaveChanges;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsGroupPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsGroupPreferences;

  /// No description provided for @settingsGroupAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsGroupAbout;

  /// No description provided for @settingsGroupAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsGroupAccount;

  /// No description provided for @settingsPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacyTitle;

  /// No description provided for @settingsPrivacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'What we collect and how we use it'**
  String get settingsPrivacySubtitle;

  /// No description provided for @settingsTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms & conditions'**
  String get settingsTermsTitle;

  /// No description provided for @settingsTermsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The rules for using {appName}'**
  String settingsTermsSubtitle(String appName);

  /// No description provided for @settingsAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About {appName}'**
  String settingsAboutTitle(String appName);

  /// No description provided for @settingsAboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What it is for and how to reach us'**
  String get settingsAboutSubtitle;

  /// No description provided for @settingsAppVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get settingsAppVersion;

  /// No description provided for @settingsSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settingsSignOut;

  /// No description provided for @settingsSignOutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your books and chats stay safe'**
  String get settingsSignOutSubtitle;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsDeleteAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account and data'**
  String get settingsDeleteAccountSubtitle;

  /// No description provided for @settingsSignOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get settingsSignOutTitle;

  /// No description provided for @settingsSignOutBody.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again to see your books and messages.'**
  String get settingsSignOutBody;

  /// No description provided for @settingsSignedOutSnack.
  ///
  /// In en, this message translates to:
  /// **'You have been signed out'**
  String get settingsSignedOutSnack;

  /// No description provided for @settingsDeleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get settingsDeleteAccountTitle;

  /// No description provided for @settingsDeleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All your data including books, exchanges, and messages will be permanently deleted.'**
  String get settingsDeleteAccountBody;

  /// No description provided for @settingsDeletingAccount.
  ///
  /// In en, this message translates to:
  /// **'Deleting your account…'**
  String get settingsDeletingAccount;

  /// No description provided for @settingsAccountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted'**
  String get settingsAccountDeleted;

  /// No description provided for @settingsDeleteNeedsLogin.
  ///
  /// In en, this message translates to:
  /// **'For your security, sign out, sign in again and then delete your account.'**
  String get settingsDeleteNeedsLogin;

  /// No description provided for @settingsDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not delete your account. Please try again.'**
  String get settingsDeleteFailed;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutVersion(String version);

  /// No description provided for @aboutMissionLabel.
  ///
  /// In en, this message translates to:
  /// **'Our mission'**
  String get aboutMissionLabel;

  /// No description provided for @aboutMissionBody.
  ///
  /// In en, this message translates to:
  /// **'{appName} is a community-driven platform that connects book lovers to exchange and donate books. We believe in making knowledge accessible to everyone and reducing waste by giving books a second life.'**
  String aboutMissionBody(String appName);

  /// No description provided for @aboutFeaturesLabel.
  ///
  /// In en, this message translates to:
  /// **'What you can do'**
  String get aboutFeaturesLabel;

  /// No description provided for @aboutFeatureDiscoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover nearby'**
  String get aboutFeatureDiscoverTitle;

  /// No description provided for @aboutFeatureDiscoverBody.
  ///
  /// In en, this message translates to:
  /// **'Find books available for exchange or donation in your area'**
  String get aboutFeatureDiscoverBody;

  /// No description provided for @aboutFeatureExchangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Exchange & donate'**
  String get aboutFeatureExchangeTitle;

  /// No description provided for @aboutFeatureExchangeBody.
  ///
  /// In en, this message translates to:
  /// **'Share your books with others through exchange or donation'**
  String get aboutFeatureExchangeBody;

  /// No description provided for @aboutFeatureConnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get aboutFeatureConnectTitle;

  /// No description provided for @aboutFeatureConnectBody.
  ///
  /// In en, this message translates to:
  /// **'Chat with book owners and build a reading community'**
  String get aboutFeatureConnectBody;

  /// No description provided for @aboutContactLabel.
  ///
  /// In en, this message translates to:
  /// **'Get in touch'**
  String get aboutContactLabel;

  /// No description provided for @aboutEmailUs.
  ///
  /// In en, this message translates to:
  /// **'Email us'**
  String get aboutEmailUs;

  /// No description provided for @aboutVisitWebsite.
  ///
  /// In en, this message translates to:
  /// **'Visit our website'**
  String get aboutVisitWebsite;

  /// No description provided for @aboutMadeWith.
  ///
  /// In en, this message translates to:
  /// **'Made with ❤️ for book lovers'**
  String get aboutMadeWith;

  /// No description provided for @aboutCopyright.
  ///
  /// In en, this message translates to:
  /// **'© 2024 {appName}. All rights reserved.'**
  String aboutCopyright(String appName);

  /// No description provided for @aboutNoEmailApp.
  ///
  /// In en, this message translates to:
  /// **'No email app found. Write to us at {email}'**
  String aboutNoEmailApp(String email);

  /// No description provided for @aboutCouldNotOpen.
  ///
  /// In en, this message translates to:
  /// **'Could not open {url}'**
  String aboutCouldNotOpen(String url);

  /// No description provided for @legalLabel.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legalLabel;

  /// No description provided for @legalPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get legalPrivacyTitle;

  /// No description provided for @legalTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get legalTermsTitle;

  /// No description provided for @legalLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date}'**
  String legalLastUpdated(String date);

  /// No description provided for @legalEnglishOnlyNotice.
  ///
  /// In en, this message translates to:
  /// **'This document is currently available in English only.'**
  String get legalEnglishOnlyNotice;
}

class _AccountL10nDelegate extends LocalizationsDelegate<AccountL10n> {
  const _AccountL10nDelegate();

  @override
  Future<AccountL10n> load(Locale locale) {
    return SynchronousFuture<AccountL10n>(lookupAccountL10n(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AccountL10nDelegate old) => false;
}

AccountL10n lookupAccountL10n(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn': return AccountL10nBn();
    case 'en': return AccountL10nEn();
  }

  throw FlutterError(
    'AccountL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
