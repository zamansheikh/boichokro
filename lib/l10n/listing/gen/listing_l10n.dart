import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'listing_l10n_bn.dart';
import 'listing_l10n_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of ListingL10n
/// returned by `ListingL10n.of(context)`.
///
/// Applications need to include `ListingL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/listing_l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: ListingL10n.localizationsDelegates,
///   supportedLocales: ListingL10n.supportedLocales,
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
/// be consistent with the languages listed in the ListingL10n.supportedLocales
/// property.
abstract class ListingL10n {
  ListingL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static ListingL10n of(BuildContext context) {
    return Localizations.of<ListingL10n>(context, ListingL10n)!;
  }

  static const LocalizationsDelegate<ListingL10n> delegate =
      _ListingL10nDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @addBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a book'**
  String get addBookTitle;

  /// No description provided for @editBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit book'**
  String get editBookTitle;

  /// No description provided for @stepCoverLabel.
  ///
  /// In en, this message translates to:
  /// **'Cover'**
  String get stepCoverLabel;

  /// No description provided for @stepDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get stepDetailsLabel;

  /// No description provided for @stepSharingLabel.
  ///
  /// In en, this message translates to:
  /// **'Sharing'**
  String get stepSharingLabel;

  /// No description provided for @stepProgress.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String stepProgress(int step, int total);

  /// No description provided for @stepSemantics.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}, {label}'**
  String stepSemantics(int step, int total, String label);

  /// No description provided for @stepCoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Start with the cover'**
  String get stepCoverTitle;

  /// No description provided for @stepCoverSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A clear photo of the front helps readers recognise the book.'**
  String get stepCoverSubtitle;

  /// No description provided for @stepDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tell readers about it'**
  String get stepDetailsTitle;

  /// No description provided for @stepDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The title and author are all you need to continue.'**
  String get stepDetailsSubtitle;

  /// No description provided for @stepSharingTitle.
  ///
  /// In en, this message translates to:
  /// **'How will you share it?'**
  String get stepSharingTitle;

  /// No description provided for @stepSharingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose what you would like in return, and where to meet.'**
  String get stepSharingSubtitle;

  /// No description provided for @actionSnapCover.
  ///
  /// In en, this message translates to:
  /// **'Snap the cover'**
  String get actionSnapCover;

  /// No description provided for @actionRetakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Retake photo'**
  String get actionRetakePhoto;

  /// No description provided for @actionChooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get actionChooseFromGallery;

  /// No description provided for @actionShareBook.
  ///
  /// In en, this message translates to:
  /// **'Share this book'**
  String get actionShareBook;

  /// No description provided for @actionSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get actionSaveChanges;

  /// No description provided for @loadingSharingBook.
  ///
  /// In en, this message translates to:
  /// **'Sharing your book…'**
  String get loadingSharingBook;

  /// No description provided for @loadingSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get loadingSaving;

  /// No description provided for @coverDropHint.
  ///
  /// In en, this message translates to:
  /// **'Front of the book, in good light'**
  String get coverDropHint;

  /// No description provided for @coverReading.
  ///
  /// In en, this message translates to:
  /// **'Reading the cover…'**
  String get coverReading;

  /// No description provided for @coverRequired.
  ///
  /// In en, this message translates to:
  /// **'A cover photo is required'**
  String get coverRequired;

  /// No description provided for @snackCoverRequired.
  ///
  /// In en, this message translates to:
  /// **'Add a photo of the cover to continue'**
  String get snackCoverRequired;

  /// No description provided for @errorCameraOpen.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t open the camera. Check the camera permission and try again.'**
  String get errorCameraOpen;

  /// No description provided for @errorGalleryOpen.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t open your gallery. Check the photos permission and try again.'**
  String get errorGalleryOpen;

  /// No description provided for @scanIsbnFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'ISBN filled in for you'**
  String get scanIsbnFoundTitle;

  /// No description provided for @scanIsbnFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'We read {isbn} from the photo. You can check it next.'**
  String scanIsbnFoundMessage(String isbn);

  /// No description provided for @scanInProgress.
  ///
  /// In en, this message translates to:
  /// **'Reading the photo for an ISBN…'**
  String get scanInProgress;

  /// No description provided for @scanNotFound.
  ///
  /// In en, this message translates to:
  /// **'No ISBN spotted in this photo. You can type it in on the next step, or leave it out.'**
  String get scanNotFound;

  /// No description provided for @scanHint.
  ///
  /// In en, this message translates to:
  /// **'When you take the photo with the camera, we look for an ISBN in it and fill it in for you.'**
  String get scanHint;

  /// No description provided for @detailsHeading.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detailsHeading;

  /// No description provided for @fieldTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get fieldTitleLabel;

  /// No description provided for @fieldTitleHint.
  ///
  /// In en, this message translates to:
  /// **'As printed on the cover'**
  String get fieldTitleHint;

