// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'browse_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class BrowseL10nBn extends BrowseL10n {
  BrowseL10nBn([String locale = 'bn']) : super(locale);

  @override
  String get navDiscover => 'খুঁজুন';

  @override
  String get navLibrary => 'লাইব্রেরি';

  @override
  String get navChats => 'চ্যাট';

  @override
  String get navProfile => 'প্রোফাইল';

  @override
  String get shareABook => 'বই শেয়ার করুন';

  @override
  String get notFoundTitle => 'পাতাটি খুঁজে পাওয়া যায়নি';

  @override
  String get notFoundMessage => 'লিংকটি হয়তো পুরোনো, অথবা বইটি অন্য কারও হাতে চলে গেছে।';

  @override
  String get notFoundAction => 'বই খোঁজায় ফিরে যান';

  @override
  String get discoverEyebrowNearby => 'আপনার কাছাকাছি বই';

  @override
  String get discoverEyebrowCircle => 'চক্রের সব বই';

  @override
  String get discoverTitle => 'পরের বইটি খুঁজে নিন';

  @override
  String get searchHint => 'বইয়ের নাম, লেখক বা ধরন';

  @override
  String get searchClear => 'সার্চ মুছুন';

  @override
  String get filtersTitle => 'ফিল্টার';

  @override
  String get filterAll => 'সব';

  @override
  String filterWithinKm(int km) {
    final intl.NumberFormat kmNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String kmString = kmNumberFormat.format(km);

    return '$kmString কিমির মধ্যে';
  }

  @override
  String get filterAvailableNow => 'এখন পাওয়া যাচ্ছে';

  @override
  String conditionOrBetter(String condition) {
    return 'অন্তত $condition';
  }

  @override
  String get loadErrorTitle => 'বই লোড করা যায়নি';

  @override
  String resultCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countStringটি বই';
  }

  @override
  String get resultSortNearest => 'কাছেরগুলো আগে';

  @override
  String get resultSortAround => 'আশপাশের পাঠকদের বই';

  @override
  String get clearFilters => 'ফিল্টার মুছুন';

  @override
  String get emptyTitle => 'এখানে এখনো কোনো বই নেই';

  @override
  String get emptyMessage => 'চক্রে প্রথম বইটি আপনিই দিন। কাছাকাছি কেউ হয়তো ঠিক এই বইটিই খুঁজছেন।';

  @override
  String get noResultsTitle => 'কোনো বই মেলেনি';

  @override
  String noResultsNearby(int km) {
    final intl.NumberFormat kmNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String kmString = kmNumberFormat.format(km);

    return 'এই মুহূর্তে $kmString কিমির মধ্যে কিছু নেই। আরও দূর পর্যন্ত খুঁজুন অথবা ফিল্টার কমিয়ে দেখুন।';
  }

  @override
  String get noResultsGeneric => 'অন্য নাম বা লেখক দিয়ে খুঁজুন, অথবা ফিল্টার কমিয়ে দেখুন।';

  @override
  String get statusShortReserved => 'রিজার্ভড';

  @override
  String get statusShortGone => 'চলে গেছে';

  @override
  String get mapLoading => 'আপনার আশপাশের বই খোঁজা হচ্ছে';

  @override
  String mapBookCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ম্যাপে $countStringটি বই',
      zero: 'এখানে কোনো বই মেলেনি',
    );
    return '$_temp0';
  }

  @override
  String get mapMyLocation => 'আমার অবস্থান';

  @override
  String get mapNothingMatches => 'আপনার সার্চ ও ফিল্টারের সাথে কিছু মেলেনি।';

  @override
  String get mapClear => 'মুছুন';

  @override
  String get previewTitle => 'ম্যাপে';

  @override
  String get previewViewBook => 'বইটি দেখুন';

  @override
  String distanceAway(String distance) {
    return '$distance দূরে';
  }

  @override
  String get locationServicesOff => 'কাছাকাছি বই দেখতে লোকেশন সার্ভিস চালু করুন।';

  @override
  String get locationDialogTitle => 'লোকেশনের অনুমতি প্রয়োজন';

  @override
  String locationDialogBody(String appName) {
    return 'বিনিময়ের জন্য কাছাকাছি থাকা বই খুঁজে দেখাতে $appName-এর আপনার লোকেশন প্রয়োজন। লোকেশন শুধু দূরত্ব হিসাব করতে আপনার ডিভাইসেই ব্যবহার হয়, সারাক্ষণ ট্র্যাক করা হয় না।';
  }

  @override
  String get locationDeny => 'না, থাক';

  @override
  String get locationAccept => 'অনুমতি দিন';

  @override
  String get locationPermissionNeeded => 'কাছাকাছি বই দেখাতে লোকেশনের অনুমতি প্রয়োজন।';

  @override
  String get locationOpenSettings => 'সেটিংস';

  @override
  String get locationFailed => 'আপনার অবস্থান জানা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get viewList => 'তালিকায় দেখুন';

  @override
  String get viewMap => 'ম্যাপে দেখুন';

  @override
  String get filterSheetSubtitle => 'কোন বইগুলো দেখতে চান, বেছে নিন';

  @override
  String get filterSheetReset => 'রিসেট';

  @override
  String filterSheetApply(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countStringটি বই দেখুন',
      zero: 'কোনো বই মেলেনি',
    );
    return '$_temp0';
  }

  @override
  String get filterSectionMode => 'কীভাবে দেওয়া হচ্ছে';

  @override
  String get filterFreeToTake => 'বিনামূল্যের বই';

  @override
  String get filterSectionGenre => 'ধরন';

  @override
  String get filterAnyGenre => 'যেকোনো ধরন';

  @override
  String get filterSectionCondition => 'বইয়ের অবস্থা';

  @override
  String get filterAnyCondition => 'যেকোনো অবস্থা';

  @override
  String filterNearMe(int km) {
    final intl.NumberFormat kmNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String kmString = kmNumberFormat.format(km);

    return 'আমার $kmString কিমির মধ্যে';
  }

  @override
  String get filterLocating => 'আপনার অবস্থান খোঁজা হচ্ছে…';

  @override
  String get filterNearMeHint => 'লোকেশন শুধু দূরত্ব মাপার জন্য ব্যবহার হয়';

  @override
  String get filterAvailableHint => 'যেসব বইয়ে আগেই অনুরোধ এসেছে, সেগুলো লুকান';
}
