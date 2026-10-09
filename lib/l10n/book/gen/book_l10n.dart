import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'book_l10n_bn.dart';
import 'book_l10n_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of BookL10n
/// returned by `BookL10n.of(context)`.
///
/// Applications need to include `BookL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/book_l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: BookL10n.localizationsDelegates,
///   supportedLocales: BookL10n.supportedLocales,
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
/// be consistent with the languages listed in the BookL10n.supportedLocales
/// property.
abstract class BookL10n {
  BookL10n(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static BookL10n of(BuildContext context) {
    return Localizations.of<BookL10n>(context, BookL10n)!;
  }

  static const LocalizationsDelegate<BookL10n> delegate = _BookL10nDelegate();

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

  /// No description provided for @listingRemovedSnack.
  ///
  /// In en, this message translates to:
  /// **'Your listing was removed.'**
  String get listingRemovedSnack;

  /// No description provided for @shareTooltip.
  ///
  /// In en, this message translates to:
  /// **'Share this book'**
  String get shareTooltip;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// No description provided for @openErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t open this book'**
  String get openErrorTitle;

  /// No description provided for @removedTitle.
  ///
  /// In en, this message translates to:
  /// **'This listing was removed'**
  String get removedTitle;

  /// No description provided for @removedMessage.
  ///
  /// In en, this message translates to:
  /// **'The book is no longer on Boichokro.'**
  String get removedMessage;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// No description provided for @notFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Book not found'**
  String get notFoundTitle;

  /// No description provided for @notFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'It may have been removed by its owner.'**
  String get notFoundMessage;

  /// No description provided for @yourListingPill.
  ///
  /// In en, this message translates to:
  /// **'Your listing'**
  String get yourListingPill;

  /// No description provided for @authorByline.
  ///
  /// In en, this message translates to:
  /// **'by {author}'**
  String authorByline(String author);

  /// No description provided for @aboutCopyTitle.
  ///
  /// In en, this message translates to:
  /// **'About this copy'**
  String get aboutCopyTitle;

  /// No description provided for @yourNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Your note'**
  String get yourNoteTitle;

  /// No description provided for @fromOwnerTitle.
  ///
  /// In en, this message translates to:
  /// **'From the owner'**
  String get fromOwnerTitle;

  /// No description provided for @listedByYouTitle.
  ///
  /// In en, this message translates to:
  /// **'Listed by you'**
  String get listedByYouTitle;

  /// No description provided for @ownerTitle.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get ownerTitle;

  /// No description provided for @howItWorksTitle.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get howItWorksTitle;

  /// No description provided for @factCondition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get factCondition;

  /// No description provided for @factDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get factDistance;

  /// No description provided for @distanceAway.
  ///
  /// In en, this message translates to:
  /// **'{distance} away'**
  String distanceAway(String distance);

  /// No description provided for @factArea.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get factArea;

  /// No description provided for @factListed.
  ///
  /// In en, this message translates to:
  /// **'Listed'**
  String get factListed;

  /// No description provided for @factIsbn.
  ///
  /// In en, this message translates to:
  /// **'ISBN'**
  String get factIsbn;

  /// No description provided for @factGenres.
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get factGenres;

  /// No description provided for @ownerUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Owner details are unavailable right now.'**
  String get ownerUnavailable;

  /// No description provided for @requestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requestsTitle;

  /// No description provided for @requestsRefreshing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing…'**
  String get requestsRefreshing;

  /// No description provided for @requestsWaiting.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 reader is waiting for your answer} other{{count} readers are waiting for your answer}}'**
  String requestsWaiting(int count);

  /// No description provided for @requestsLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load requests'**
  String get requestsLoadErrorTitle;

  /// No description provided for @requestsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No requests yet'**
  String get requestsEmptyTitle;

  /// No description provided for @requestsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Readers nearby can find this book in Discover.'**
  String get requestsEmptyMessage;

  /// No description provided for @requestsNoneOpen.
  ///
  /// In en, this message translates to:
  /// **'No open requests right now. Past requests are kept in My Library.'**
  String get requestsNoneOpen;

  /// No description provided for @requestedTime.
  ///
  /// In en, this message translates to:
  /// **'Requested {time}'**
  String requestedTime(String time);

  /// No description provided for @acceptedTime.
  ///
  /// In en, this message translates to:
  /// **'Accepted {time}'**
  String acceptedTime(String time);

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @confirmHandover.
  ///
  /// In en, this message translates to:
  /// **'Confirm handover'**
  String get confirmHandover;

  /// No description provided for @handoverConfirmedBanner.
  ///
  /// In en, this message translates to:
  /// **'You confirmed the handover. Waiting for the reader to confirm too.'**
  String get handoverConfirmedBanner;

  /// No description provided for @openChat.
  ///
  /// In en, this message translates to:
  /// **'Open chat'**
  String get openChat;

  /// No description provided for @offersInExchange.
  ///
  /// In en, this message translates to:
  /// **'Offers in exchange'**
  String get offersInExchange;

  /// No description provided for @offeredLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading the offered book…'**
  String get offeredLoading;

  /// No description provided for @offeredUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This book is no longer available'**
  String get offeredUnavailable;

  /// No description provided for @acceptDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Accept this request?'**
  String get acceptDialogTitle;

  /// No description provided for @acceptDialogMessageDonate.
  ///
  /// In en, this message translates to:
  /// **'A chat will open so the two of you can arrange the handover.'**
  String get acceptDialogMessageDonate;

  /// No description provided for @acceptDialogMessageExchange.
  ///
  /// In en, this message translates to:
  /// **'A chat will open so the two of you can arrange the swap.'**
  String get acceptDialogMessageExchange;

  /// No description provided for @acceptDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Accept request'**
  String get acceptDialogConfirm;

  /// No description provided for @acceptProgress.
  ///
  /// In en, this message translates to:
  /// **'Accepting request…'**
  String get acceptProgress;

  /// No description provided for @acceptSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request accepted. A chat has been opened for coordination.'**
  String get acceptSuccess;

  /// No description provided for @declineDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Decline this request?'**
  String get declineDialogTitle;

  /// No description provided for @declineDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'The reader will be notified and your book stays available for others.'**
  String get declineDialogMessage;

  /// No description provided for @declineDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Decline request'**
  String get declineDialogConfirm;

  /// No description provided for @declineProgress.
  ///
  /// In en, this message translates to:
  /// **'Declining request…'**
  String get declineProgress;

  /// No description provided for @declineSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request declined.'**
  String get declineSuccess;

  /// No description provided for @handoverDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm the handover?'**
  String get handoverDialogTitle;

  /// No description provided for @handoverDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Only confirm once the book has changed hands. It is marked complete when both of you confirm.'**
  String get handoverDialogMessage;

  /// No description provided for @handoverDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Yes, confirm'**
  String get handoverDialogConfirm;

  /// No description provided for @requestUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update request: {error}'**
  String requestUpdateFailed(String error);

  /// No description provided for @signInToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to confirm the exchange.'**
  String get signInToConfirm;

  /// No description provided for @exchangeConfirmRecorded.
  ///
  /// In en, this message translates to:
  /// **'Exchange confirmation recorded.'**
  String get exchangeConfirmRecorded;

  /// No description provided for @exchangeConfirmFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to confirm exchange: {error}'**
  String exchangeConfirmFailed(String error);

  /// No description provided for @exchangeConfirmProgress.
  ///
  /// In en, this message translates to:
  /// **'Confirming exchange…'**
  String get exchangeConfirmProgress;

  /// No description provided for @seekerBarAccepted.
  ///
  /// In en, this message translates to:
  /// **'The owner accepted your request. Arrange the handover in chat.'**
  String get seekerBarAccepted;

  /// No description provided for @seekerBarRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent {time}. Waiting for the owner to answer.'**
  String seekerBarRequestSent(String time);

  /// No description provided for @messageOwner.
  ///
  /// In en, this message translates to:
  /// **'Message owner'**
  String get messageOwner;

  /// No description provided for @seekerBarCompleted.
  ///
  /// In en, this message translates to:
  /// **'This book has already found a new reader.'**
  String get seekerBarCompleted;

  /// No description provided for @seekerBarBusy.
  ///
  /// In en, this message translates to:
  /// **'Another reader is arranging this book right now, so it can\'t be requested.'**
  String get seekerBarBusy;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get notAvailable;

  /// No description provided for @requestThisBook.
  ///
  /// In en, this message translates to:
  /// **'Request this book'**
  String get requestThisBook;

  /// No description provided for @offerSwap.
  ///
  /// In en, this message translates to:
  /// **'Offer a swap'**
  String get offerSwap;

  /// No description provided for @ownerBarWaitingReader.
  ///
  /// In en, this message translates to:
  /// **'You confirmed the handover. Waiting for the reader to confirm.'**
  String get ownerBarWaitingReader;

  /// No description provided for @ownerBarAccepted.
  ///
  /// In en, this message translates to:
  /// **'Request accepted. Confirm once the book has changed hands.'**
  String get ownerBarAccepted;

  /// No description provided for @ownerBarReviewRequests.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Review 1 request} other{Review {count} requests}}'**
  String ownerBarReviewRequests(int count);

  /// No description provided for @ownerBarLive.
  ///
  /// In en, this message translates to:
  /// **'Your listing is live. We\'ll show requests here.'**
  String get ownerBarLive;

  /// No description provided for @editListing.
  ///
  /// In en, this message translates to:
  /// **'Edit listing'**
  String get editListing;

  /// No description provided for @ownerBarCompleted.
  ///
  /// In en, this message translates to:
  /// **'This book has found a new reader. Thank you for sharing it.'**
  String get ownerBarCompleted;

  /// No description provided for @ownerBarInProgress.
  ///
  /// In en, this message translates to:
  /// **'This book is {status}. Manage progress in the requests above.'**
  String ownerBarInProgress(String status);

  /// No description provided for @shareText.
  ///
  /// In en, this message translates to:
  /// **'📚 {title} by {author}\nMode: {mode}\nCondition: {condition}\n\nFind it on Boichokro!'**
  String shareText(String title, String author, String mode, String condition);

  /// No description provided for @manageListingTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage listing'**
  String get manageListingTitle;

  /// No description provided for @actionBlockedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Not possible while an exchange is in progress'**
  String get actionBlockedSubtitle;

  /// No description provided for @deleteListing.
  ///
  /// In en, this message translates to:
  /// **'Delete listing'**
  String get deleteListing;

  /// No description provided for @saveToWishlist.
  ///
  /// In en, this message translates to:
  /// **'Save to wishlist'**
  String get saveToWishlist;

  /// No description provided for @reportBook.
  ///
  /// In en, this message translates to:
  /// **'Report this book'**
  String get reportBook;

  /// No description provided for @reportBookSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us if something looks wrong'**
  String get reportBookSubtitle;

  /// No description provided for @blockOwner.
  ///
  /// In en, this message translates to:
  /// **'Block owner'**
  String get blockOwner;

  /// No description provided for @blockOwnerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hide this person\'s books'**
  String get blockOwnerSubtitle;

  /// No description provided for @deleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this listing?'**
  String get deleteDialogTitle;

  /// No description provided for @deleteDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" will be removed from Boichokro. This can\'t be undone.'**
  String deleteDialogMessage(String title);

  /// No description provided for @signInToReport.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to report a book.'**
  String get signInToReport;

  /// No description provided for @reportDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Report this book?'**
  String get reportDialogTitle;

  /// No description provided for @reportDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Our team will review this listing. The owner won\'t know who reported it.'**
  String get reportDialogMessage;

  /// No description provided for @reportDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Send report'**
  String get reportDialogConfirm;

  /// No description provided for @reportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Book reported. Thank you!'**
  String get reportSuccess;

  /// No description provided for @reportFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to report: {error}'**
  String reportFailed(String error);

  /// No description provided for @signInToBlock.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to block someone.'**
  String get signInToBlock;

  /// No description provided for @blockDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Block this owner?'**
  String get blockDialogTitle;

  /// No description provided for @blockDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'You will stop seeing their books and you\'ll leave this page.'**
  String get blockDialogMessage;

  /// No description provided for @blockSuccess.
  ///
  /// In en, this message translates to:
  /// **'User blocked.'**
  String get blockSuccess;

  /// No description provided for @blockFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to block: {error}'**
  String blockFailed(String error);

  /// No description provided for @signInToSave.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to save books.'**
  String get signInToSave;

  /// No description provided for @wishlistSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved to your wishlist.'**
  String get wishlistSaved;

  /// No description provided for @wishlistFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save: {error}'**
  String wishlistFailed(String error);

  /// No description provided for @signInToRequest.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to request books'**
  String get signInToRequest;

  /// No description provided for @cannotRequestOwn.
  ///
  /// In en, this message translates to:
  /// **'You cannot request your own book'**
  String get cannotRequestOwn;

  /// No description provided for @alreadyRequested.
  ///
  /// In en, this message translates to:
  /// **'You have already requested this book.'**
  String get alreadyRequested;

  /// No description provided for @requestSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Request this book'**
  String get requestSheetTitle;

  /// No description provided for @requestSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The owner will be asked to approve your request.'**
  String get requestSheetSubtitle;

  /// No description provided for @sendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get sendRequest;

  /// No description provided for @giftBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'This book is a gift'**
  String get giftBannerTitle;

  /// No description provided for @giftBannerMessage.
  ///
  /// In en, this message translates to:
  /// **'You don\'t need to give anything in return. If the owner accepts, a chat opens to arrange the handover.'**
  String get giftBannerMessage;

  /// No description provided for @swapRequestProgress.
  ///
  /// In en, this message translates to:
  /// **'Sending swap request…'**
  String get swapRequestProgress;

  /// No description provided for @swapRequestSuccess.
  ///
  /// In en, this message translates to:
  /// **'Swap request sent. You offered \"{offered}\" for \"{requested}\".'**
  String swapRequestSuccess(String offered, String requested);

  /// No description provided for @requestProgress.
  ///
  /// In en, this message translates to:
  /// **'Sending request…'**
  String get requestProgress;

  /// No description provided for @requestSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request sent for \"{title}\".'**
  String requestSuccess(String title);

  /// No description provided for @requestFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send request: {error}'**
  String requestFailed(String error);

  /// No description provided for @signInToMessage.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to message the owner'**
  String get signInToMessage;

  /// No description provided for @ownBook.
  ///
  /// In en, this message translates to:
  /// **'This is your own book'**
  String get ownBook;

  /// No description provided for @chatCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create chat: {error}'**
  String chatCreateFailed(String error);

  /// No description provided for @chatOpening.
  ///
  /// In en, this message translates to:
  /// **'Opening chat…'**
  String get chatOpening;

  /// No description provided for @howDonateAskTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask for the book'**
  String get howDonateAskTitle;

  /// No description provided for @howDonateAskBody.
  ///
  /// In en, this message translates to:
  /// **'Send a request. This book is free, nothing to give in return.'**
  String get howDonateAskBody;

  /// No description provided for @howOwnerAcceptsTitle.
  ///
  /// In en, this message translates to:
  /// **'The owner accepts'**
  String get howOwnerAcceptsTitle;

  /// No description provided for @howOwnerAcceptsBody.
  ///
  /// In en, this message translates to:
  /// **'A chat opens so you can agree on a time and a safe public place.'**
  String get howOwnerAcceptsBody;

  /// No description provided for @howDonateCollectTitle.
  ///
  /// In en, this message translates to:
  /// **'Collect and confirm'**
  String get howDonateCollectTitle;

  /// No description provided for @howDonateCollectBody.
  ///
  /// In en, this message translates to:
  /// **'Pick up the book, then both of you confirm the handover.'**
  String get howDonateCollectBody;

  /// No description provided for @howSwapOfferTitle.
  ///
  /// In en, this message translates to:
  /// **'Offer one of your books'**
  String get howSwapOfferTitle;

  /// No description provided for @howSwapOfferBody.
  ///
  /// In en, this message translates to:
  /// **'Choose a book from your library to give in return.'**
  String get howSwapOfferBody;

  /// No description provided for @howSwapTradeTitle.
  ///
  /// In en, this message translates to:
  /// **'Swap and confirm'**
  String get howSwapTradeTitle;

  /// No description provided for @howSwapTradeBody.
  ///
  /// In en, this message translates to:
  /// **'Trade books in person, then both of you confirm the exchange.'**
  String get howSwapTradeBody;

  /// No description provided for @offerEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No books to offer yet'**
  String get offerEmptyTitle;

  /// No description provided for @offerEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add a book to your library first, then come back to offer it for this one.'**
  String get offerEmptyMessage;

  /// No description provided for @offerAddBook.
  ///
  /// In en, this message translates to:
  /// **'Add a book'**
  String get offerAddBook;

  /// No description provided for @offerAskingFor.
  ///
  /// In en, this message translates to:
  /// **'You are asking for'**
  String get offerAskingFor;

  /// No description provided for @offerYourBooks.
  ///
  /// In en, this message translates to:
  /// **'Your available books'**
  String get offerYourBooks;

  /// No description provided for @offerPickPrompt.
  ///
  /// In en, this message translates to:
  /// **'Pick a book to offer'**
  String get offerPickPrompt;

  /// No description provided for @offerSendSwap.
  ///
  /// In en, this message translates to:
  /// **'Send swap request'**
  String get offerSendSwap;

  /// No description provided for @offerLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your books'**
  String get offerLoadErrorTitle;

  /// No description provided for @offerLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading your books…'**
  String get offerLoading;

  /// No description provided for @offerSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Offer a book in return'**
  String get offerSheetTitle;

  /// No description provided for @offerSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The owner sees your offer and decides whether to swap.'**
  String get offerSheetSubtitle;
}

class _BookL10nDelegate extends LocalizationsDelegate<BookL10n> {
  const _BookL10nDelegate();

  @override
  Future<BookL10n> load(Locale locale) {
    return SynchronousFuture<BookL10n>(lookupBookL10n(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_BookL10nDelegate old) => false;
}

BookL10n lookupBookL10n(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn': return BookL10nBn();
    case 'en': return BookL10nEn();
  }

  throw FlutterError(
    'BookL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