  /// No description provided for @validationTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get validationTitleRequired;

  /// No description provided for @validationTitleTooLong.
  ///
  /// In en, this message translates to:
  /// **'Title is too long'**
  String get validationTitleTooLong;

  /// No description provided for @fieldAuthorLabel.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get fieldAuthorLabel;

  /// No description provided for @fieldAuthorHint.
  ///
  /// In en, this message translates to:
  /// **'Who wrote it?'**
  String get fieldAuthorHint;

  /// No description provided for @validationAuthorRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the author\'s name'**
  String get validationAuthorRequired;

  /// No description provided for @fieldIsbnLabel.
  ///
  /// In en, this message translates to:
  /// **'ISBN (optional)'**
  String get fieldIsbnLabel;

  /// No description provided for @fieldIsbnHint.
  ///
  /// In en, this message translates to:
  /// **'The number above the barcode'**
  String get fieldIsbnHint;

  /// No description provided for @fieldDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get fieldDescriptionLabel;

  /// No description provided for @fieldDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'What is it about? Any notes, marks or missing pages?'**
  String get fieldDescriptionHint;

  /// No description provided for @conditionHeading.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get conditionHeading;

  /// No description provided for @conditionHint.
  ///
  /// In en, this message translates to:
  /// **'Be honest, it builds trust.'**
  String get conditionHint;

  /// No description provided for @conditionLikeNewExplanation.
  ///
  /// In en, this message translates to:
  /// **'Looks unread, with no marks or creases.'**
  String get conditionLikeNewExplanation;

  /// No description provided for @conditionVeryGoodExplanation.
  ///
  /// In en, this message translates to:
  /// **'Read gently. Clean pages, barely any wear.'**
  String get conditionVeryGoodExplanation;

  /// No description provided for @conditionGoodExplanation.
  ///
  /// In en, this message translates to:
  /// **'A well-kept copy with light wear.'**
  String get conditionGoodExplanation;

  /// No description provided for @conditionFairExplanation.
  ///
  /// In en, this message translates to:
  /// **'Clear wear, or some notes and highlights.'**
  String get conditionFairExplanation;

  /// No description provided for @conditionWornExplanation.
  ///
  /// In en, this message translates to:
  /// **'Heavily used, but still readable.'**
  String get conditionWornExplanation;

  /// No description provided for @genresHeading.
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get genresHeading;

  /// No description provided for @genresHint.
  ///
  /// In en, this message translates to:
  /// **'Pick any that fit, so readers can find it.'**
  String get genresHint;

  /// No description provided for @genresOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get genresOptional;

  /// No description provided for @genresSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String genresSelected(int count);

  /// No description provided for @modeDonateTitle.
  ///
  /// In en, this message translates to:
  /// **'Give it away'**
  String get modeDonateTitle;

  /// No description provided for @modeDonateDescription.
  ///
  /// In en, this message translates to:
  /// **'Free for any reader who asks for it.'**
  String get modeDonateDescription;

  /// No description provided for @modeExchangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Swap for another book'**
  String get modeExchangeTitle;

  /// No description provided for @modeExchangeDescription.
  ///
  /// In en, this message translates to:
  /// **'Readers offer one of their books in return.'**
  String get modeExchangeDescription;

  /// No description provided for @sharingHeading.
  ///
  /// In en, this message translates to:
  /// **'How you share it'**
  String get sharingHeading;

  /// No description provided for @sharingHint.
  ///
  /// In en, this message translates to:
  /// **'Choose what you would like in return.'**
  String get sharingHint;

  /// No description provided for @pickupHeading.
  ///
  /// In en, this message translates to:
  /// **'Pickup location'**
  String get pickupHeading;

  /// No description provided for @pickupHint.
  ///
  /// In en, this message translates to:
  /// **'Where readers can collect the book.'**
  String get pickupHint;

  /// No description provided for @pickupEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a spot'**
  String get pickupEmptyTitle;

  /// No description provided for @pickupEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Search, tap the map or use your current location.'**
  String get pickupEmptySubtitle;

  /// No description provided for @pickupChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get pickupChange;

  /// No description provided for @pickupRequired.
  ///
  /// In en, this message translates to:
  /// **'A pickup location is required'**
  String get pickupRequired;

  /// No description provided for @snackPickupRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose a pickup location to continue'**
  String get snackPickupRequired;

  /// No description provided for @pickupPublicPlaceTip.
  ///
  /// In en, this message translates to:
  /// **'Nearby readers see this spot on the map, so a public place such as a campus gate or a café works well.'**
  String get pickupPublicPlaceTip;

  /// No description provided for @snackBookAdded.
  ///
  /// In en, this message translates to:
  /// **'Your book is on the shelf for nearby readers'**
  String get snackBookAdded;

