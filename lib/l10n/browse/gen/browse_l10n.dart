import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'browse_l10n_bn.dart';
import 'browse_l10n_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of BrowseL10n
/// returned by `BrowseL10n.of(context)`.
///
/// Applications need to include `BrowseL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/browse_l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: BrowseL10n.localizationsDelegates,
///   supportedLocales: BrowseL10n.supportedLocales,
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
/// be consistent with the languages listed in the BrowseL10n.supportedLocales
/// property.
abstract class BrowseL10n {
  BrowseL10n(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static BrowseL10n of(BuildContext context) {
    return Localizations.of<BrowseL10n>(context, BrowseL10n)!;
  }

  static const LocalizationsDelegate<BrowseL10n> delegate = _BrowseL10nDelegate();

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

  /// No description provided for @navDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get navDiscover;

  /// No description provided for @navLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// No description provided for @navChats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get navChats;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @shareABook.
  ///
  /// In en, this message translates to:
  /// **'Share a book'**
  String get shareABook;

  /// No description provided for @notFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'This page is not here'**
  String get notFoundTitle;

  /// No description provided for @notFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'The link may be old or the book may have moved on.'**
  String get notFoundMessage;

  /// No description provided for @notFoundAction.
  ///
  /// In en, this message translates to:
  /// **'Back to Discover'**
  String get notFoundAction;

  /// No description provided for @discoverEyebrowNearby.
  ///
  /// In en, this message translates to:
  /// **'Books near you'**
  String get discoverEyebrowNearby;

  /// No description provided for @discoverEyebrowCircle.
  ///
  /// In en, this message translates to:
  /// **'Books in the circle'**
  String get discoverEyebrowCircle;

  /// No description provided for @discoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Find your next read'**
  String get discoverTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Title, author or genre'**
  String get searchHint;

  /// No description provided for @searchClear.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get searchClear;

  /// No description provided for @filtersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtersTitle;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterWithinKm.
  ///
  /// In en, this message translates to:
  /// **'Within {km} km'**
  String filterWithinKm(int km);

  /// No description provided for @filterAvailableNow.
  ///
  /// In en, this message translates to:
  /// **'Available now'**
  String get filterAvailableNow;

  /// No description provided for @conditionOrBetter.
  ///
  /// In en, this message translates to:
  /// **'{condition} or better'**
  String conditionOrBetter(String condition);

  /// No description provided for @loadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load books'**
  String get loadErrorTitle;

  /// No description provided for @resultCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 book} other{{count} books}}'**
  String resultCount(int count);

  /// No description provided for @resultSortNearest.
  ///
  /// In en, this message translates to:
  /// **'nearest first'**
  String get resultSortNearest;

  /// No description provided for @resultSortAround.
  ///
  /// In en, this message translates to:
  /// **'from readers around you'**
  String get resultSortAround;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No books here yet'**
  String get emptyTitle;

  /// No description provided for @emptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Be the first to put a book into the circle. Someone nearby is probably looking for it.'**
  String get emptyMessage;

  /// No description provided for @noResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No books match'**
  String get noResultsTitle;

  /// No description provided for @noResultsNearby.
  ///
  /// In en, this message translates to:
  /// **'Nothing within {km} km right now. Try a wider search or fewer filters.'**
  String noResultsNearby(int km);

  /// No description provided for @noResultsGeneric.
  ///
  /// In en, this message translates to:
  /// **'Try a different title or author, or loosen the filters.'**
  String get noResultsGeneric;

  /// No description provided for @statusShortReserved.
  ///
  /// In en, this message translates to:
  /// **'Reserved'**
  String get statusShortReserved;

  /// No description provided for @statusShortGone.
  ///
  /// In en, this message translates to:
  /// **'Gone'**
  String get statusShortGone;

  /// No description provided for @mapLoading.
  ///
  /// In en, this message translates to:
  /// **'Finding books around you'**
  String get mapLoading;

  /// No description provided for @mapBookCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No books match here} =1{1 book on the map} other{{count} books on the map}}'**
  String mapBookCount(int count);

  /// No description provided for @mapMyLocation.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get mapMyLocation;

  /// No description provided for @mapNothingMatches.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches your search and filters.'**
  String get mapNothingMatches;

  /// No description provided for @mapClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get mapClear;

  /// No description provided for @previewTitle.
  ///
  /// In en, this message translates to:
  /// **'On the map'**
  String get previewTitle;

  /// No description provided for @previewViewBook.
  ///
  /// In en, this message translates to:
  /// **'View this book'**
  String get previewViewBook;

  /// No description provided for @distanceAway.
  ///
  /// In en, this message translates to:
  /// **'{distance} away'**
  String distanceAway(String distance);

  /// No description provided for @locationServicesOff.
  ///
  /// In en, this message translates to:
  /// **'Turn on location services to see nearby books.'**
  String get locationServicesOff;

  /// No description provided for @locationDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Access Required'**
  String get locationDialogTitle;

  /// No description provided for @locationDialogBody.
  ///
  /// In en, this message translates to:
  /// **'{appName} needs your location to find and display nearby books available for exchange. Your location is only used locally to calculate distance and is not continuously tracked.'**
  String locationDialogBody(String appName);

  /// No description provided for @locationDeny.
  ///
  /// In en, this message translates to:
  /// **'Deny'**
  String get locationDeny;

  /// No description provided for @locationAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get locationAccept;

  /// No description provided for @locationPermissionNeeded.
  ///
  /// In en, this message translates to:
  /// **'Location permission is needed to show books near you.'**
  String get locationPermissionNeeded;

  /// No description provided for @locationOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get locationOpenSettings;

  /// No description provided for @locationFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not determine your location. Please try again.'**
  String get locationFailed;

  /// No description provided for @viewList.
  ///
  /// In en, this message translates to:
  /// **'List view'**
  String get viewList;

  /// No description provided for @viewMap.
  ///
  /// In en, this message translates to:
  /// **'Map view'**
  String get viewMap;

  /// No description provided for @filterSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Narrow down the books you see'**
  String get filterSheetSubtitle;

  /// No description provided for @filterSheetReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get filterSheetReset;

  /// No description provided for @filterSheetApply.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No books match} =1{Show 1 book} other{Show {count} books}}'**
  String filterSheetApply(int count);

  /// No description provided for @filterSectionMode.
  ///
  /// In en, this message translates to:
  /// **'How it is shared'**
  String get filterSectionMode;

  /// No description provided for @filterFreeToTake.
  ///
  /// In en, this message translates to:
  /// **'Free to take'**
  String get filterFreeToTake;

  /// No description provided for @filterSectionGenre.
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get filterSectionGenre;

  /// No description provided for @filterAnyGenre.
  ///
  /// In en, this message translates to:
  /// **'Any genre'**
  String get filterAnyGenre;

  /// No description provided for @filterSectionCondition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get filterSectionCondition;

  /// No description provided for @filterAnyCondition.
  ///
  /// In en, this message translates to:
  /// **'Any condition'**
  String get filterAnyCondition;

  /// No description provided for @filterNearMe.
  ///
  /// In en, this message translates to:
  /// **'Within {km} km of me'**
  String filterNearMe(int km);

  /// No description provided for @filterLocating.
  ///
  /// In en, this message translates to:
  /// **'Finding your location…'**
  String get filterLocating;

  /// No description provided for @filterNearMeHint.
  ///
  /// In en, this message translates to:
  /// **'Uses your location only to measure distance'**
  String get filterNearMeHint;

  /// No description provided for @filterAvailableHint.
  ///
  /// In en, this message translates to:
  /// **'Hide books that are already requested'**
  String get filterAvailableHint;
}

class _BrowseL10nDelegate extends LocalizationsDelegate<BrowseL10n> {
  const _BrowseL10nDelegate();

  @override
  Future<BrowseL10n> load(Locale locale) {
    return SynchronousFuture<BrowseL10n>(lookupBrowseL10n(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_BrowseL10nDelegate old) => false;
}

BrowseL10n lookupBrowseL10n(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn': return BrowseL10nBn();
    case 'en': return BrowseL10nEn();
  }

  throw FlutterError(
    'BrowseL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
