// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'chat_l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class ChatL10nEn extends ChatL10n {
  ChatL10nEn([String locale = 'en']) : super(locale);

  @override
  String get chatsTitle => 'Chats';

  @override
  String get chatsSubtitle => 'Arrange hand-overs with other readers';

  @override
  String unreadSummary(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString conversations have new messages',
      one: '1 conversation has new messages',
    );
    return '$_temp0';
  }

  @override
  String get signInTitle => 'Sign in to view chats';

  @override
  String get signInMessage => 'Your conversations with other readers will appear here once you are signed in.';

  @override
  String get emptyTitle => 'No conversations yet';

  @override
  String get emptyMessage => 'A chat opens when you request a book, or when someone requests one of yours. Find a book you like to get started.';

  @override
  String get emptyAction => 'Discover books';

  @override
  String get previewEmpty => 'Say hello to get things started';

  @override
  String get previewLocation => 'Shared a location';

  @override
  String get readerFallbackName => 'Reader';

  @override
  String namePair(String first, String second) {
    return '$first & $second';
  }

  @override
  String get dayToday => 'Today';

  @override
  String get dayYesterday => 'Yesterday';

  @override
  String get dayFormat => 'MMMM d';

  @override
  String get dayFormatWithYear => 'MMMM d, y';

  @override
  String unreadBadgeLabel(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString unread';
  }

  @override
  String get chatFallbackTitle => 'Chat';

  @override
  String get moreOptions => 'More options';

  @override
  String get menuViewBook => 'View book details';

  @override
  String get menuReportUser => 'Report user';

  @override
  String get menuBlockUser => 'Block user';

  @override
  String get openChatFailed => 'Could not open this chat';

  @override
  String get openingConversation => 'Opening conversation';

  @override
  String get loadMessagesFailed => 'Could not load messages';

  @override
  String get bookFallbackTitle => 'Book in this chat';

  @override
  String bookYours(String name) {
    return 'Your book · $name asked about it';
  }

  @override
  String bookSharedBy(String name) {
    return 'Shared by $name';
  }

  @override
  String bookRequestedBy(String name) {
    return 'requested by $name';
  }

  @override
  String get emptyConversationTitle => 'Start the conversation';

  @override
  String emptyConversationMessage(String name) {
    return 'Say hello to $name and agree on how to hand the book over. Tap a suggestion to use it.';
  }

  @override
  String get starterAvailable => 'Hi! Is the book still available?';

  @override
  String starterAvailableBook(String book) {
    return 'Hi! Is \"$book\" still available?';
  }

  @override
  String get starterMeet => 'When and where would be good to meet?';

  @override
  String get starterThanks => 'Thank you for sharing this book!';

  @override
  String get safetyTipTitle => 'Meet safely';

  @override
  String get safetyTipMessage => 'Hand books over in a busy public place during the day, and never send money or personal details in chat.';

  @override
  String get safetyTipAction => 'Got it';

  @override
  String get composerHint => 'Write a message';

  @override
  String get sendTooltip => 'Send';

  @override
  String get shareLocationTitle => 'Share your location';

  @override
  String get shareLocationSubtitle => 'Sends a map pin of where you are right now.';

  @override
  String get shareLocationConfirm => 'Share pin';

  @override
  String get shareCareTitle => 'Share with care';

  @override
  String get shareCareMessage => 'Only share your location when you are ready to meet, and pick a busy public place rather than your home.';

  @override
  String get locationServicesOff => 'Turn on location services to share a pin.';

  @override
  String get locationPermissionNeeded => 'Location permission is needed to share a pin.';

  @override
  String get locationFailed => 'Could not get your location. Please try again.';

  @override
  String get mapsOpenFailed => 'Could not open a maps app.';

  @override
  String get locationSharedByYou => 'You shared a location';

  @override
  String get locationShared => 'Shared location';

  @override
  String get locationOpenHint => 'Tap to open in maps';

  @override
  String get reportTitle => 'Report user';

  @override
  String reportSubtitle(String name) {
    return 'Tell us what is wrong with $name.';
  }

  @override
  String get reportSubmit => 'Submit report';

  @override
  String get reasonSpam => 'Spam';

  @override
  String get reasonHarassment => 'Harassment';

  @override
  String get reasonInappropriate => 'Inappropriate content';

  @override
  String get reasonOther => 'Other';

  @override
  String blockTitle(String name) {
    return 'Block $name?';
  }

  @override
  String get blockMessage => 'You will no longer receive messages from them, and they will not be able to interact with your books.';

  @override
  String get blockAction => 'Block';
}
