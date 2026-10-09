// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'library_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class LibraryL10nBn extends LibraryL10n {
  LibraryL10nBn([String locale = 'bn']) : super(locale);

  @override
  String get libraryTitle => 'আমার লাইব্রেরি';

  @override
  String get summarySignedOut => 'বই শেয়ার করতে ও চাইতে সাইন ইন করুন';

  @override
  String get summaryLoading => 'আপনার বইয়ের তাক খোলা হচ্ছে…';

  @override
  String summaryBooksShared(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countStringটি বই শেয়ার করেছেন',
      zero: 'এখনো কোনো বই শেয়ার করেননি',
    );
    return '$_temp0';
  }

  @override
  String summaryRequestsWaiting(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countStringটি অনুরোধ অপেক্ষায়';
  }

  @override
  String summaryHandOffsInProgress(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countStringটি হাতবদল চলছে';
  }

  @override
  String get tabMyBooks => 'আমার বই';

  @override
  String get tabMyRequests => 'আমার অনুরোধ';

  @override
  String get tabRequestsToMe => 'আমার কাছে অনুরোধ';

  @override
  String get tabHistory => 'ইতিহাস';

  @override
  String get signedOutTitle => 'আপনার লাইব্রেরি এখানেই';

  @override
  String get signedOutMessage =>
      'সাইন ইন করে নিজের বই শেয়ার করুন, অন্যের বই চেয়ে নিন আর প্রতিটি হাতবদলের খোঁজ রাখুন।';

  @override
  String get signInAction => 'সাইন ইন করুন';

  @override
  String get booksLoadErrorTitle => 'আপনার বইগুলো লোড করা যায়নি';

  @override
  String get requestsLoadErrorTitle => 'আপনার অনুরোধগুলো লোড করা যায়নি';

  @override
  String get emptyBooksTitle => 'আপনার তাক এখনো ফাঁকা';

  @override
  String get emptyBooksMessage =>
      'পড়া শেষ হওয়া একটি বই শেয়ার করুন। হয়তো কাছেই কোনো পাঠক ঠিক এই বইটিই খুঁজছেন।';

  @override
  String get addBookAction => 'বই যোগ করুন';

  @override
  String get emptySentTitle => 'এখন কোনো অনুরোধ চলমান নেই';

  @override
  String get emptySentMessage =>
      'কোনো বই চাইলে অনুরোধ থেকে হাতবদল পর্যন্ত পুরো যাত্রা এখানে দেখতে পাবেন।';

  @override
  String get discoverBooksAction => 'বই খুঁজুন';

  @override
  String get emptyReceivedTitle => 'এখনো কেউ বই চাননি';

  @override
  String get emptyReceivedMessage =>
      'কোনো পাঠক আপনার বই চাইলে অনুরোধটি এখানে দেখা যাবে। তখন আপনি সেটি গ্রহণ করতে বা ফিরিয়ে দিতে পারবেন।';

  @override
  String get emptyHistoryTitle => 'এখনো কোনো ইতিহাস নেই';

  @override
  String get emptyHistoryMessage =>
      'সম্পন্ন, প্রত্যাখ্যাত ও বাতিল হওয়া অনুরোধগুলো এখানে জমা থাকে, সঙ্গে আপনাদের দেওয়া রিভিউও।';

  @override
  String get snackBookRemoved => 'বইটি আপনার লাইব্রেরি থেকে সরানো হয়েছে';

  @override
  String get bookOptionsTitle => 'বইয়ের অপশন';

  @override
  String get bookLockedCompleted =>
      'এই বইটি এরই মধ্যে নতুন পাঠকের হাতে পৌঁছে গেছে, তাই এটি আর সম্পাদনা করা বা সরানো যাবে না।';

  @override
  String get bookLockedInRequest =>
      'এই বইটি এখন একটি অনুরোধের সঙ্গে যুক্ত। সেটি মিটে গেলে সম্পাদনা করতে বা সরাতে পারবেন।';

  @override
  String get bookActionView => 'বইটি দেখুন';

  @override
  String get bookActionEdit => 'তথ্য সম্পাদনা করুন';

  @override
  String get bookActionRemove => 'লাইব্রেরি থেকে সরান';

  @override
  String get deleteBookTitle => 'বইটি সরিয়ে ফেলবেন?';

  @override
  String deleteBookMessage(String title) {
    return '“$title” বইচক্র থেকে সরে যাবে এবং পাঠকেরা আর এটি চাইতে পারবেন না। এটি আর ফিরিয়ে আনা যাবে না।';
  }

  @override
  String get deleteBookConfirm => 'সরান';

  @override
  String get keepItAction => 'রেখে দিন';

  @override
  String get snackRequestAccepted =>
      'অনুরোধ গ্রহণ করা হয়েছে। চ্যাটে কথা বলে হাতবদলের ব্যবস্থা করুন।';

  @override
  String get declineDialogTitle => 'অনুরোধটি ফিরিয়ে দেবেন?';

  @override
  String declineDialogMessage(String name) {
    return '$name জানতে পারবেন যে আপনি রাজি হননি। আপনার বইটি অন্য পাঠকদের জন্য খোলা থাকবে।';
  }

  @override
  String get declineAction => 'ফিরিয়ে দিন';

  @override
  String get notNowAction => 'এখন নয়';

  @override
  String get snackRequestDeclined => 'অনুরোধ ফিরিয়ে দেওয়া হয়েছে';

  @override
  String get cancelDialogTitle => 'অনুরোধটি বাতিল করবেন?';

  @override
  String get cancelDialogMessage =>
      'মালিক জানতে পারবেন যে বইটি আপনার আর লাগবে না। বইটি তখনো পাওয়া গেলে পরে আবার চাইতে পারবেন।';

  @override
  String get cancelRequestAction => 'অনুরোধ বাতিল করুন';

  @override
  String get snackRequestCancelled => 'অনুরোধ বাতিল করা হয়েছে';

  @override
  String get confirmReceivedTitle => 'বইটি হাতে পেয়েছেন?';

  @override
  String get confirmHandedOverTitle => 'বইটি দিয়ে দিয়েছেন?';

  @override
  String get confirmReceivedMessage =>
      'বইটি হাতে পাওয়ার পরেই কেবল নিশ্চিত করুন।';

  @override
  String get confirmHandedOverMessage =>
      'পাঠক বইটি হাতে পাওয়ার পরেই কেবল নিশ্চিত করুন।';

  @override
  String get confirmDetailCompletes =>
      'এতে বিনিময়টি সম্পন্ন হবে, এরপর আপনারা একে অপরকে রিভিউ দিতে পারবেন।';

  @override
  String get confirmDetailWaitsOther =>
      'অন্যজনও নিশ্চিত করলে বিনিময়টি সম্পন্ন হবে।';

  @override
  String get confirmReceivedYes => 'হ্যাঁ, পেয়েছি';

  @override
  String get confirmHandedOverYes => 'হ্যাঁ, দিয়েছি';

  @override
  String get notYetAction => 'এখনো না';

  @override
  String get snackExchangeComplete =>
      'বিনিময় সম্পন্ন হয়েছে। এখন রিভিউ দিতে পারেন।';

  @override
  String get snackConfirmedWaiting =>
      'নিশ্চিত করা হয়েছে। এখন অন্যজনের নিশ্চিত করার অপেক্ষা।';

  @override
  String get snackReviewSubmitted => 'রিভিউ জমা হয়েছে। ধন্যবাদ!';

  @override
  String get missingBookTitle => 'বইটি আর তালিকায় নেই';

  @override
  String bookNextPeopleAsked(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString জন এই বইটি চেয়েছেন';
  }

  @override
  String get bookNextSomeoneAsked => 'কেউ একজন এই বইটি চেয়েছেন';

  @override
  String get bookNextHandOff => 'হাতবদল চলছে';

  @override
  String get bookNextFoundReader => 'নতুন পাঠক পেয়েছে';

  @override
  String get fallbackOwner => 'মালিক';

  @override
  String get fallbackOwnerInline => 'মালিক';

  @override
  String get fallbackReader => 'পাঠক';

  @override
  String get fallbackReaderInline => 'পাঠক';

  @override
  String get captionYouAsked => 'যাঁর কাছে চেয়েছেন';

  @override
  String get captionAskedBy => 'বইটি চেয়েছেন';

  @override
  String askedTime(String time) {
    return '$time চাওয়া হয়েছে';
  }

  @override
  String get youOfferedInReturn => 'বিনিময়ে আপনি দিতে চান';

  @override
  String get offeredInReturn => 'বিনিময়ে দিতে চান';

  @override
  String get pillYouConfirmed => 'আপনি: নিশ্চিত করেছেন';

  @override
  String get pillYouNotYet => 'আপনি: এখনো না';

  @override
  String get pillOwnerConfirmed => 'মালিক: নিশ্চিত করেছেন';

  @override
  String get pillOwnerNotYet => 'মালিক: এখনো না';

  @override
  String get pillReaderConfirmed => 'পাঠক: নিশ্চিত করেছেন';

  @override
  String get pillReaderNotYet => 'পাঠক: এখনো না';

  @override
  String requestBannerWaitingTitle(String name) {
    return '$name এখনো উত্তর দেননি';
  }

  @override
  String get requestBannerWaitingMessage =>
      'তিনি আপনার অনুরোধ গ্রহণ করবেন বা ফিরিয়ে দেবেন। তার আগে যেকোনো সময় আপনি এটি বাতিল করতে পারেন।';

  @override
  String requestBannerSwapOfferTitle(String name) {
    return '$name বই বিনিময় করতে চান';
  }

  @override
  String requestBannerWantsBookTitle(String name) {
    return '$name এই বইটি চেয়েছেন';
  }

  @override
  String get requestBannerIncomingMessage =>
      'গ্রহণ করলে হাতবদলের ব্যবস্থা করতে একটি চ্যাট খুলবে, আর এই বইয়ের অন্য অনুরোধগুলো প্রত্যাখ্যাত হয়ে যাবে।';

  @override
  String get requestBannerYouConfirmedTitle => 'আপনি নিশ্চিত করেছেন';

  @override
  String requestBannerYouConfirmedMessage(String name) {
    return '$name এখনো হাতবদল নিশ্চিত করেননি। তিনি নিশ্চিত করলেই বিনিময় সম্পন্ন হবে।';
  }

  @override
  String get requestBannerYourTurnTitle => 'এবার আপনার নিশ্চিত করার পালা';

  @override
  String requestBannerYourTurnSeekerMessage(String name) {
    return '$name জানিয়েছেন যে বইটি দিয়ে দিয়েছেন। বই হাতে পেলে নিশ্চিত করুন, তাহলেই বিনিময় সম্পন্ন হবে।';
  }

  @override
  String requestBannerYourTurnOwnerMessage(String name) {
    return '$name জানিয়েছেন যে বইটি পেয়েছেন। আপনিও নিশ্চিত করুন, তাহলেই বিনিময় সম্পন্ন হবে।';
  }

  @override
  String requestBannerSaidYesTitle(String name) {
    return '$name রাজি হয়েছেন';
  }

  @override
  String get requestBannerHandOverTitle => 'এবার বইটি পৌঁছে দেওয়ার পালা';

  @override
  String get requestBannerArrangeSeekerMessage =>
      'চ্যাটে কথা বলে সময় ও জায়গা ঠিক করুন। বই হাতে পেলে এখানে নিশ্চিত করুন।';

  @override
  String get requestBannerArrangeOwnerMessage =>
      'চ্যাটে কথা বলে সময় ও জায়গা ঠিক করুন। বই দিয়ে দেওয়ার পর এখানে নিশ্চিত করুন।';

  @override
  String get handOffEyebrow => 'হাতবদল';

  @override
  String trackingId(String id) {
    return 'ট্র্যাকিং $id';
  }

  @override
  String get acceptAction => 'গ্রহণ করুন';

  @override
  String get receivedBookAction => 'বইটি হাতে পেয়েছি';

  @override
  String get handedOverAction => 'বইটি দিয়ে দিয়েছি';

  @override
  String get arrangeInChatAction => 'চ্যাটে হাতবদল ঠিক করুন';

  @override
  String get openChatAction => 'চ্যাট খুলুন';

  @override
  String historyReceivedFrom(String name) {
    return '$name আপনাকে এই বইটি দিয়েছেন';
  }

  @override
  String historyGaveTo(String name) {
    return '$name আপনার কাছ থেকে এই বইটি পেয়েছেন';
  }

  @override
  String historyTheyDeclined(String name) {
    return '$name আপনার অনুরোধ ফিরিয়ে দিয়েছেন';
  }

  @override
  String historyYouDeclined(String name) {
    return '$name বইটি চেয়েছিলেন, আপনি রাজি হননি';
  }

  @override
  String historyYouCancelled(String name) {
    return '$name-এর কাছে পাঠানো অনুরোধটি আপনি বাতিল করেছেন';
  }

  @override
  String historyTheyCancelled(String name) {
    return '$name নিজের অনুরোধ বাতিল করেছেন';
  }

  @override
  String historyYouAsked(String name) {
    return 'আপনি $name-এর কাছে বইটি চেয়েছেন';
  }

  @override
  String historyTheyAsked(String name) {
    return '$name এই বইটি চেয়েছেন';
  }

  @override
  String get reviewYouRated => 'আপনার দেওয়া রেটিং';

  @override
  String get reviewTheyRated => 'আপনার পাওয়া রেটিং';

  @override
  String reviewPrompt(String name) {
    return '$name-এর সঙ্গে বিনিময় কেমন হলো? আপনার রিভিউ দেখে অন্য পাঠকেরা তাঁর ওপর ভরসা করতে পারবেন।';
  }

  @override
  String get leaveReviewAction => 'রিভিউ দিন';

  @override
  String reviewNotLeftYet(String name) {
    return '$name এখনো রিভিউ দেননি।';
  }

  @override
  String reviewQuote(String text) {
    return '“$text”';
  }

  @override
  String get reviewSheetSubtitle => 'বিনিময় কেমন হলো?';

  @override
  String reviewSheetSubtitleNamed(String name) {
    return '$name-এর সঙ্গে বিনিময় কেমন হলো?';
  }

  @override
  String get submitReviewAction => 'রিভিউ জমা দিন';

  @override
  String get ratingLabelNotGood => 'ভালো লাগেনি';

  @override
  String get ratingLabelCouldBeBetter => 'আরও ভালো হতে পারত';

  @override
  String get ratingLabelOkay => 'মোটামুটি';

  @override
  String get ratingLabelGood => 'ভালো';

  @override
  String get ratingLabelExcellent => 'চমৎকার';

  @override
  String get reviewFieldLabel => 'আপনার রিভিউ (ঐচ্ছিক)';

  @override
  String get reviewFieldHint =>
      'বইটি কি বর্ণনার সঙ্গে মিলেছে? দেখা করা কি সহজ ছিল?';

  @override
  String get reviewShareNote =>
      'আপনার রেটিং তিনি দেখতে পাবেন এবং এটি তাঁর প্রোফাইলে যোগ হবে।';

  @override
  String get journeyEyebrow => 'যাত্রা';

  @override
  String get journeyHideSteps => 'যাত্রার ধাপগুলো লুকান';

  @override
  String get journeyShowSteps => 'যাত্রার ধাপগুলো দেখুন';

  @override
  String get journeySummaryDeclined => 'শেষ · অনুরোধ প্রত্যাখ্যাত';

  @override
  String get journeySummaryCancelled => 'শেষ · অনুরোধ বাতিল';

  @override
  String get journeySummaryComplete => 'সম্পন্ন · রিভিউসহ সব শেষ';

  @override
  String journeySummaryProgress(int done, int total, String next) {
    final intl.NumberFormat doneNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String doneString = doneNumberFormat.format(done);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$totalStringটির মধ্যে $doneStringটি ধাপ শেষ · এরপর: $next';
  }

  @override
  String get journeyStepRequested => 'অনুরোধ';

  @override
  String get journeyStepDeclined => 'প্রত্যাখ্যাত';

  @override
  String get journeyStepCancelled => 'বাতিল';

  @override
  String get journeyStepAccepted => 'অনুরোধ গ্রহণ';

  @override
  String get journeyStepHandOffArranged => 'হাতবদলের ব্যবস্থা';

  @override
  String get journeyStepBothConfirmed => 'দুজনের নিশ্চিতকরণ';

  @override
  String get journeyStepReviewed => 'রিভিউ';

  @override
  String journeyRequestedSeeker(String time) {
    return 'আপনি এই বইটি চেয়েছেন · $time';
  }

  @override
  String journeyRequestedOwner(String time) {
    return 'একজন পাঠক আপনার বইটি চেয়েছেন · $time';
  }

  @override
  String get journeyDeclinedSeeker => 'মালিক এবার বইটি দিতে পারেননি';

  @override
  String get journeyDeclinedOwner => 'আপনি এই অনুরোধটি ফিরিয়ে দিয়েছেন';

  @override
  String get journeyCancelledSeeker => 'আপনি এই অনুরোধটি বাতিল করেছেন';

  @override
  String get journeyCancelledOwner => 'পাঠক নিজের অনুরোধ বাতিল করেছেন';

  @override
  String get journeyWaitingOwnerReply => 'মালিকের উত্তরের অপেক্ষা';

  @override
  String get journeyWaitingYourReply => 'আপনার উত্তরের অপেক্ষা';

  @override
  String get journeyArrangeHint => 'চ্যাটে সময় ও জায়গা ঠিক করুন';

  @override
  String get journeyChangedHands => 'বইটি হাতবদল হয়েছে';

  @override
  String get journeyBothConfirmedFinishing =>
      'দুজনই নিশ্চিত করেছেন · শেষ ধাপ চলছে';

  @override
  String get journeyReviewPrompt => 'রিভিউ দিয়ে যাত্রাটি পূর্ণ করুন';

  @override
  String journeyYouRated(String rating) {
    return 'আপনি রেটিং দিয়েছেন $rating';
  }

  @override
  String journeyBothRated(String mine, String theirs) {
    return 'আপনি দিয়েছেন $mine · আপনি পেয়েছেন $theirs';
  }

  @override
  String get journeyNow => 'এখন';
}
