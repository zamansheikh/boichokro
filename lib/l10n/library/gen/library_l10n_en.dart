// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'library_l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class LibraryL10nEn extends LibraryL10n {
  LibraryL10nEn([String locale = 'en']) : super(locale);

  @override
  String get libraryTitle => 'My library';

  @override
  String get summarySignedOut => 'Sign in to share and request books';

  @override
  String get summaryLoading => 'Opening your shelf…';

  @override
  String summaryBooksShared(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString books shared',
      one: '1 book shared',
      zero: 'No books shared yet',
    );
    return '$_temp0';
  }

  @override
  String summaryRequestsWaiting(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString requests waiting',
      one: '1 request waiting',
    );
    return '$_temp0';
  }

  @override
  String summaryHandOffsInProgress(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString hand-offs in progress',
      one: '1 hand-off in progress',
    );
    return '$_temp0';
  }

  @override
  String get tabMyBooks => 'My books';

  @override
  String get tabMyRequests => 'My requests';

  @override
  String get tabRequestsToMe => 'Requests to me';

  @override
  String get tabHistory => 'History';

  @override
  String get signedOutTitle => 'Your library lives here';

  @override
  String get signedOutMessage =>
      'Sign in to share your books, ask for others and follow every hand-off.';

  @override
  String get signInAction => 'Sign in';

  @override
  String get booksLoadErrorTitle => 'Could not load your books';

  @override
  String get requestsLoadErrorTitle => 'Could not load your requests';

  @override
  String get emptyBooksTitle => 'Your shelf is empty';

  @override
  String get emptyBooksMessage =>
      'Share a book you have finished. A reader nearby may be looking for exactly that one.';

  @override
  String get addBookAction => 'Add a book';

  @override
  String get emptySentTitle => 'No requests on the way';

  @override
  String get emptySentMessage =>
      'When you ask for a book, you can follow its journey here, from request to hand-off.';

  @override
  String get discoverBooksAction => 'Discover books';

  @override
  String get emptyReceivedTitle => 'No one has asked yet';

  @override
  String get emptyReceivedMessage =>
      'When a reader asks for one of your books, their request shows up here for you to accept or decline.';

  @override
  String get emptyHistoryTitle => 'No history yet';

  @override
  String get emptyHistoryMessage =>
      'Completed, declined and cancelled requests are kept here, along with the reviews you exchange.';

  @override
  String get snackBookRemoved => 'Book removed from your library';

  @override
  String get bookOptionsTitle => 'Book options';

  @override
  String get bookLockedCompleted =>
      'This book has already found its reader, so it can no longer be edited or removed.';

  @override
  String get bookLockedInRequest =>
      'This book is part of a request right now. You can edit or remove it once that is settled.';

  @override
  String get bookActionView => 'View book';

  @override
  String get bookActionEdit => 'Edit details';

  @override
  String get bookActionRemove => 'Remove from library';

  @override
  String get deleteBookTitle => 'Remove this book?';

  @override
  String deleteBookMessage(String title) {
    return '\"$title\" will be taken off Boichokro and readers will no longer be able to ask for it. This cannot be undone.';
  }

  @override
  String get deleteBookConfirm => 'Remove';

  @override
  String get keepItAction => 'Keep it';

  @override
  String get snackRequestAccepted =>
      'Request accepted. Use the chat to arrange the hand-off.';

  @override
  String get declineDialogTitle => 'Decline this request?';

  @override
  String declineDialogMessage(String name) {
    return '$name will see that you declined. Your book stays available for other readers.';
  }

  @override
  String get declineAction => 'Decline';

  @override
  String get notNowAction => 'Not now';

  @override
  String get snackRequestDeclined => 'Request declined';

  @override
  String get cancelDialogTitle => 'Cancel your request?';

  @override
  String get cancelDialogMessage =>
      'The owner will see that you no longer need this book. You can ask for it again later if it is still available.';

  @override
  String get cancelRequestAction => 'Cancel request';

  @override
  String get snackRequestCancelled => 'Request cancelled';

  @override
  String get confirmReceivedTitle => 'Did you receive the book?';

  @override
  String get confirmHandedOverTitle => 'Did you hand it over?';

  @override
  String get confirmReceivedMessage =>
      'Confirm only once the book is in your hands.';

  @override
  String get confirmHandedOverMessage =>
      'Confirm only once the reader has the book.';

  @override
  String get confirmDetailCompletes =>
      'This completes the exchange, and you can then review each other.';

  @override
  String get confirmDetailWaitsOther =>
      'The exchange completes when the other person confirms too.';

  @override
  String get confirmReceivedYes => 'Yes, I have it';

  @override
  String get confirmHandedOverYes => 'Yes, handed over';

  @override
  String get notYetAction => 'Not yet';

  @override
  String get snackExchangeComplete =>
      'Exchange complete. You can now leave a review.';

  @override
  String get snackConfirmedWaiting =>
      'Confirmed. Waiting for the other person to confirm too.';

  @override
  String get snackReviewSubmitted => 'Review submitted. Thank you!';

  @override
  String get missingBookTitle => 'A book that is no longer listed';

  @override
  String bookNextPeopleAsked(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString people asked for this',
      one: '1 person asked for this',
    );
    return '$_temp0';
  }

  @override
  String get bookNextSomeoneAsked => 'Someone asked for this';

  @override
  String get bookNextHandOff => 'Hand-off in progress';

  @override
  String get bookNextFoundReader => 'Found a new reader';

  @override
  String get fallbackOwner => 'The owner';

  @override
  String get fallbackOwnerInline => 'the owner';

  @override
  String get fallbackReader => 'The reader';

  @override
  String get fallbackReaderInline => 'the reader';

  @override
  String get captionYouAsked => 'You asked';

  @override
  String get captionAskedBy => 'Asked by';

  @override
  String askedTime(String time) {
    return 'Asked $time';
  }

  @override
  String get youOfferedInReturn => 'You offered in return';

  @override
  String get offeredInReturn => 'Offered in return';

  @override
  String get pillYouConfirmed => 'You: confirmed';

  @override
  String get pillYouNotYet => 'You: not yet';

  @override
  String get pillOwnerConfirmed => 'Owner: confirmed';

  @override
  String get pillOwnerNotYet => 'Owner: not yet';

  @override
  String get pillReaderConfirmed => 'Reader: confirmed';

  @override
  String get pillReaderNotYet => 'Reader: not yet';

  @override
  String requestBannerWaitingTitle(String name) {
    return 'Waiting for $name';
  }

  @override
  String get requestBannerWaitingMessage =>
      'They will accept or decline your request. You can cancel it any time before then.';

  @override
  String requestBannerSwapOfferTitle(String name) {
    return '$name is offering a swap';
  }

  @override
  String requestBannerWantsBookTitle(String name) {
    return '$name would like this book';
  }

  @override
  String get requestBannerIncomingMessage =>
      'Accepting opens a chat to arrange the hand-off and declines any other requests for this book.';

  @override
  String get requestBannerYouConfirmedTitle => 'You have confirmed';

  @override
  String requestBannerYouConfirmedMessage(String name) {
    return 'Waiting for $name to confirm the hand-off too.';
  }

  @override
  String get requestBannerYourTurnTitle => 'Your turn to confirm';

  @override
  String requestBannerYourTurnSeekerMessage(String name) {
    return '$name confirmed handing the book over. Confirm once it is in your hands to complete the exchange.';
  }

  @override
  String requestBannerYourTurnOwnerMessage(String name) {
    return '$name confirmed receiving the book. Confirm on your side to complete the exchange.';
  }

  @override
  String requestBannerSaidYesTitle(String name) {
    return '$name said yes';
  }

  @override
  String get requestBannerHandOverTitle => 'Time to hand it over';

  @override
  String get requestBannerArrangeSeekerMessage =>
      'Agree on a time and place in chat. Once the book is in your hands, confirm it here.';

  @override
  String get requestBannerArrangeOwnerMessage =>
      'Agree on a time and place in chat. Once you have handed the book over, confirm it here.';

  @override
  String get handOffEyebrow => 'Hand-off';

  @override
  String trackingId(String id) {
    return 'Tracking $id';
  }

  @override
  String get acceptAction => 'Accept';

  @override
  String get receivedBookAction => 'I received the book';

  @override
  String get handedOverAction => 'I handed it over';

  @override
  String get arrangeInChatAction => 'Arrange hand-off in chat';

  @override
  String get openChatAction => 'Open chat';

  @override
  String historyReceivedFrom(String name) {
    return 'You received this from $name';
  }

  @override
  String historyGaveTo(String name) {
    return 'You gave this to $name';
  }

  @override
  String historyTheyDeclined(String name) {
    return '$name declined your request';
  }

  @override
  String historyYouDeclined(String name) {
    return 'You declined the request from $name';
  }

  @override
  String historyYouCancelled(String name) {
    return 'You cancelled your request to $name';
  }

  @override
  String historyTheyCancelled(String name) {
    return '$name cancelled their request';
  }

  @override
  String historyYouAsked(String name) {
    return 'You asked $name';
  }

  @override
  String historyTheyAsked(String name) {
    return '$name asked for this book';
  }

  @override
  String get reviewYouRated => 'You rated';

  @override
  String get reviewTheyRated => 'They rated you';

  @override
  String reviewPrompt(String name) {
    return 'How was your exchange with $name? Your review helps other readers trust them.';
  }

  @override
  String get leaveReviewAction => 'Leave a review';

  @override
  String reviewNotLeftYet(String name) {
    return '$name has not left a review yet.';
  }

  @override
  String reviewQuote(String text) {
    return '\"$text\"';
  }

  @override
  String get reviewSheetSubtitle => 'How did the exchange go?';

  @override
  String reviewSheetSubtitleNamed(String name) {
    return 'How was your exchange with $name?';
  }

  @override
  String get submitReviewAction => 'Submit review';

  @override
  String get ratingLabelNotGood => 'Not good';

  @override
  String get ratingLabelCouldBeBetter => 'Could be better';

  @override
  String get ratingLabelOkay => 'Okay';

  @override
  String get ratingLabelGood => 'Good';

  @override
  String get ratingLabelExcellent => 'Excellent';

  @override
  String get reviewFieldLabel => 'Your review (optional)';

  @override
  String get reviewFieldHint =>
      'Was the book as described? Were they easy to meet?';

  @override
  String get reviewShareNote =>
      'Your rating is shared with them and counts towards their profile.';

  @override
  String get journeyEyebrow => 'Journey';

  @override
  String get journeyHideSteps => 'Hide journey steps';

  @override
  String get journeyShowSteps => 'Show journey steps';

  @override
  String get journeySummaryDeclined => 'Ended · request declined';

  @override
  String get journeySummaryCancelled => 'Ended · request cancelled';

  @override
  String get journeySummaryComplete => 'Complete · reviewed and done';

  @override
  String journeySummaryProgress(int done, int total, String next) {
    final intl.NumberFormat doneNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String doneString = doneNumberFormat.format(done);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$doneString of $totalString done · Next: $next';
  }

  @override
  String get journeyStepRequested => 'Requested';

  @override
  String get journeyStepDeclined => 'Declined';

  @override
  String get journeyStepCancelled => 'Cancelled';

  @override
  String get journeyStepAccepted => 'Accepted';

  @override
  String get journeyStepHandOffArranged => 'Hand-off arranged';

  @override
  String get journeyStepBothConfirmed => 'Both confirmed';

  @override
  String get journeyStepReviewed => 'Reviewed';

  @override
  String journeyRequestedSeeker(String time) {
    return 'You asked for this book · $time';
  }

  @override
  String journeyRequestedOwner(String time) {
    return 'A reader asked for your book · $time';
  }

  @override
  String get journeyDeclinedSeeker =>
      'The owner could not share this book this time';

  @override
  String get journeyDeclinedOwner => 'You declined this request';

  @override
  String get journeyCancelledSeeker => 'You cancelled this request';

  @override
  String get journeyCancelledOwner => 'The reader cancelled their request';

  @override
  String get journeyWaitingOwnerReply => 'Waiting for the owner to reply';

  @override
  String get journeyWaitingYourReply => 'Waiting for your reply';

  @override
  String get journeyArrangeHint => 'Agree on a time and place in chat';

  @override
  String get journeyChangedHands => 'The book changed hands';

  @override
  String get journeyBothConfirmedFinishing => 'Both confirmed · finishing up';

  @override
  String get journeyReviewPrompt => 'Leave a review to close the loop';

  @override
  String journeyYouRated(String rating) {
    return 'You rated $rating';
  }

  @override
  String journeyBothRated(String mine, String theirs) {
    return 'You rated $mine · they rated you $theirs';
  }

  @override
  String get journeyNow => 'Now';
}
