// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'book_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class BookL10nBn extends BookL10n {
  BookL10nBn([String locale = 'bn']) : super(locale);

  @override
  String get listingRemovedSnack => 'আপনার বইটি সরিয়ে ফেলা হয়েছে।';

  @override
  String get shareTooltip => 'বইটি শেয়ার করুন';

  @override
  String get moreOptions => 'আরও অপশন';

  @override
  String get openErrorTitle => 'বইটি খোলা যায়নি';

  @override
  String get removedTitle => 'এই বইটি সরিয়ে ফেলা হয়েছে';

  @override
  String get removedMessage => 'বইটি আর বইচক্রে নেই।';

  @override
  String get goBack => 'ফিরে যান';

  @override
  String get notFoundTitle => 'বইটি পাওয়া যায়নি';

  @override
  String get notFoundMessage => 'মালিক হয়তো বইটি সরিয়ে ফেলেছেন।';

  @override
  String get yourListingPill => 'আপনার বই';

  @override
  String authorByline(String author) {
    return 'লেখক: $author';
  }

  @override
  String get aboutCopyTitle => 'এই কপি সম্পর্কে';

  @override
  String get yourNoteTitle => 'আপনার নোট';

  @override
  String get fromOwnerTitle => 'মালিকের কথা';

  @override
  String get listedByYouTitle => 'আপনি যোগ করেছেন';

  @override
  String get ownerTitle => 'মালিক';

  @override
  String get howItWorksTitle => 'যেভাবে কাজ করে';

  @override
  String get factCondition => 'অবস্থা';

  @override
  String get factDistance => 'দূরত্ব';

  @override
  String distanceAway(String distance) {
    return '$distance দূরে';
  }

  @override
  String get factArea => 'এলাকা';

  @override
  String get factListed => 'যোগ হয়েছে';

  @override
  String get factIsbn => 'ISBN';

  @override
  String get factGenres => 'ধরন';

  @override
  String get ownerUnavailable => 'এই মুহূর্তে মালিকের তথ্য দেখানো যাচ্ছে না।';

  @override
  String get requestsTitle => 'অনুরোধ';

  @override
  String get requestsRefreshing => 'রিফ্রেশ হচ্ছে…';

  @override
  String requestsWaiting(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString জন পাঠক আপনার উত্তরের অপেক্ষায় আছেন';
  }

  @override
  String get requestsLoadErrorTitle => 'অনুরোধগুলো লোড করা যায়নি';

  @override
  String get requestsEmptyTitle => 'এখনো কোনো অনুরোধ আসেনি';

  @override
  String get requestsEmptyMessage => 'আশপাশের পাঠকেরা ‘খুঁজুন’ ট্যাবে এই বইটি পাবেন।';

  @override
  String get requestsNoneOpen => 'এই মুহূর্তে কোনো চলমান অনুরোধ নেই। আগের অনুরোধগুলো লাইব্রেরিতে রাখা আছে।';

  @override
  String requestedTime(String time) {
    return 'অনুরোধ: $time';
  }

  @override
  String acceptedTime(String time) {
    return 'গৃহীত: $time';
  }

  @override
  String get decline => 'ফিরিয়ে দিন';

  @override
  String get accept => 'গ্রহণ করুন';

  @override
  String get confirmHandover => 'হাতবদল নিশ্চিত করুন';

  @override
  String get handoverConfirmedBanner => 'আপনি হাতবদল নিশ্চিত করেছেন। এখন পাঠকের নিশ্চিত করার অপেক্ষা।';

  @override
  String get openChat => 'চ্যাট খুলুন';

  @override
  String get offersInExchange => 'বিনিময়ে দিতে চান';

  @override
  String get offeredLoading => 'প্রস্তাবিত বইটি লোড হচ্ছে…';

  @override
  String get offeredUnavailable => 'বইটি আর পাওয়া যাচ্ছে না';

  @override
  String get acceptDialogTitle => 'অনুরোধটি গ্রহণ করবেন?';

  @override
  String get acceptDialogMessageDonate => 'হাতবদলের ব্যবস্থা করতে আপনাদের দুজনের জন্য একটি চ্যাট খুলবে।';

  @override
  String get acceptDialogMessageExchange => 'বিনিময়ের ব্যবস্থা করতে আপনাদের দুজনের জন্য একটি চ্যাট খুলবে।';

  @override
  String get acceptDialogConfirm => 'অনুরোধ গ্রহণ করুন';

  @override
  String get acceptProgress => 'অনুরোধ গ্রহণ করা হচ্ছে…';

  @override
  String get acceptSuccess => 'অনুরোধ গ্রহণ করা হয়েছে। কথা বলার জন্য একটি চ্যাট খোলা হয়েছে।';

  @override
  String get declineDialogTitle => 'অনুরোধটি ফিরিয়ে দেবেন?';

  @override
  String get declineDialogMessage => 'পাঠককে জানিয়ে দেওয়া হবে, আর আপনার বইটি অন্যদের জন্য খোলা থাকবে।';

  @override
  String get declineDialogConfirm => 'অনুরোধ ফিরিয়ে দিন';

  @override
  String get declineProgress => 'অনুরোধ ফিরিয়ে দেওয়া হচ্ছে…';

  @override
  String get declineSuccess => 'অনুরোধ ফিরিয়ে দেওয়া হয়েছে।';

  @override
  String get handoverDialogTitle => 'হাতবদল নিশ্চিত করবেন?';

  @override
  String get handoverDialogMessage => 'বই হাতবদল হওয়ার পরেই নিশ্চিত করুন। দুজনই নিশ্চিত করলে এটি সম্পন্ন হিসেবে চিহ্নিত হবে।';

  @override
  String get handoverDialogConfirm => 'হ্যাঁ, নিশ্চিত করুন';

  @override
  String requestUpdateFailed(String error) {
    return 'অনুরোধ আপডেট করা যায়নি: $error';
  }

  @override
  String get signInToConfirm => 'বিনিময় নিশ্চিত করতে সাইন ইন করুন।';

  @override
  String get exchangeConfirmRecorded => 'আপনার নিশ্চিতকরণ সংরক্ষিত হয়েছে।';

  @override
  String exchangeConfirmFailed(String error) {
    return 'বিনিময় নিশ্চিত করা যায়নি: $error';
  }

  @override
  String get exchangeConfirmProgress => 'বিনিময় নিশ্চিত করা হচ্ছে…';

  @override
  String get seekerBarAccepted => 'মালিক আপনার অনুরোধ গ্রহণ করেছেন। চ্যাটে কথা বলে হাতবদলের ব্যবস্থা করুন।';

  @override
  String seekerBarRequestSent(String time) {
    return '$time অনুরোধ পাঠানো হয়েছে। মালিকের উত্তরের অপেক্ষায় আছে।';
  }

  @override
  String get messageOwner => 'মালিককে মেসেজ দিন';

  @override
  String get seekerBarCompleted => 'বইটি ইতিমধ্যে নতুন পাঠকের হাতে পৌঁছে গেছে।';

  @override
  String get seekerBarBusy => 'অন্য একজন পাঠকের সঙ্গে বইটির হাতবদল চলছে, তাই এখন অনুরোধ করা যাবে না।';

  @override
  String get notAvailable => 'এখন পাওয়া যাচ্ছে না';

  @override
  String get requestThisBook => 'অনুরোধ করুন';

  @override
  String get offerSwap => 'বিনিময়ের প্রস্তাব দিন';

  @override
  String get ownerBarWaitingReader => 'আপনি হাতবদল নিশ্চিত করেছেন। পাঠকের নিশ্চিত করার অপেক্ষা।';

  @override
  String get ownerBarAccepted => 'অনুরোধ গৃহীত হয়েছে। বই হাতবদল হলে নিশ্চিত করুন।';

  @override
  String ownerBarReviewRequests(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countStringটি অনুরোধ দেখুন';
  }

  @override
  String get ownerBarLive => 'আপনার বইটি এখন সবাই দেখতে পাচ্ছেন। অনুরোধ এলে এখানে দেখাব।';

  @override
  String get editListing => 'বইয়ের তথ্য সম্পাদনা';

  @override
  String get ownerBarCompleted => 'বইটি নতুন পাঠকের হাতে পৌঁছে গেছে। শেয়ার করার জন্য ধন্যবাদ।';

  @override
  String ownerBarInProgress(String status) {
    return 'বইটির অবস্থা: $status। ওপরের অনুরোধগুলো থেকে অগ্রগতি দেখুন।';
  }

  @override
  String shareText(String title, String author, String mode, String condition) {
    return '📚 $title — $author\nধরন: $mode\nঅবস্থা: $condition\n\nবইটি পাবেন বইচক্রে!';
  }

  @override
  String get manageListingTitle => 'বইটি পরিচালনা';

  @override
  String get actionBlockedSubtitle => 'বিনিময় চলাকালে এটি করা যাবে না';

  @override
  String get deleteListing => 'বইটি মুছে ফেলুন';

  @override
  String get saveToWishlist => 'উইশলিস্টে রাখুন';

  @override
  String get reportBook => 'বইটি রিপোর্ট করুন';

  @override
  String get reportBookSubtitle => 'কিছু ঠিক না মনে হলে আমাদের জানান';

  @override
  String get blockOwner => 'মালিককে ব্লক করুন';

  @override
  String get blockOwnerSubtitle => 'এই ব্যক্তির বইগুলো আর দেখাবে না';

  @override
  String get deleteDialogTitle => 'বইটি মুছে ফেলবেন?';

  @override
  String deleteDialogMessage(String title) {
    return '“$title” বইচক্র থেকে সরিয়ে ফেলা হবে। এটি আর ফেরানো যাবে না।';
  }

  @override
  String get signInToReport => 'বই রিপোর্ট করতে সাইন ইন করুন।';

  @override
  String get reportDialogTitle => 'বইটি রিপোর্ট করবেন?';

  @override
  String get reportDialogMessage => 'আমাদের টিম বইটি খতিয়ে দেখবে। কে রিপোর্ট করেছেন, মালিক তা জানবেন না।';

  @override
  String get reportDialogConfirm => 'রিপোর্ট পাঠান';

  @override
  String get reportSuccess => 'রিপোর্ট পাঠানো হয়েছে। ধন্যবাদ!';

  @override
  String reportFailed(String error) {
    return 'রিপোর্ট পাঠানো যায়নি: $error';
  }

  @override
  String get signInToBlock => 'কাউকে ব্লক করতে সাইন ইন করুন।';

  @override
  String get blockDialogTitle => 'এই মালিককে ব্লক করবেন?';

  @override
  String get blockDialogMessage => 'তাঁর বইগুলো আর দেখতে পাবেন না, আর এই পাতা থেকে বেরিয়ে যাবেন।';

  @override
  String get blockSuccess => 'ব্যবহারকারীকে ব্লক করা হয়েছে।';

  @override
  String blockFailed(String error) {
    return 'ব্লক করা যায়নি: $error';
  }

  @override
  String get signInToSave => 'বই সংরক্ষণ করতে সাইন ইন করুন।';

  @override
  String get wishlistSaved => 'আপনার উইশলিস্টে রাখা হয়েছে।';

  @override
  String wishlistFailed(String error) {
    return 'সংরক্ষণ করা যায়নি: $error';
  }

  @override
  String get signInToRequest => 'বইয়ের অনুরোধ করতে সাইন ইন করুন';

  @override
  String get cannotRequestOwn => 'নিজের বইয়ের জন্য অনুরোধ করা যায় না';

  @override
  String get alreadyRequested => 'আপনি আগেই এই বইটির অনুরোধ করেছেন।';

  @override
  String get requestSheetTitle => 'বইটির জন্য অনুরোধ';

  @override
  String get requestSheetSubtitle => 'আপনার অনুরোধটি মালিকের অনুমোদনের জন্য যাবে।';

  @override
  String get sendRequest => 'অনুরোধ পাঠান';

  @override
  String get giftBannerTitle => 'বইটি উপহার';

  @override
  String get giftBannerMessage => 'বিনিময়ে কিছু দিতে হবে না। মালিক গ্রহণ করলে হাতবদলের ব্যবস্থা করতে একটি চ্যাট খুলবে।';

  @override
  String get swapRequestProgress => 'বিনিময়ের অনুরোধ পাঠানো হচ্ছে…';

  @override
  String swapRequestSuccess(String offered, String requested) {
    return 'বিনিময়ের অনুরোধ পাঠানো হয়েছে। “$requested”-এর বদলে আপনি “$offered” দিতে চেয়েছেন।';
  }

  @override
  String get requestProgress => 'অনুরোধ পাঠানো হচ্ছে…';

  @override
  String requestSuccess(String title) {
    return '“$title”-এর জন্য অনুরোধ পাঠানো হয়েছে।';
  }

  @override
  String requestFailed(String error) {
    return 'অনুরোধ পাঠানো যায়নি: $error';
  }

  @override
  String get signInToMessage => 'মালিককে মেসেজ দিতে সাইন ইন করুন';

  @override
  String get ownBook => 'এটি আপনার নিজের বই';

  @override
  String chatCreateFailed(String error) {
    return 'চ্যাট খোলা যায়নি: $error';
  }

  @override
  String get chatOpening => 'চ্যাট খোলা হচ্ছে…';

  @override
  String get howDonateAskTitle => 'বইটি চেয়ে নিন';

  @override
  String get howDonateAskBody => 'একটি অনুরোধ পাঠান। বইটি বিনামূল্যে, বিনিময়ে কিছু দিতে হবে না।';

  @override
  String get howOwnerAcceptsTitle => 'মালিক গ্রহণ করবেন';

  @override
  String get howOwnerAcceptsBody => 'একটি চ্যাট খুলবে, সেখানে সময় আর নিরাপদ কোনো খোলা জায়গা ঠিক করে নিন।';

  @override
  String get howDonateCollectTitle => 'বই নিন, নিশ্চিত করুন';

  @override
  String get howDonateCollectBody => 'বইটি বুঝে নিন, তারপর দুজনই হাতবদল নিশ্চিত করুন।';

  @override
  String get howSwapOfferTitle => 'নিজের একটি বইয়ের প্রস্তাব দিন';

  @override
  String get howSwapOfferBody => 'বিনিময়ে দেওয়ার জন্য আপনার লাইব্রেরি থেকে একটি বই বেছে নিন।';

  @override
  String get howSwapTradeTitle => 'বদলে নিন, নিশ্চিত করুন';

  @override
  String get howSwapTradeBody => 'সরাসরি দেখা করে বই বদলে নিন, তারপর দুজনই বিনিময় নিশ্চিত করুন।';

  @override
  String get offerEmptyTitle => 'দেওয়ার মতো কোনো বই এখনো নেই';

  @override
  String get offerEmptyMessage => 'আগে আপনার লাইব্রেরিতে একটি বই যোগ করুন, তারপর ফিরে এসে এই বইটির বদলে সেটির প্রস্তাব দিন।';

  @override
  String get offerAddBook => 'বই যোগ করুন';

  @override
  String get offerAskingFor => 'আপনি চাইছেন';

  @override
  String get offerYourBooks => 'আপনার যে বইগুলো দেওয়া যাবে';

  @override
  String get offerPickPrompt => 'একটি বই বেছে নিন';

  @override
  String get offerSendSwap => 'বিনিময়ের অনুরোধ পাঠান';

  @override
  String get offerLoadErrorTitle => 'আপনার বইগুলো লোড করা যায়নি';

  @override
  String get offerLoading => 'আপনার বইগুলো লোড হচ্ছে…';

  @override
  String get offerSheetTitle => 'বিনিময়ে একটি বই দিন';

  @override
  String get offerSheetSubtitle => 'মালিক আপনার প্রস্তাব দেখে ঠিক করবেন বিনিময় করবেন কি না।';
}
