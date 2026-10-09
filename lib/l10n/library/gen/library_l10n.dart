import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'library_l10n_bn.dart';
import 'library_l10n_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of LibraryL10n
/// returned by `LibraryL10n.of(context)`.
///
/// Applications need to include `LibraryL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/library_l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: LibraryL10n.localizationsDelegates,
///   supportedLocales: LibraryL10n.supportedLocales,
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
/// be consistent with the languages listed in the LibraryL10n.supportedLocales
/// property.
abstract class LibraryL10n {
  LibraryL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static LibraryL10n of(BuildContext context) {
    return Localizations.of<LibraryL10n>(context, LibraryL10n)!;
  }

  static const LocalizationsDelegate<LibraryL10n> delegate =
      _LibraryL10nDelegate();

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

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'My library'**
  String get libraryTitle;

  /// No description provided for @summarySignedOut.
  ///
  /// In en, this message translates to:
  /// **'Sign in to share and request books'**
  String get summarySignedOut;

  /// No description provided for @summaryLoading.
  ///
  /// In en, this message translates to:
  /// **'Opening your shelf…'**
  String get summaryLoading;

  /// No description provided for @summaryBooksShared.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No books shared yet} =1{1 book shared} other{{count} books shared}}'**
  String summaryBooksShared(int count);

  /// No description provided for @summaryRequestsWaiting.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 request waiting} other{{count} requests waiting}}'**
  String summaryRequestsWaiting(int count);

  /// No description provided for @summaryHandOffsInProgress.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hand-off in progress} other{{count} hand-offs in progress}}'**
  String summaryHandOffsInProgress(int count);

  /// No description provided for @tabMyBooks.
  ///
  /// In en, this message translates to:
  /// **'My books'**
  String get tabMyBooks;

  /// No description provided for @tabMyRequests.
  ///
  /// In en, this message translates to:
  /// **'My requests'**
  String get tabMyRequests;

  /// No description provided for @tabRequestsToMe.
  ///
  /// In en, this message translates to:
  /// **'Requests to me'**
  String get tabRequestsToMe;

  /// No description provided for @tabHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get tabHistory;

  /// No description provided for @signedOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Your library lives here'**
  String get signedOutTitle;

  /// No description provided for @signedOutMessage.
  ///
  /// In en, this message translates to:
  /// **'Sign in to share your books, ask for others and follow every hand-off.'**
  String get signedOutMessage;

  /// No description provided for @signInAction.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInAction;

  /// No description provided for @booksLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load your books'**
  String get booksLoadErrorTitle;

  /// No description provided for @requestsLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load your requests'**
  String get requestsLoadErrorTitle;

  /// No description provided for @emptyBooksTitle.
  ///
  /// In en, this message translates to:
  /// **'Your shelf is empty'**
  String get emptyBooksTitle;

  /// No description provided for @emptyBooksMessage.
  ///
  /// In en, this message translates to:
  /// **'Share a book you have finished. A reader nearby may be looking for exactly that one.'**
  String get emptyBooksMessage;

  /// No description provided for @addBookAction.
  ///
  /// In en, this message translates to:
  /// **'Add a book'**
  String get addBookAction;

  /// No description provided for @emptySentTitle.
  ///
  /// In en, this message translates to:
  /// **'No requests on the way'**
  String get emptySentTitle;

  /// No description provided for @emptySentMessage.
  ///
  /// In en, this message translates to:
  /// **'When you ask for a book, you can follow its journey here, from request to hand-off.'**
  String get emptySentMessage;

  /// No description provided for @discoverBooksAction.
  ///
  /// In en, this message translates to:
  /// **'Discover books'**
  String get discoverBooksAction;

  /// No description provided for @emptyReceivedTitle.
  ///
  /// In en, this message translates to:
  /// **'No one has asked yet'**
  String get emptyReceivedTitle;

  /// No description provided for @emptyReceivedMessage.
  ///
  /// In en, this message translates to:
  /// **'When a reader asks for one of your books, their request shows up here for you to accept or decline.'**
  String get emptyReceivedMessage;