  /// No description provided for @snackChangesSaved.
  ///
  /// In en, this message translates to:
  /// **'Your changes are saved'**
  String get snackChangesSaved;

  /// No description provided for @discardNewTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard this book?'**
  String get discardNewTitle;

  /// No description provided for @discardNewMessage.
  ///
  /// In en, this message translates to:
  /// **'The photo and details you added won\'t be saved.'**
  String get discardNewMessage;

  /// No description provided for @discardEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard your changes?'**
  String get discardEditTitle;

  /// No description provided for @discardEditMessage.
  ///
  /// In en, this message translates to:
  /// **'The edits you made to this book won\'t be saved.'**
  String get discardEditMessage;

  /// No description provided for @discardKeepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get discardKeepEditing;

  /// No description provided for @discardConfirm.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discardConfirm;

  /// No description provided for @editingEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Editing'**
  String get editingEyebrow;

  /// No description provided for @editSummaryNote.
  ///
  /// In en, this message translates to:
  /// **'The cover photo and pickup location stay as they are.'**
  String get editSummaryNote;

  /// No description provided for @locationDisclosureTitle.
  ///
  /// In en, this message translates to:
  /// **'Location access required'**
  String get locationDisclosureTitle;

  /// No description provided for @locationDisclosureMessage.
  ///
  /// In en, this message translates to:
  /// **'Boichokro needs your location to help you pinpoint your current address for assigning a pickup location to a book you upload, or finding a nearby book.'**
  String get locationDisclosureMessage;

  /// No description provided for @locationDisclosureDeny.
  ///
  /// In en, this message translates to:
  /// **'Deny'**
  String get locationDisclosureDeny;

  /// No description provided for @locationDisclosureAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get locationDisclosureAccept;

  /// No description provided for @errorLocationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t get your location. Please try again, or pick the spot on the map.'**
  String get errorLocationUnavailable;

  /// No description provided for @snackAddressNotFound.
  ///
  /// In en, this message translates to:
  /// **'Address not found'**
  String get snackAddressNotFound;

  /// No description provided for @errorAddressSearch.
  ///
  /// In en, this message translates to:
  /// **'Could not find that address. Try a different search or tap the spot on the map.'**
  String get errorAddressSearch;

  /// No description provided for @actionUseThisLocation.
  ///
  /// In en, this message translates to:
  /// **'Use this location'**
  String get actionUseThisLocation;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search an area, road or landmark'**
  String get searchHint;

  /// No description provided for @searchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTooltip;

  /// No description provided for @mapTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to place the pin'**
  String get mapTapHint;

  /// No description provided for @tooltipUseCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my current location'**
  String get tooltipUseCurrentLocation;

  /// No description provided for @issueDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Location access is off'**
  String get issueDeniedTitle;

  /// No description provided for @issueDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'No problem. Search for an address or tap the map to place the pin yourself.'**
  String get issueDeniedMessage;

  /// No description provided for @issueBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Location access is blocked'**
  String get issueBlockedTitle;

  /// No description provided for @issueBlockedMessage.
  ///
  /// In en, this message translates to:
  /// **'Allow location for Boichokro in your phone settings, or search and tap the map instead.'**
  String get issueBlockedMessage;

  /// No description provided for @actionOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get actionOpenSettings;

  /// No description provided for @issueServiceOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Location is turned off'**
  String get issueServiceOffTitle;

  /// No description provided for @issueServiceOffMessage.
  ///
  /// In en, this message translates to:
  /// **'Turn on location on your phone and try again, or search and tap the map instead.'**
  String get issueServiceOffMessage;

  /// No description provided for @actionOpenLocationSettings.
  ///
  /// In en, this message translates to:
  /// **'Open location settings'**
  String get actionOpenLocationSettings;

  /// No description provided for @noSpotTitle.
  ///
  /// In en, this message translates to:
  /// **'No spot chosen yet'**
  String get noSpotTitle;

  /// No description provided for @noSpotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick where readers can collect the book.'**
  String get noSpotSubtitle;

  /// No description provided for @actionLocateMe.
  ///
  /// In en, this message translates to:
  /// **'Locate me'**
  String get actionLocateMe;

  /// No description provided for @selectedSpotEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Selected spot'**
  String get selectedSpotEyebrow;

  /// No description provided for @pinnedSpotNoAddress.
  ///
  /// In en, this message translates to:
  /// **'Pinned spot (no street address found)'**
  String get pinnedSpotNoAddress;
}

class _ListingL10nDelegate extends LocalizationsDelegate<ListingL10n> {
  const _ListingL10nDelegate();

  @override
  Future<ListingL10n> load(Locale locale) {
    return SynchronousFuture<ListingL10n>(lookupListingL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_ListingL10nDelegate old) => false;
}

ListingL10n lookupListingL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return ListingL10nBn();
    case 'en':
      return ListingL10nEn();
  }

  throw FlutterError(
    'ListingL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
