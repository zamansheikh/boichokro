// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'book_l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class BookL10nEn extends BookL10n {
  BookL10nEn([String locale = 'en']) : super(locale);

  @override
  String get listingRemovedSnack => 'Your listing was removed.';

  @override
  String get shareTooltip => 'Share this book';

  @override
  String get moreOptions => 'More options';

  @override
  String get openErrorTitle => 'We couldn\'t open this book';

  @override
  String get removedTitle => 'This listing was removed';

  @override
  String get removedMessage => 'The book is no longer on Boichokro.';

  @override
  String get goBack => 'Go back';

  @override
  String get notFoundTitle => 'Book not found';

  @override
  String get notFoundMessage => 'It may have been removed by its owner.';

  @override
  String get yourListingPill => 'Your listing';

  @override
  String authorByline(String author) {
    return 'by $author';
  }

  @override
  String get aboutCopyTitle => 'About this copy';

  @override
  String get yourNoteTitle => 'Your note';

  @override
  String get fromOwnerTitle => 'From the owner';

  @override
  String get listedByYouTitle => 'Listed by you';

  @override
  String get ownerTitle => 'Owner';

  @override
  String get howItWorksTitle => 'How it works';

  @override
  String get factCondition => 'Condition';

  @override
  String get factDistance => 'Distance';

  @override
  String distanceAway(String distance) {
    return '$distance away';
  }

  @override
  String get factArea => 'Area';

  @override
  String get factListed => 'Listed';

  @override
  String get factIsbn => 'ISBN';

  @override
  String get factGenres => 'Genres';

  @override
  String get ownerUnavailable => 'Owner details are unavailable right now.';

  @override
  String get requestsTitle => 'Requests';

  @override
  String get requestsRefreshing => 'Refreshing…';

  @override
  String requestsWaiting(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString readers are waiting for your answer',
      one: '1 reader is waiting for your answer',
    );
    return '$_temp0';
  }

  @override
  String get requestsLoadErrorTitle => 'Couldn\'t load requests';

  @override
  String get requestsEmptyTitle => 'No requests yet';

  @override
  String get requestsEmptyMessage => 'Readers nearby can find this book in Discover.';

  @override
  String get requestsNoneOpen => 'No open requests right now. Past requests are kept in My Library.';

  @override
  String requestedTime(String time) {
    return 'Requested $time';
  }

  @override
  String acceptedTime(String time) {
    return 'Accepted $time';
  }

  @override
  String get decline => 'Decline';

  @override
  String get accept => 'Accept';

  @override
  String get confirmHandover => 'Confirm handover';

  @override
  String get handoverConfirmedBanner => 'You confirmed the handover. Waiting for the reader to confirm too.';

  @override
  String get openChat => 'Open chat';

  @override
  String get offersInExchange => 'Offers in exchange';

  @override
  String get offeredLoading => 'Loading the offered book…';

  @override
  String get offeredUnavailable => 'This book is no longer available';

  @override
  String get acceptDialogTitle => 'Accept this request?';

  @override
  String get acceptDialogMessageDonate => 'A chat will open so the two of you can arrange the handover.';

  @override
  String get acceptDialogMessageExchange => 'A chat will open so the two of you can arrange the swap.';

  @override
  String get acceptDialogConfirm => 'Accept request';

  @override
  String get acceptProgress => 'Accepting request…';

  @override
  String get acceptSuccess => 'Request accepted. A chat has been opened for coordination.';

  @override
  String get declineDialogTitle => 'Decline this request?';

  @override
  String get declineDialogMessage => 'The reader will be notified and your book stays available for others.';

  @override
  String get declineDialogConfirm => 'Decline request';

  @override
  String get declineProgress => 'Declining request…';

  @override
  String get declineSuccess => 'Request declined.';

  @override
  String get handoverDialogTitle => 'Confirm the handover?';

  @override
  String get handoverDialogMessage => 'Only confirm once the book has changed hands. It is marked complete when both of you confirm.';

  @override
  String get handoverDialogConfirm => 'Yes, confirm';

  @override
  String requestUpdateFailed(String error) {
    return 'Failed to update request: $error';
  }

  @override
  String get signInToConfirm => 'Please sign in to confirm the exchange.';

  @override
  String get exchangeConfirmRecorded => 'Exchange confirmation recorded.';

  @override
  String exchangeConfirmFailed(String error) {
    return 'Failed to confirm exchange: $error';
  }

  @override
  String get exchangeConfirmProgress => 'Confirming exchange…';

  @override
  String get seekerBarAccepted => 'The owner accepted your request. Arrange the handover in chat.';

  @override
  String seekerBarRequestSent(String time) {
    return 'Request sent $time. Waiting for the owner to answer.';
  }

  @override
  String get messageOwner => 'Message owner';

  @override
  String get seekerBarCompleted => 'This book has already found a new reader.';

  @override
  String get seekerBarBusy => 'Another reader is arranging this book right now, so it can\'t be requested.';

  @override
  String get notAvailable => 'Not available';

  @override
  String get requestThisBook => 'Request this book';

  @override
  String get offerSwap => 'Offer a swap';

  @override
  String get ownerBarWaitingReader => 'You confirmed the handover. Waiting for the reader to confirm.';

  @override
  String get ownerBarAccepted => 'Request accepted. Confirm once the book has changed hands.';

  @override
  String ownerBarReviewRequests(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Review $countString requests',
      one: 'Review 1 request',
    );
    return '$_temp0';
  }

  @override
  String get ownerBarLive => 'Your listing is live. We\'ll show requests here.';

  @override
  String get editListing => 'Edit listing';

  @override
  String get ownerBarCompleted => 'This book has found a new reader. Thank you for sharing it.';

  @override
  String ownerBarInProgress(String status) {
    return 'This book is $status. Manage progress in the requests above.';
  }

  @override
  String shareText(String title, String author, String mode, String condition) {
    return '📚 $title by $author\nMode: $mode\nCondition: $condition\n\nFind it on Boichokro!';
  }

  @override
  String get manageListingTitle => 'Manage listing';

  @override
  String get actionBlockedSubtitle => 'Not possible while an exchange is in progress';

  @override
  String get deleteListing => 'Delete listing';

  @override
  String get saveToWishlist => 'Save to wishlist';

  @override
  String get reportBook => 'Report this book';

  @override
  String get reportBookSubtitle => 'Tell us if something looks wrong';

  @override
  String get blockOwner => 'Block owner';

  @override
  String get blockOwnerSubtitle => 'Hide this person\'s books';

  @override
  String get deleteDialogTitle => 'Delete this listing?';

  @override
  String deleteDialogMessage(String title) {
    return '\"$title\" will be removed from Boichokro. This can\'t be undone.';
  }

  @override
  String get signInToReport => 'Please sign in to report a book.';

  @override
  String get reportDialogTitle => 'Report this book?';

  @override
  String get reportDialogMessage => 'Our team will review this listing. The owner won\'t know who reported it.';

  @override
  String get reportDialogConfirm => 'Send report';

  @override
  String get reportSuccess => 'Book reported. Thank you!';

  @override
  String reportFailed(String error) {
    return 'Failed to report: $error';
  }

  @override
  String get signInToBlock => 'Please sign in to block someone.';

  @override
  String get blockDialogTitle => 'Block this owner?';

  @override
  String get blockDialogMessage => 'You will stop seeing their books and you\'ll leave this page.';

  @override
  String get blockSuccess => 'User blocked.';

  @override
  String blockFailed(String error) {
    return 'Failed to block: $error';
  }

  @override
  String get signInToSave => 'Please sign in to save books.';

  @override
  String get wishlistSaved => 'Saved to your wishlist.';

  @override
  String wishlistFailed(String error) {
    return 'Failed to save: $error';
  }

  @override
  String get signInToRequest => 'Please sign in to request books';

  @override
  String get cannotRequestOwn => 'You cannot request your own book';

  @override
  String get alreadyRequested => 'You have already requested this book.';

  @override
  String get requestSheetTitle => 'Request this book';

  @override
  String get requestSheetSubtitle => 'The owner will be asked to approve your request.';

  @override
  String get sendRequest => 'Send request';

  @override
  String get giftBannerTitle => 'This book is a gift';

  @override
  String get giftBannerMessage => 'You don\'t need to give anything in return. If the owner accepts, a chat opens to arrange the handover.';

  @override
  String get swapRequestProgress => 'Sending swap request…';

  @override
  String swapRequestSuccess(String offered, String requested) {
    return 'Swap request sent. You offered \"$offered\" for \"$requested\".';
  }

  @override
  String get requestProgress => 'Sending request…';

  @override
  String requestSuccess(String title) {
    return 'Request sent for \"$title\".';
  }

  @override
  String requestFailed(String error) {
    return 'Failed to send request: $error';
  }

  @override
  String get signInToMessage => 'Please sign in to message the owner';

  @override
  String get ownBook => 'This is your own book';

  @override
  String chatCreateFailed(String error) {
    return 'Failed to create chat: $error';
  }

  @override
  String get chatOpening => 'Opening chat…';

  @override
  String get howDonateAskTitle => 'Ask for the book';

  @override
  String get howDonateAskBody => 'Send a request. This book is free, nothing to give in return.';

  @override
  String get howOwnerAcceptsTitle => 'The owner accepts';

  @override
  String get howOwnerAcceptsBody => 'A chat opens so you can agree on a time and a safe public place.';

  @override
  String get howDonateCollectTitle => 'Collect and confirm';

  @override
  String get howDonateCollectBody => 'Pick up the book, then both of you confirm the handover.';

  @override
  String get howSwapOfferTitle => 'Offer one of your books';

  @override
  String get howSwapOfferBody => 'Choose a book from your library to give in return.';

  @override
  String get howSwapTradeTitle => 'Swap and confirm';

  @override
  String get howSwapTradeBody => 'Trade books in person, then both of you confirm the exchange.';

  @override
  String get offerEmptyTitle => 'No books to offer yet';

  @override
  String get offerEmptyMessage => 'Add a book to your library first, then come back to offer it for this one.';

  @override
  String get offerAddBook => 'Add a book';

  @override
  String get offerAskingFor => 'You are asking for';

  @override
  String get offerYourBooks => 'Your available books';

  @override
  String get offerPickPrompt => 'Pick a book to offer';

  @override
  String get offerSendSwap => 'Send swap request';

  @override
  String get offerLoadErrorTitle => 'Couldn\'t load your books';

  @override
  String get offerLoading => 'Loading your books…';

  @override
  String get offerSheetTitle => 'Offer a book in return';

  @override
  String get offerSheetSubtitle => 'The owner sees your offer and decides whether to swap.';
}