  /// No description provided for @emptyHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get emptyHistoryTitle;

  /// No description provided for @emptyHistoryMessage.
  ///
  /// In en, this message translates to:
  /// **'Completed, declined and cancelled requests are kept here, along with the reviews you exchange.'**
  String get emptyHistoryMessage;

  /// No description provided for @snackBookRemoved.
  ///
  /// In en, this message translates to:
  /// **'Book removed from your library'**
  String get snackBookRemoved;

  /// No description provided for @bookOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Book options'**
  String get bookOptionsTitle;

  /// No description provided for @bookLockedCompleted.
  ///
  /// In en, this message translates to:
  /// **'This book has already found its reader, so it can no longer be edited or removed.'**
  String get bookLockedCompleted;

  /// No description provided for @bookLockedInRequest.
  ///
  /// In en, this message translates to:
  /// **'This book is part of a request right now. You can edit or remove it once that is settled.'**
  String get bookLockedInRequest;

  /// No description provided for @bookActionView.
  ///
  /// In en, this message translates to:
  /// **'View book'**
  String get bookActionView;

  /// No description provided for @bookActionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit details'**
  String get bookActionEdit;

  /// No description provided for @bookActionRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from library'**
  String get bookActionRemove;

  /// No description provided for @deleteBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this book?'**
  String get deleteBookTitle;

  /// No description provided for @deleteBookMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" will be taken off Boichokro and readers will no longer be able to ask for it. This cannot be undone.'**
  String deleteBookMessage(String title);

  /// No description provided for @deleteBookConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get deleteBookConfirm;

  /// No description provided for @keepItAction.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get keepItAction;

  /// No description provided for @snackRequestAccepted.
  ///
  /// In en, this message translates to:
  /// **'Request accepted. Use the chat to arrange the hand-off.'**
  String get snackRequestAccepted;

  /// No description provided for @declineDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Decline this request?'**
  String get declineDialogTitle;

  /// No description provided for @declineDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} will see that you declined. Your book stays available for other readers.'**
  String declineDialogMessage(String name);

  /// No description provided for @declineAction.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get declineAction;

  /// No description provided for @notNowAction.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNowAction;

  /// No description provided for @snackRequestDeclined.
  ///
  /// In en, this message translates to:
  /// **'Request declined'**
  String get snackRequestDeclined;

  /// No description provided for @cancelDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel your request?'**
  String get cancelDialogTitle;

  /// No description provided for @cancelDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'The owner will see that you no longer need this book. You can ask for it again later if it is still available.'**
  String get cancelDialogMessage;

  /// No description provided for @cancelRequestAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get cancelRequestAction;

  /// No description provided for @snackRequestCancelled.
  ///
  /// In en, this message translates to:
  /// **'Request cancelled'**
  String get snackRequestCancelled;

  /// No description provided for @confirmReceivedTitle.
  ///
  /// In en, this message translates to:
  /// **'Did you receive the book?'**
  String get confirmReceivedTitle;

  /// No description provided for @confirmHandedOverTitle.
  ///
  /// In en, this message translates to:
  /// **'Did you hand it over?'**
  String get confirmHandedOverTitle;

  /// No description provided for @confirmReceivedMessage.
  ///
  /// In en, this message translates to:
  /// **'Confirm only once the book is in your hands.'**
  String get confirmReceivedMessage;

  /// No description provided for @confirmHandedOverMessage.
  ///
  /// In en, this message translates to:
  /// **'Confirm only once the reader has the book.'**
  String get confirmHandedOverMessage;

  /// No description provided for @confirmDetailCompletes.
  ///
  /// In en, this message translates to:
  /// **'This completes the exchange, and you can then review each other.'**
  String get confirmDetailCompletes;

  /// No description provided for @confirmDetailWaitsOther.
  ///
  /// In en, this message translates to:
  /// **'The exchange completes when the other person confirms too.'**
  String get confirmDetailWaitsOther;

