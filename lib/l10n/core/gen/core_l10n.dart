import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'core_l10n_bn.dart';
import 'core_l10n_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of CoreL10n
/// returned by `CoreL10n.of(context)`.
///
/// Applications need to include `CoreL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/core_l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: CoreL10n.localizationsDelegates,
///   supportedLocales: CoreL10n.supportedLocales,
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
/// be consistent with the languages listed in the CoreL10n.supportedLocales
/// property.
abstract class CoreL10n {
  CoreL10n(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static CoreL10n of(BuildContext context) {
    return Localizations.of<CoreL10n>(context, CoreL10n)!;
  }

  static const LocalizationsDelegate<CoreL10n> delegate = _CoreL10nDelegate();

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

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Boichokro'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Books that keep moving'**
  String get appTagline;

  /// No description provided for @languageBangla.
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get languageBangla;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the language you read best'**
  String get languageSubtitle;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonRetry;

  /// No description provided for @commonRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get commonRefresh;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get commonLoading;

  /// No description provided for @commonView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get commonView;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get commonShare;

  /// No description provided for @errorGenericTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGenericTitle;

  /// No description provided for @aReader.
  ///
  /// In en, this message translates to:
  /// **'A reader'**
  String get aReader;

  /// No description provided for @newMember.
  ///
  /// In en, this message translates to:
  /// **'New member'**
  String get newMember;

  /// No description provided for @swapCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 swap} other{{count} swaps}}'**
  String swapCount(int count);

  /// No description provided for @modeDonate.
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get modeDonate;

  /// No description provided for @modeExchange.
  ///
  /// In en, this message translates to:
  /// **'Exchange'**
  String get modeExchange;

  /// No description provided for @offerFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get offerFree;

  /// No description provided for @offerSwap.
  ///
  /// In en, this message translates to:
  /// **'Swap'**
  String get offerSwap;

  /// No description provided for @bookStatusAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get bookStatusAvailable;

  /// No description provided for @bookStatusRequested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get bookStatusRequested;

  /// No description provided for @bookStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Exchange pending'**
  String get bookStatusPending;

  /// No description provided for @bookStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get bookStatusCompleted;

  /// No description provided for @requestStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get requestStatusPending;

  /// No description provided for @requestStatusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get requestStatusAccepted;

  /// No description provided for @requestStatusDeclined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get requestStatusDeclined;

  /// No description provided for @requestStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get requestStatusCancelled;

  /// No description provided for @requestStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get requestStatusCompleted;

  /// No description provided for @exchangeMeetup.
  ///
  /// In en, this message translates to:
  /// **'Meet in person'**
  String get exchangeMeetup;

  /// No description provided for @exchangeCourier.
  ///
  /// In en, this message translates to:
  /// **'Courier service'**
  String get exchangeCourier;

  /// No description provided for @conditionLikeNew.
  ///
  /// In en, this message translates to:
  /// **'Like New'**
  String get conditionLikeNew;

  /// No description provided for @conditionVeryGood.
  ///
  /// In en, this message translates to:
  /// **'Very Good'**
  String get conditionVeryGood;

  /// No description provided for @conditionGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get conditionGood;

  /// No description provided for @conditionFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get conditionFair;

  /// No description provided for @conditionWorn.
  ///
  /// In en, this message translates to:
  /// **'Worn'**
  String get conditionWorn;

  /// No description provided for @genreFiction.
  ///
  /// In en, this message translates to:
  /// **'Fiction'**
  String get genreFiction;

  /// No description provided for @genreNonFiction.
  ///
  /// In en, this message translates to:
  /// **'Non-Fiction'**
  String get genreNonFiction;

  /// No description provided for @genreScienceFiction.
  ///
  /// In en, this message translates to:
  /// **'Science Fiction'**
  String get genreScienceFiction;

  /// No description provided for @genreFantasy.
  ///
  /// In en, this message translates to:
  /// **'Fantasy'**
  String get genreFantasy;

  /// No description provided for @genreMystery.
  ///
  /// In en, this message translates to:
  /// **'Mystery'**
  String get genreMystery;

  /// No description provided for @genreThriller.
  ///
  /// In en, this message translates to:
  /// **'Thriller'**
  String get genreThriller;

  /// No description provided for @genreRomance.
  ///
  /// In en, this message translates to:
  /// **'Romance'**
  String get genreRomance;

  /// No description provided for @genreBiography.
  ///
  /// In en, this message translates to:
  /// **'Biography'**
  String get genreBiography;

  /// No description provided for @genreHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get genreHistory;

  /// No description provided for @genreSelfHelp.
  ///
  /// In en, this message translates to:
  /// **'Self-Help'**
  String get genreSelfHelp;

  /// No description provided for @genreBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get genreBusiness;

  /// No description provided for @genreScience.
  ///
  /// In en, this message translates to:
  /// **'Science'**
  String get genreScience;

  /// No description provided for @genrePhilosophy.
  ///
  /// In en, this message translates to:
  /// **'Philosophy'**
  String get genrePhilosophy;

  /// No description provided for @genrePoetry.
  ///
  /// In en, this message translates to:
  /// **'Poetry'**
  String get genrePoetry;

  /// No description provided for @genreComics.
  ///
  /// In en, this message translates to:
  /// **'Comics'**
  String get genreComics;

  /// No description provided for @genreChildren.
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get genreChildren;

  /// No description provided for @genreYoungAdult.
  ///
  /// In en, this message translates to:
  /// **'Young Adult'**
  String get genreYoungAdult;

  /// No description provided for @genreOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get genreOther;

  /// No description provided for @timeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String timeMinutesAgo(int count);

  /// No description provided for @timeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String timeHoursAgo(int count);

  /// No description provided for @timeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String timeDaysAgo(int count);

  /// No description provided for @timeMonthsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}mo ago'**
  String timeMonthsAgo(int count);

  /// No description provided for @timeYearsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}y ago'**
  String timeYearsAgo(int count);

  /// No description provided for @distanceMeters.
  ///
  /// In en, this message translates to:
  /// **'{value} m'**
  String distanceMeters(int value);

  /// No description provided for @distanceKm.
  ///
  /// In en, this message translates to:
  /// **'{value} km'**
  String distanceKm(String value);
}

class _CoreL10nDelegate extends LocalizationsDelegate<CoreL10n> {
  const _CoreL10nDelegate();

  @override
  Future<CoreL10n> load(Locale locale) {
    return SynchronousFuture<CoreL10n>(lookupCoreL10n(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_CoreL10nDelegate old) => false;
}

CoreL10n lookupCoreL10n(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn': return CoreL10nBn();
    case 'en': return CoreL10nEn();
  }

  throw FlutterError(
    'CoreL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
