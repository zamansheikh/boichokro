import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'chat_l10n_bn.dart';
import 'chat_l10n_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of ChatL10n
/// returned by `ChatL10n.of(context)`.
///
/// Applications need to include `ChatL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/chat_l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: ChatL10n.localizationsDelegates,
///   supportedLocales: ChatL10n.supportedLocales,
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
/// be consistent with the languages listed in the ChatL10n.supportedLocales
/// property.
abstract class ChatL10n {
  ChatL10n(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static ChatL10n of(BuildContext context) {
    return Localizations.of<ChatL10n>(context, ChatL10n)!;
  }

  static const LocalizationsDelegate<ChatL10n> delegate = _ChatL10nDelegate();

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

  /// No description provided for @chatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chatsTitle;

  /// No description provided for @chatsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Arrange hand-overs with other readers'**
  String get chatsSubtitle;

  /// No description provided for @unreadSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 conversation has new messages} other{{count} conversations have new messages}}'**
  String unreadSummary(int count);

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to view chats'**
  String get signInTitle;

  /// No description provided for @signInMessage.
  ///
  /// In en, this message translates to:
  /// **'Your conversations with other readers will appear here once you are signed in.'**
  String get signInMessage;

  /// No description provided for @emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get emptyTitle;

  /// No description provided for @emptyMessage.
  ///
  /// In en, this message translates to:
  /// **'A chat opens when you request a book, or when someone requests one of yours. Find a book you like to get started.'**
  String get emptyMessage;

  /// No description provided for @emptyAction.
  ///
  /// In en, this message translates to:
  /// **'Discover books'**
  String get emptyAction;

  /// No description provided for @previewEmpty.
  ///
  /// In en, this message translates to:
  /// **'Say hello to get things started'**
  String get previewEmpty;

  /// No description provided for @previewLocation.
  ///
  /// In en, this message translates to:
  /// **'Shared a location'**
  String get previewLocation;

  /// No description provided for @readerFallbackName.
  ///
  /// In en, this message translates to:
  /// **'Reader'**
  String get readerFallbackName;

  /// No description provided for @namePair.
  ///
  /// In en, this message translates to:
  /// **'{first} & {second}'**
  String namePair(String first, String second);

  /// No description provided for @dayToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dayToday;

  /// No description provided for @dayYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dayYesterday;

  /// DateFormat pattern for a day separator in the current year.
  ///
  /// In en, this message translates to:
  /// **'MMMM d'**
  String get dayFormat;

  /// DateFormat pattern for a day separator in an earlier year.
  ///
  /// In en, this message translates to:
  /// **'MMMM d, y'**
  String get dayFormatWithYear;

  /// No description provided for @unreadBadgeLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} unread'**
  String unreadBadgeLabel(int count);

  /// No description provided for @chatFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatFallbackTitle;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// No description provided for @menuViewBook.
  ///
  /// In en, this message translates to:
  /// **'View book details'**
  String get menuViewBook;

  /// No description provided for @menuReportUser.
  ///
  /// In en, this message translates to:
  /// **'Report user'**
  String get menuReportUser;

  /// No description provided for @menuBlockUser.
  ///
  /// In en, this message translates to:
  /// **'Block user'**
  String get menuBlockUser;

  /// No description provided for @openChatFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open this chat'**
  String get openChatFailed;

  /// No description provided for @openingConversation.
  ///
  /// In en, this message translates to:
  /// **'Opening conversation'**
  String get openingConversation;

  /// No description provided for @loadMessagesFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load messages'**
  String get loadMessagesFailed;

  /// No description provided for @bookFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Book in this chat'**
  String get bookFallbackTitle;

  /// No description provided for @bookYours.
  ///
  /// In en, this message translates to:
  /// **'Your book · {name} asked about it'**
  String bookYours(String name);

  /// No description provided for @bookSharedBy.
  ///
  /// In en, this message translates to:
  /// **'Shared by {name}'**
  String bookSharedBy(String name);

  /// No description provided for @bookRequestedBy.
  ///
  /// In en, this message translates to:
  /// **'requested by {name}'**
  String bookRequestedBy(String name);

  /// No description provided for @emptyConversationTitle.
  ///
  /// In en, this message translates to:
  /// **'Start the conversation'**
  String get emptyConversationTitle;

  /// No description provided for @emptyConversationMessage.
  ///
  /// In en, this message translates to:
  /// **'Say hello to {name} and agree on how to hand the book over. Tap a suggestion to use it.'**
  String emptyConversationMessage(String name);

  /// No description provided for @starterAvailable.
  ///
  /// In en, this message translates to:
  /// **'Hi! Is the book still available?'**
  String get starterAvailable;

  /// No description provided for @starterAvailableBook.
  ///
  /// In en, this message translates to:
  /// **'Hi! Is \"{book}\" still available?'**
  String starterAvailableBook(String book);

  /// No description provided for @starterMeet.
  ///
  /// In en, this message translates to:
  /// **'When and where would be good to meet?'**
  String get starterMeet;

  /// No description provided for @starterThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you for sharing this book!'**
  String get starterThanks;

  /// No description provided for @safetyTipTitle.
  ///
  /// In en, this message translates to:
  /// **'Meet safely'**
  String get safetyTipTitle;

  /// No description provided for @safetyTipMessage.
  ///
  /// In en, this message translates to:
  /// **'Hand books over in a busy public place during the day, and never send money or personal details in chat.'**
  String get safetyTipMessage;

  /// No description provided for @safetyTipAction.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get safetyTipAction;

  /// No description provided for @composerHint.
  ///
  /// In en, this message translates to:
  /// **'Write a message'**
  String get composerHint;

  /// No description provided for @sendTooltip.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendTooltip;

  /// No description provided for @shareLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Share your location'**
  String get shareLocationTitle;

  /// No description provided for @shareLocationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sends a map pin of where you are right now.'**
  String get shareLocationSubtitle;

  /// No description provided for @shareLocationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Share pin'**
  String get shareLocationConfirm;

  /// No description provided for @shareCareTitle.
  ///
  /// In en, this message translates to:
  /// **'Share with care'**
  String get shareCareTitle;

  /// No description provided for @shareCareMessage.
  ///
  /// In en, this message translates to:
  /// **'Only share your location when you are ready to meet, and pick a busy public place rather than your home.'**
  String get shareCareMessage;

  /// No description provided for @locationServicesOff.
  ///
  /// In en, this message translates to:
  /// **'Turn on location services to share a pin.'**
  String get locationServicesOff;

  /// No description provided for @locationPermissionNeeded.
  ///
  /// In en, this message translates to:
  /// **'Location permission is needed to share a pin.'**
  String get locationPermissionNeeded;

  /// No description provided for @locationFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not get your location. Please try again.'**
  String get locationFailed;

  /// No description provided for @mapsOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open a maps app.'**
  String get mapsOpenFailed;

  /// No description provided for @locationSharedByYou.
  ///
  /// In en, this message translates to:
  /// **'You shared a location'**
  String get locationSharedByYou;

  /// No description provided for @locationShared.
  ///
  /// In en, this message translates to:
  /// **'Shared location'**
  String get locationShared;

  /// No description provided for @locationOpenHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to open in maps'**
  String get locationOpenHint;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report user'**
  String get reportTitle;

  /// No description provided for @reportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us what is wrong with {name}.'**
  String reportSubtitle(String name);

  /// No description provided for @reportSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit report'**
  String get reportSubmit;

  /// No description provided for @reasonSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get reasonSpam;

  /// No description provided for @reasonHarassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment'**
  String get reasonHarassment;

  /// No description provided for @reasonInappropriate.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate content'**
  String get reasonInappropriate;

  /// No description provided for @reasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reasonOther;

  /// No description provided for @blockTitle.
  ///
  /// In en, this message translates to:
  /// **'Block {name}?'**
  String blockTitle(String name);

  /// No description provided for @blockMessage.
  ///
  /// In en, this message translates to:
  /// **'You will no longer receive messages from them, and they will not be able to interact with your books.'**
  String get blockMessage;

  /// No description provided for @blockAction.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get blockAction;
}

class _ChatL10nDelegate extends LocalizationsDelegate<ChatL10n> {
  const _ChatL10nDelegate();

  @override
  Future<ChatL10n> load(Locale locale) {
    return SynchronousFuture<ChatL10n>(lookupChatL10n(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_ChatL10nDelegate old) => false;
}

ChatL10n lookupChatL10n(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn': return ChatL10nBn();
    case 'en': return ChatL10nEn();
  }

  throw FlutterError(
    'ChatL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