  /// No description provided for @confirmReceivedYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, I have it'**
  String get confirmReceivedYes;

  /// No description provided for @confirmHandedOverYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, handed over'**
  String get confirmHandedOverYes;

  /// No description provided for @notYetAction.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get notYetAction;

  /// No description provided for @snackExchangeComplete.
  ///
  /// In en, this message translates to:
  /// **'Exchange complete. You can now leave a review.'**
  String get snackExchangeComplete;

  /// No description provided for @snackConfirmedWaiting.
  ///
  /// In en, this message translates to:
  /// **'Confirmed. Waiting for the other person to confirm too.'**
  String get snackConfirmedWaiting;

  /// No description provided for @snackReviewSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Review submitted. Thank you!'**
  String get snackReviewSubmitted;

  /// No description provided for @missingBookTitle.
  ///
  /// In en, this message translates to:
  /// **'A book that is no longer listed'**
  String get missingBookTitle;

  /// No description provided for @bookNextPeopleAsked.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 person asked for this} other{{count} people asked for this}}'**
  String bookNextPeopleAsked(int count);

  /// No description provided for @bookNextSomeoneAsked.
  ///
  /// In en, this message translates to:
  /// **'Someone asked for this'**
  String get bookNextSomeoneAsked;

  /// No description provided for @bookNextHandOff.
  ///
  /// In en, this message translates to:
  /// **'Hand-off in progress'**
  String get bookNextHandOff;

  /// No description provided for @bookNextFoundReader.
  ///
  /// In en, this message translates to:
  /// **'Found a new reader'**
  String get bookNextFoundReader;

  /// No description provided for @fallbackOwner.
  ///
  /// In en, this message translates to:
  /// **'The owner'**
  String get fallbackOwner;

  /// No description provided for @fallbackOwnerInline.
  ///
  /// In en, this message translates to:
  /// **'the owner'**
  String get fallbackOwnerInline;

  /// No description provided for @fallbackReader.
  ///
  /// In en, this message translates to:
  /// **'The reader'**
  String get fallbackReader;

  /// No description provided for @fallbackReaderInline.
  ///
  /// In en, this message translates to:
  /// **'the reader'**
  String get fallbackReaderInline;

  /// No description provided for @captionYouAsked.
  ///
  /// In en, this message translates to:
  /// **'You asked'**
  String get captionYouAsked;

  /// No description provided for @captionAskedBy.
  ///
  /// In en, this message translates to:
  /// **'Asked by'**
  String get captionAskedBy;

  /// No description provided for @askedTime.
  ///
  /// In en, this message translates to:
  /// **'Asked {time}'**
  String askedTime(String time);

  /// No description provided for @youOfferedInReturn.
  ///
  /// In en, this message translates to:
  /// **'You offered in return'**
  String get youOfferedInReturn;

  /// No description provided for @offeredInReturn.
  ///
  /// In en, this message translates to:
  /// **'Offered in return'**
  String get offeredInReturn;

  /// No description provided for @pillYouConfirmed.
  ///
  /// In en, this message translates to:
  /// **'You: confirmed'**
  String get pillYouConfirmed;

  /// No description provided for @pillYouNotYet.
  ///
  /// In en, this message translates to:
  /// **'You: not yet'**
  String get pillYouNotYet;

  /// No description provided for @pillOwnerConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Owner: confirmed'**
  String get pillOwnerConfirmed;

  /// No description provided for @pillOwnerNotYet.
  ///
  /// In en, this message translates to:
  /// **'Owner: not yet'**
  String get pillOwnerNotYet;

  /// No description provided for @pillReaderConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Reader: confirmed'**
  String get pillReaderConfirmed;

  /// No description provided for @pillReaderNotYet.
  ///
  /// In en, this message translates to:
  /// **'Reader: not yet'**
  String get pillReaderNotYet;

  /// No description provided for @requestBannerWaitingTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting for {name}'**
  String requestBannerWaitingTitle(String name);

