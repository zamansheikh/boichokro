// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'chat_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class ChatL10nBn extends ChatL10n {
  ChatL10nBn([String locale = 'bn']) : super(locale);

  @override
  String get chatsTitle => 'চ্যাট';

  @override
  String get chatsSubtitle => 'অন্য পাঠকদের সঙ্গে বই হাতবদলের কথা সেরে নিন';

  @override
  String unreadSummary(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countStringটি কথোপকথনে নতুন মেসেজ এসেছে';
  }

  @override
  String get signInTitle => 'চ্যাট দেখতে সাইন ইন করুন';

  @override
  String get signInMessage => 'সাইন ইন করলে অন্য পাঠকদের সঙ্গে আপনার কথোপকথনগুলো এখানে দেখা যাবে।';

  @override
  String get emptyTitle => 'এখনো কোনো কথোপকথন নেই';

  @override
  String get emptyMessage => 'আপনি কোনো বইয়ের অনুরোধ করলে, অথবা কেউ আপনার বই চাইলে চ্যাট শুরু হয়। পছন্দের একটি বই খুঁজে নিয়ে শুরু করুন।';

  @override
  String get emptyAction => 'বই খুঁজে দেখুন';

  @override
  String get previewEmpty => 'হ্যালো বলে আলাপ শুরু করুন';

  @override
  String get previewLocation => 'লোকেশন শেয়ার করা হয়েছে';

  @override
  String get readerFallbackName => 'পাঠক';

  @override
  String namePair(String first, String second) {
    return '$first ও $second';
  }

  @override
  String get dayToday => 'আজ';

  @override
  String get dayYesterday => 'গতকাল';

  @override
  String get dayFormat => 'd MMMM';

  @override
  String get dayFormatWithYear => 'd MMMM, y';

  @override
  String unreadBadgeLabel(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countStringটি না-পড়া মেসেজ';
  }

  @override
  String get chatFallbackTitle => 'চ্যাট';

  @override
  String get moreOptions => 'আরও অপশন';

  @override
  String get menuViewBook => 'বইয়ের বিস্তারিত দেখুন';

  @override
  String get menuReportUser => 'রিপোর্ট করুন';

  @override
  String get menuBlockUser => 'ব্লক করুন';

  @override
  String get openChatFailed => 'চ্যাটটি খোলা যায়নি';

  @override
  String get openingConversation => 'কথোপকথন খোলা হচ্ছে';

  @override
  String get loadMessagesFailed => 'মেসেজ লোড করা যায়নি';

  @override
  String get bookFallbackTitle => 'এই চ্যাটের বই';

  @override
  String bookYours(String name) {
    return 'আপনার বই · $name এটি সম্পর্কে জানতে চেয়েছেন';
  }

  @override
  String bookSharedBy(String name) {
    return 'শেয়ার করেছেন $name';
  }

  @override
  String bookRequestedBy(String name) {
    return 'অনুরোধ করেছেন $name';
  }

  @override
  String get emptyConversationTitle => 'আলাপ শুরু করুন';

  @override
  String emptyConversationMessage(String name) {
    return '$name-কে হ্যালো বলুন এবং বইটি কীভাবে হাতবদল হবে তা ঠিক করে নিন। নিচের যেকোনো মেসেজে ট্যাপ করলেই সেটি লেখা হয়ে যাবে।';
  }

  @override
  String get starterAvailable => 'হ্যালো! বইটি কি এখনো আছে?';

  @override
  String starterAvailableBook(String book) {
    return 'হ্যালো! \"$book\" বইটি কি এখনো আছে?';
  }

  @override
  String get starterMeet => 'কখন, কোথায় দেখা করলে আপনার সুবিধা হয়?';

  @override
  String get starterThanks => 'বইটি শেয়ার করার জন্য অনেক ধন্যবাদ!';

  @override
  String get safetyTipTitle => 'নিরাপদে দেখা করুন';

  @override
  String get safetyTipMessage => 'দিনের বেলায়, লোকজন আছে এমন জায়গায় বই হাতবদল করুন। চ্যাটে কখনো টাকা বা ব্যক্তিগত তথ্য পাঠাবেন না।';

  @override
  String get safetyTipAction => 'বুঝেছি';

  @override
  String get composerHint => 'মেসেজ লিখুন';

  @override
  String get sendTooltip => 'পাঠান';

  @override
  String get shareLocationTitle => 'আপনার লোকেশন শেয়ার করুন';

  @override
  String get shareLocationSubtitle => 'আপনি এখন যেখানে আছেন, ম্যাপে সেই জায়গার পিন পাঠানো হবে।';

  @override
  String get shareLocationConfirm => 'পিন শেয়ার করুন';

  @override
  String get shareCareTitle => 'ভেবেচিন্তে শেয়ার করুন';

  @override
  String get shareCareMessage => 'দেখা করার জন্য প্রস্তুত হলে তবেই লোকেশন শেয়ার করুন। নিজের বাসার বদলে লোকজন আছে এমন কোনো জায়গা বেছে নিন।';

  @override
  String get locationServicesOff => 'পিন শেয়ার করতে লোকেশন সার্ভিস চালু করুন।';

  @override
  String get locationPermissionNeeded => 'পিন শেয়ার করতে লোকেশনের অনুমতি প্রয়োজন।';

  @override
  String get locationFailed => 'আপনার লোকেশন পাওয়া যায়নি। আবার চেষ্টা করুন।';

  @override
  String get mapsOpenFailed => 'কোনো ম্যাপ অ্যাপ খোলা যায়নি।';

  @override
  String get locationSharedByYou => 'আপনি লোকেশন শেয়ার করেছেন';

  @override
  String get locationShared => 'শেয়ার করা লোকেশন';

  @override
  String get locationOpenHint => 'ম্যাপে দেখতে ট্যাপ করুন';

  @override
  String get reportTitle => 'রিপোর্ট করুন';

  @override
  String reportSubtitle(String name) {
    return '$name-এর ব্যাপারে সমস্যাটি কী, আমাদের জানান।';
  }

  @override
  String get reportSubmit => 'রিপোর্ট জমা দিন';

  @override
  String get reasonSpam => 'স্প্যাম';

  @override
  String get reasonHarassment => 'হয়রানি';

  @override
  String get reasonInappropriate => 'আপত্তিকর কনটেন্ট';

  @override
  String get reasonOther => 'অন্যান্য';

  @override
  String blockTitle(String name) {
    return '$name-কে ব্লক করবেন?';
  }

  @override
  String get blockMessage => 'তাঁর কাছ থেকে আর কোনো মেসেজ পাবেন না, আর তিনিও আপনার বইগুলোতে কোনো অনুরোধ বা যোগাযোগ করতে পারবেন না।';

  @override
  String get blockAction => 'ব্লক করুন';
}