  /// No description provided for @requestBannerWaitingMessage.
  ///
  /// In en, this message translates to:
  /// **'They will accept or decline your request. You can cancel it any time before then.'**
  String get requestBannerWaitingMessage;

  /// No description provided for @requestBannerSwapOfferTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} is offering a swap'**
  String requestBannerSwapOfferTitle(String name);

  /// No description provided for @requestBannerWantsBookTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} would like this book'**
  String requestBannerWantsBookTitle(String name);

  /// No description provided for @requestBannerIncomingMessage.
  ///
  /// In en, this message translates to:
  /// **'Accepting opens a chat to arrange the hand-off and declines any other requests for this book.'**
  String get requestBannerIncomingMessage;

  /// No description provided for @requestBannerYouConfirmedTitle.
  ///
  /// In en, this message translates to:
  /// **'You have confirmed'**
  String get requestBannerYouConfirmedTitle;

  /// No description provided for @requestBannerYouConfirmedMessage.
  ///
  /// In en, this message translates to:
  /// **'Waiting for {name} to confirm the hand-off too.'**
  String requestBannerYouConfirmedMessage(String name);

  /// No description provided for @requestBannerYourTurnTitle.
  ///
  /// In en, this message translates to:
  /// **'Your turn to confirm'**
  String get requestBannerYourTurnTitle;

  /// No description provided for @requestBannerYourTurnSeekerMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} confirmed handing the book over. Confirm once it is in your hands to complete the exchange.'**
  String requestBannerYourTurnSeekerMessage(String name);

  /// No description provided for @requestBannerYourTurnOwnerMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} confirmed receiving the book. Confirm on your side to complete the exchange.'**
  String requestBannerYourTurnOwnerMessage(String name);

  /// No description provided for @requestBannerSaidYesTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} said yes'**
  String requestBannerSaidYesTitle(String name);

  /// No description provided for @requestBannerHandOverTitle.
  ///
  /// In en, this message translates to:
  /// **'Time to hand it over'**
  String get requestBannerHandOverTitle;

  /// No description provided for @requestBannerArrangeSeekerMessage.
  ///
  /// In en, this message translates to:
  /// **'Agree on a time and place in chat. Once the book is in your hands, confirm it here.'**
  String get requestBannerArrangeSeekerMessage;

  /// No description provided for @requestBannerArrangeOwnerMessage.
  ///
  /// In en, this message translates to:
  /// **'Agree on a time and place in chat. Once you have handed the book over, confirm it here.'**
  String get requestBannerArrangeOwnerMessage;

  /// No description provided for @handOffEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Hand-off'**
  String get handOffEyebrow;

  /// No description provided for @trackingId.
  ///
  /// In en, this message translates to:
  /// **'Tracking {id}'**
  String trackingId(String id);

  /// No description provided for @acceptAction.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptAction;

  /// No description provided for @receivedBookAction.
  ///
  /// In en, this message translates to:
  /// **'I received the book'**
  String get receivedBookAction;

  /// No description provided for @handedOverAction.
  ///
  /// In en, this message translates to:
  /// **'I handed it over'**
  String get handedOverAction;

  /// No description provided for @arrangeInChatAction.
  ///
  /// In en, this message translates to:
  /// **'Arrange hand-off in chat'**
  String get arrangeInChatAction;

  /// No description provided for @openChatAction.
  ///
  /// In en, this message translates to:
  /// **'Open chat'**
  String get openChatAction;

  /// No description provided for @historyReceivedFrom.
  ///
  /// In en, this message translates to:
  /// **'You received this from {name}'**
  String historyReceivedFrom(String name);

  /// No description provided for @historyGaveTo.
  ///
  /// In en, this message translates to:
  /// **'You gave this to {name}'**
  String historyGaveTo(String name);

  /// No description provided for @historyTheyDeclined.
  ///
  /// In en, this message translates to:
  /// **'{name} declined your request'**
  String historyTheyDeclined(String name);

  /// No description provided for @historyYouDeclined.
  ///
  /// In en, this message translates to:
  /// **'You declined the request from {name}'**
  String historyYouDeclined(String name);

  /// No description provided for @historyYouCancelled.
  ///
  /// In en, this message translates to:
  /// **'You cancelled your request to {name}'**
  String historyYouCancelled(String name);

  /// No description provided for @historyTheyCancelled.
  ///
  /// In en, this message translates to:
  /// **'{name} cancelled their request'**
  String historyTheyCancelled(String name);

  /// No description provided for @historyYouAsked.
  ///
  /// In en, this message translates to:
  /// **'You asked {name}'**
  String historyYouAsked(String name);

  /// No description provided for @historyTheyAsked.
  ///
  /// In en, this message translates to:
  /// **'{name} asked for this book'**
  String historyTheyAsked(String name);

  /// No description provided for @reviewYouRated.
  ///
  /// In en, this message translates to:
  /// **'You rated'**
  String get reviewYouRated;

  /// No description provided for @reviewTheyRated.
  ///
  /// In en, this message translates to:
  /// **'They rated you'**
  String get reviewTheyRated;

  /// No description provided for @reviewPrompt.
  ///
  /// In en, this message translates to:
  /// **'How was your exchange with {name}? Your review helps other readers trust them.'**
  String reviewPrompt(String name);

  /// No description provided for @leaveReviewAction.
  ///
  /// In en, this message translates to:
  /// **'Leave a review'**
  String get leaveReviewAction;

  /// No description provided for @reviewNotLeftYet.
  ///
  /// In en, this message translates to:
  /// **'{name} has not left a review yet.'**
  String reviewNotLeftYet(String name);

  /// No description provided for @reviewQuote.
  ///
  /// In en, this message translates to:
  /// **'\"{text}\"'**
  String reviewQuote(String text);

  /// No description provided for @reviewSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How did the exchange go?'**
  String get reviewSheetSubtitle;

  /// No description provided for @reviewSheetSubtitleNamed.
  ///
  /// In en, this message translates to:
  /// **'How was your exchange with {name}?'**
  String reviewSheetSubtitleNamed(String name);

  /// No description provided for @submitReviewAction.
  ///
  /// In en, this message translates to:
  /// **'Submit review'**
  String get submitReviewAction;

  /// No description provided for @ratingLabelNotGood.
  ///
  /// In en, this message translates to:
  /// **'Not good'**
  String get ratingLabelNotGood;

  /// No description provided for @ratingLabelCouldBeBetter.
  ///
  /// In en, this message translates to:
  /// **'Could be better'**
  String get ratingLabelCouldBeBetter;

  /// No description provided for @ratingLabelOkay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get ratingLabelOkay;

  /// No description provided for @ratingLabelGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get ratingLabelGood;

  /// No description provided for @ratingLabelExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get ratingLabelExcellent;

  /// No description provided for @reviewFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Your review (optional)'**
  String get reviewFieldLabel;

  /// No description provided for @reviewFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Was the book as described? Were they easy to meet?'**
  String get reviewFieldHint;

  /// No description provided for @reviewShareNote.
  ///
  /// In en, this message translates to:
  /// **'Your rating is shared with them and counts towards their profile.'**
  String get reviewShareNote;

  /// No description provided for @journeyEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Journey'**
  String get journeyEyebrow;

  /// No description provided for @journeyHideSteps.
  ///
  /// In en, this message translates to:
  /// **'Hide journey steps'**
  String get journeyHideSteps;

  /// No description provided for @journeyShowSteps.
  ///
  /// In en, this message translates to:
  /// **'Show journey steps'**
  String get journeyShowSteps;

  /// No description provided for @journeySummaryDeclined.
  ///
  /// In en, this message translates to:
  /// **'Ended · request declined'**
  String get journeySummaryDeclined;

  /// No description provided for @journeySummaryCancelled.
  ///
  /// In en, this message translates to:
  /// **'Ended · request cancelled'**
  String get journeySummaryCancelled;

  /// No description provided for @journeySummaryComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete · reviewed and done'**
  String get journeySummaryComplete;

  /// No description provided for @journeySummaryProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done · Next: {next}'**
  String journeySummaryProgress(int done, int total, String next);

  /// No description provided for @journeyStepRequested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get journeyStepRequested;

  /// No description provided for @journeyStepDeclined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get journeyStepDeclined;

  /// No description provided for @journeyStepCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get journeyStepCancelled;

  /// No description provided for @journeyStepAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get journeyStepAccepted;

  /// No description provided for @journeyStepHandOffArranged.
  ///
  /// In en, this message translates to:
  /// **'Hand-off arranged'**
  String get journeyStepHandOffArranged;

  /// No description provided for @journeyStepBothConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Both confirmed'**
  String get journeyStepBothConfirmed;

  /// No description provided for @journeyStepReviewed.
  ///
  /// In en, this message translates to:
  /// **'Reviewed'**
  String get journeyStepReviewed;

  /// No description provided for @journeyRequestedSeeker.
  ///
  /// In en, this message translates to:
  /// **'You asked for this book · {time}'**
  String journeyRequestedSeeker(String time);

  /// No description provided for @journeyRequestedOwner.
  ///
  /// In en, this message translates to:
  /// **'A reader asked for your book · {time}'**
  String journeyRequestedOwner(String time);

  /// No description provided for @journeyDeclinedSeeker.
  ///
  /// In en, this message translates to:
  /// **'The owner could not share this book this time'**
  String get journeyDeclinedSeeker;

  /// No description provided for @journeyDeclinedOwner.
  ///
  /// In en, this message translates to:
  /// **'You declined this request'**
  String get journeyDeclinedOwner;

  /// No description provided for @journeyCancelledSeeker.
  ///
  /// In en, this message translates to:
  /// **'You cancelled this request'**
  String get journeyCancelledSeeker;

  /// No description provided for @journeyCancelledOwner.
  ///
  /// In en, this message translates to:
  /// **'The reader cancelled their request'**
  String get journeyCancelledOwner;

  /// No description provided for @journeyWaitingOwnerReply.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the owner to reply'**
  String get journeyWaitingOwnerReply;

  /// No description provided for @journeyWaitingYourReply.
  ///
  /// In en, this message translates to:
  /// **'Waiting for your reply'**
  String get journeyWaitingYourReply;

  /// No description provided for @journeyArrangeHint.
  ///
  /// In en, this message translates to:
  /// **'Agree on a time and place in chat'**
  String get journeyArrangeHint;

  /// No description provided for @journeyChangedHands.
  ///
  /// In en, this message translates to:
  /// **'The book changed hands'**
  String get journeyChangedHands;

  /// No description provided for @journeyBothConfirmedFinishing.
  ///
  /// In en, this message translates to:
  /// **'Both confirmed · finishing up'**
  String get journeyBothConfirmedFinishing;

  /// No description provided for @journeyReviewPrompt.
  ///
  /// In en, this message translates to:
  /// **'Leave a review to close the loop'**
  String get journeyReviewPrompt;

  /// No description provided for @journeyYouRated.
  ///
  /// In en, this message translates to:
  /// **'You rated {rating}'**
  String journeyYouRated(String rating);

  /// No description provided for @journeyBothRated.
  ///
  /// In en, this message translates to:
  /// **'You rated {mine} · they rated you {theirs}'**
  String journeyBothRated(String mine, String theirs);

  /// No description provided for @journeyNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get journeyNow;
}

class _LibraryL10nDelegate extends LocalizationsDelegate<LibraryL10n> {
  const _LibraryL10nDelegate();

  @override
  Future<LibraryL10n> load(Locale locale) {
    return SynchronousFuture<LibraryL10n>(lookupLibraryL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_LibraryL10nDelegate old) => false;
}

LibraryL10n lookupLibraryL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return LibraryL10nBn();
    case 'en':
      return LibraryL10nEn();
  }

  throw FlutterError(
    'LibraryL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
