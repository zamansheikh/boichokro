// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'account_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AccountL10nBn extends AccountL10n {
  AccountL10nBn([String locale = 'bn']) : super(locale);

  @override
  String get splashMotto => 'দান  ·  বিনিময়  ·  পড়া';

  @override
  String get brandAltName => 'Boichokro';

  @override
  String get verifiedReader => 'যাচাইকৃত পাঠক';

  @override
  String get readerFallback => 'পাঠক';

  @override
  String get onboardingSkip => 'বাদ দিন';

  @override
  String get onboardingNext => 'পরবর্তী';

  @override
  String get onboardingGetStarted => 'শুরু করুন';

  @override
  String onboardingPageIndicator(int current, int total) {
    final intl.NumberFormat currentNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String currentString = currentNumberFormat.format(current);
    final intl.NumberFormat totalNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$totalStringটির মধ্যে $currentString নম্বর পাতা';
  }

  @override
  String get onboardingSlide1Title => 'কাছেই খুঁজে নিন বই';

  @override
  String get onboardingSlide1Body => 'আশপাশের পাঠকদের বইয়ের তাক ঘুরে দেখুন, আর হাঁটাপথের দূরত্বেই পেয়ে যান আপনার পরের বইটি।';

  @override
  String get onboardingSlide2Title => 'বিনিময় করুন বা দান করুন';

  @override
  String get onboardingSlide2Body => 'পড়া শেষ হওয়া বইয়ের বদলে পছন্দের বই নিন, কিংবা বইটি বিনামূল্যে কাউকে দিয়ে দিন।';

  @override
  String get onboardingSlide3Title => 'পাঠকদের সঙ্গে যুক্ত হোন';

  @override
  String get onboardingSlide3Body => 'বইয়ের মালিকের সঙ্গে চ্যাট করুন, দেখা করার জায়গা ঠিক করুন, তারপর বইটি হাতবদল করুন।';

  @override
  String onboardingChipDistanceAway(String distance) {
    return '$distance দূরে';
  }

  @override
  String onboardingChipBooksNearYou(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'আপনার কাছেই $countStringটি বই';
  }

  @override
  String get onboardingSampleBookFeluda => 'ফেলুদা সমগ্র';

  @override
  String get onboardingSampleBookSapiens => 'স্যাপিয়েন্স';

  @override
  String get onboardingSampleSeekerName => 'নুসরাত জাহান';

  @override
  String get onboardingSampleOwnerName => 'আরিফ রহমান';

  @override
  String get onboardingSampleQuestion => 'বইটা কি এখনো আছে?';

  @override
  String get onboardingSampleReply => 'আছে! লাইব্রেরির গেটে দেখা করি?';

  @override
  String authWelcome(String name) {
    return 'স্বাগতম, $name!';
  }

  @override
  String get authErrorTitle => 'সাইন ইন করা যায়নি';

  @override
  String get authHeadline => 'পড়া বই দিন।\nনতুন বই নিন।';

  @override
  String get authSubhead => 'আপনার এলাকার পাঠকদের সঙ্গে বই বিনিময় ও দান করুন।';

  @override
  String get authTrustFreeTitle => 'সবসময় বিনামূল্যে';

  @override
  String get authTrustFreeBody => 'কোনো ফি নেই, কেনাবেচা নেই—শুধু বিনিময় আর উপহার।';

  @override
  String get authTrustNearbyTitle => 'আপনার কাছেই';

  @override
  String get authTrustNearbyBody => 'নিজের এলাকার পাঠকদের বই দেখুন।';

  @override
  String get authTrustVerifiedTitle => 'যাচাইকৃত পাঠক';

  @override
  String get authTrustVerifiedBody => 'রেটিং আর ব্যাজ দেখে বুঝুন কার ওপর ভরসা করা যায়।';

  @override
  String get authSigningIn => 'সাইন ইন হচ্ছে…';

  @override
  String get authContinueWithGoogle => 'গুগল দিয়ে এগিয়ে যান';

  @override
  String get authLegalPrefix => 'এগিয়ে গেলে আপনি মেনে নিচ্ছেন আমাদের';

  @override
  String get authLegalTerms => 'সেবার শর্তাবলি';

  @override
  String get authLegalAnd => 'ও';

  @override
  String get authLegalPrivacy => 'গোপনীয়তা নীতি';

  @override
  String get profileTitle => 'প্রোফাইল';

  @override
  String get profileLoadErrorTitle => 'আপনার প্রোফাইল লোড করা যায়নি';

  @override
  String get profileSignedOutTitle => 'সাইন ইন করা নেই';

  @override
  String get profileSignedOutBody => 'প্রোফাইল দেখতে ও নিজের বই সামলাতে সাইন ইন করুন।';

  @override
  String get profileSignIn => 'সাইন ইন';

  @override
  String get profileHistoryTitle => 'ইতিহাস ও রিভিউ';

  @override
  String get profileHistorySubtitle => 'আগের হাতবদল আর আপনার পাওয়া রেটিং';

  @override
  String get profileSettingsSubtitle => 'অ্যাকাউন্ট, গোপনীয়তা, শর্তাবলি ও পরিচিতি';

  @override
  String profileMemberSince(String date) {
    return '$date থেকে সদস্য';
  }

  @override
  String profileToExchange(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'বিনিময়ের জন্য $countStringটি';
  }

  @override
  String profileToDonate(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'দানের জন্য $countStringটি';
  }

  @override
  String get profileEdit => 'প্রোফাইল সম্পাদনা';

  @override
  String get statRating => 'রেটিং';

  @override
  String statSwaps(int count) {
    return 'বিনিময়';
  }

  @override
  String statBooks(int count) {
    return 'বই';
  }

  @override
  String statHandoffs(int count) {
    return 'হাতবদল';
  }

  @override
  String get journeyTitle => 'চক্রে যোগ দিন';

  @override
  String journeyProgress(int done, int total) {
    final intl.NumberFormat doneNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String doneString = doneNumberFormat.format(done);
    final intl.NumberFormat totalNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$totalStringটির মধ্যে $doneStringটি ধাপ সম্পন্ন';
  }

  @override
  String get journeyStep1Title => 'প্রথম বইটি শেয়ার করুন';

  @override
  String get journeyStep1Hint => 'পড়া শেষ হওয়া একটি বই চক্রে দিন';

  @override
  String get journeyStep2Title => 'একটি হাতবদল সম্পন্ন করুন';

  @override
  String get journeyStep2Hint => 'কোনো পাঠককে বই দিন বা তাঁর সঙ্গে বিনিময় করুন';

  @override
  String get journeyStep3Title => 'প্রথম রেটিং অর্জন করুন';

  @override
  String get journeyStep3Hint => 'হাতবদলের পর পাঠকেরা একে অপরকে রেটিং দেন';

  @override
  String get journeyShareBook => 'একটি বই শেয়ার করুন';

  @override
  String get shelfYours => 'আপনার বইয়ের তাক';

  @override
  String get shelfEmptySubtitle => 'আপনার শেয়ার করা বই এখানে দেখা যাবে';

  @override
  String shelfCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'চক্রে $countStringটি বই';
  }

  @override
  String get shelfOpenLibrary => 'লাইব্রেরি খুলুন';

  @override
  String get shelfEmptyTitle => 'আপনার তাক এখনো ফাঁকা';

  @override
  String get shelfEmptyBody => 'পড়া শেষ হওয়া একটি বই যোগ করতে ট্যাপ করুন।';

  @override
  String get inviteTitle => 'বন্ধুকে চক্রে নিয়ে আসুন';

  @override
  String get inviteBody => 'কাছাকাছি যত পাঠক, বেছে নেওয়ার মতো তত বই।';

  @override
  String get inviteButton => 'ইনভাইট';

  @override
  String inviteShareText(String appName, String url) {
    return 'আমি $appName অ্যাপে বিনামূল্যে বই দিচ্ছি আর খুঁজে নিচ্ছি। আপনিও যোগ দিন: $url';
  }

  @override
  String get userThisReader => 'এই পাঠক';

  @override
  String get userMore => 'আরও';

  @override
  String get userReport => 'রিপোর্ট করুন';

  @override
  String get userReportSubtitle => 'এই পাঠককে নিয়ে কোনো সমস্যা হলে আমাদের জানান';

  @override
  String get userBlock => 'ব্লক করুন';

  @override
  String get userBlockSubtitle => 'তিনি আর আপনার সঙ্গে যোগাযোগ করতে পারবেন না';

  @override
  String userReportTitle(String name) {
    return '$name সম্পর্কে রিপোর্ট';
  }

  @override
  String get userReportQuestion => 'সমস্যাটা কী?';

  @override
  String get userReportReasonSpam => 'স্প্যাম';

  @override
  String get userReportReasonHarassment => 'হয়রানি';

  @override
  String get userReportReasonInappropriate => 'আপত্তিকর কনটেন্ট';

  @override
  String get userReportReasonOther => 'অন্যান্য';

  @override
  String userBlockConfirmTitle(String name) {
    return '$name-কে ব্লক করবেন?';
  }

  @override
  String get userBlockConfirmBody => 'তাঁর কাছ থেকে আর কোনো মেসেজ পাবেন না, আর তিনি আপনার বইয়ের জন্য অনুরোধও করতে পারবেন না।';

  @override
  String get userBlockedSnack => 'পাঠককে ব্লক করা হয়েছে';

  @override
  String get userReportedSnack => 'রিপোর্ট পাঠানো হয়েছে';

  @override
  String get userNotFoundTitle => 'পাঠককে পাওয়া যায়নি';

  @override
  String get userNotFoundBody => 'এই মুহূর্তে প্রোফাইলটি লোড করা যাচ্ছে না।';

  @override
  String get userOwnPreviewBanner => 'অন্য পাঠকেরা আপনার প্রোফাইল এভাবেই দেখেন।';

  @override
  String userReaderSince(String date) {
    return '$date থেকে পাঠক';
  }

  @override
  String get shelfTheirs => 'তাঁর বইয়ের তাকে';

  @override
  String shelfOfName(String name) {
    return '$name-এর বইয়ের তাকে';
  }

  @override
  String get shelfNothingAvailable => 'এই মুহূর্তে কোনো বই পাওয়া যাচ্ছে না';

  @override
  String shelfAvailableCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countStringটি বইয়ের জন্য অনুরোধ করতে পারেন';
  }

  @override
  String get shelfNoBooksTitle => 'তাকে কোনো বই নেই';

  @override
  String get shelfNoBooksBody => 'এই পাঠক এখনো কোনো বই শেয়ার করেননি।';

  @override
  String get trustVerifiedBody => 'এই পাঠকের যাচাইকৃত ব্যাজ আছে।';

  @override
  String get trustNotVerifiedTitle => 'এখনো যাচাই করা হয়নি';

  @override
  String get trustNotVerifiedBody => 'যেকোনো নতুন পাঠকের মতোই, লোকজন আছে এমন খোলা জায়গায় দেখা করুন।';

  @override
  String trustHandoffsTitle(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countStringটি হাতবদল সম্পন্ন';
  }

  @override
  String get trustHandoffsBody => 'অ্যাপের মাধ্যমে দেওয়া, নেওয়া বা বিনিময় করা বই।';

  @override
  String get trustNewTitle => 'চক্রে নতুন';

  @override
  String get trustNewBody => 'এখনো কোনো হাতবদল সম্পন্ন হয়নি। সবার শুরুটা এখান থেকেই।';

  @override
  String get reviewsTitle => 'পাঠকেরা যা বলছেন';

  @override
  String reviewsCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'হাতবদলের পর $countStringটি রিভিউ';
  }

  @override
  String get reviewsEmptyTitle => 'এখনো কোনো রিভিউ নেই';

  @override
  String get reviewsEmptyWithHandoffs => 'হাতবদল নিয়ে পাঠকেরা এখনো কিছু লেখেননি।';

  @override
  String get reviewsEmptyNoHandoffs => 'হাতবদল সম্পন্ন হলে রিভিউ এখানে দেখা যাবে।';

  @override
  String reviewReceivedBook(String name) {
    return '$name · বই পেয়েছেন';
  }

  @override
  String reviewGaveBook(String name) {
    return '$name · বই দিয়েছেন';
  }

  @override
  String get editCameraError => 'ক্যামেরা খোলা যায়নি। অ্যাপের অনুমতিগুলো দেখে নিন।';

  @override
  String get editGalleryError => 'আপনার ছবি খোলা যায়নি। অ্যাপের অনুমতিগুলো দেখে নিন।';

  @override
  String get editPhotoSheetTitle => 'প্রোফাইল ছবি';

  @override
  String get editPhotoSheetSubtitle => 'বই বিনিময়ের সময় অন্য পাঠকেরা এটি দেখতে পান।';

  @override
  String get editTakePhoto => 'ছবি তুলুন';

  @override
  String get editChooseGallery => 'গ্যালারি থেকে বেছে নিন';

  @override
  String get editKeepCurrentPhoto => 'আগের ছবিটাই থাকুক';

  @override
  String get editKeepCurrentPhotoSubtitle => 'এইমাত্র বেছে নেওয়া ছবিটি বাদ দিন';

  @override
  String get editStillLoading => 'আপনার প্রোফাইল এখনো লোড হচ্ছে। একটু পরে আবার চেষ্টা করুন।';

  @override
  String get editDiscardTitle => 'পরিবর্তনগুলো বাদ দেবেন?';

  @override
  String get editDiscardBody => 'কিছু পরিবর্তন এখনো সংরক্ষণ করা হয়নি। এখন বেরিয়ে গেলে সেগুলো হারিয়ে যাবে।';

  @override
  String get editKeepEditing => 'সম্পাদনা চালিয়ে যান';

  @override
  String get editDiscard => 'বাদ দিন';

  @override
  String get editProfileUpdated => 'প্রোফাইল হালনাগাদ হয়েছে';

  @override
  String get editPhotoUpdated => 'ছবি হালনাগাদ হয়েছে';

  @override
  String get editUploadingPhoto => 'ছবি আপলোড হচ্ছে…';

  @override
  String get editChangePhoto => 'ছবি বদলান';

  @override
  String get editChangePhotoSemantics => 'প্রোফাইল ছবি বদলান';

  @override
  String get editNameLabel => 'প্রোফাইলে দেখানো নাম';

  @override
  String get editNameHint => 'আপনার নাম লিখুন';

  @override
  String get editNameHelper => 'অন্য পাঠকেরা আপনাকে এই নামেই দেখবেন।';

  @override
  String get editNameRequired => 'অনুগ্রহ করে আপনার নাম লিখুন';

  @override
  String get editNameTooShort => 'নাম কমপক্ষে ২ অক্ষরের হতে হবে';

  @override
  String get editNameTooLong => 'নাম ৫০ অক্ষরের কম হতে হবে';

  @override
  String get editPhotoNotice => 'বই শেয়ার বা বিনিময়ের সময় অন্য ব্যবহারকারীরা আপনার প্রোফাইল ছবি দেখতে পাবেন।';

  @override
  String get editSaving => 'সংরক্ষণ হচ্ছে…';

  @override
  String get editSaveChanges => 'পরিবর্তন সংরক্ষণ করুন';

  @override
  String get settingsTitle => 'সেটিংস';

  @override
  String get settingsGroupPreferences => 'পছন্দ';

  @override
  String get settingsGroupAbout => 'পরিচিতি';

  @override
  String get settingsGroupAccount => 'অ্যাকাউন্ট';

  @override
  String get settingsPrivacyTitle => 'গোপনীয়তা নীতি';

  @override
  String get settingsPrivacySubtitle => 'আমরা কী তথ্য নিই আর কীভাবে ব্যবহার করি';

  @override
  String get settingsTermsTitle => 'শর্তাবলি';

  @override
  String settingsTermsSubtitle(String appName) {
    return '$appName ব্যবহারের নিয়মকানুন';
  }

  @override
  String settingsAboutTitle(String appName) {
    return '$appName সম্পর্কে';
  }

  @override
  String get settingsAboutSubtitle => 'অ্যাপটি কেন, আর আমাদের সঙ্গে যোগাযোগের উপায়';

  @override
  String get settingsAppVersion => 'অ্যাপ ভার্সন';

  @override
  String get settingsSignOut => 'সাইন আউট';

  @override
  String get settingsSignOutSubtitle => 'আপনার বই ও চ্যাট নিরাপদেই থাকবে';

  @override
  String get settingsDeleteAccount => 'অ্যাকাউন্ট মুছে ফেলুন';

  @override
  String get settingsDeleteAccountSubtitle => 'আপনার অ্যাকাউন্ট ও তথ্য স্থায়ীভাবে মুছে ফেলুন';

  @override
  String get settingsSignOutTitle => 'সাইন আউট করবেন?';

  @override
  String get settingsSignOutBody => 'আপনার বই ও মেসেজ দেখতে আবার সাইন ইন করতে হবে।';

  @override
  String get settingsSignedOutSnack => 'আপনি সাইন আউট করেছেন';

  @override
  String get settingsDeleteAccountTitle => 'অ্যাকাউন্ট মুছে ফেলবেন?';

  @override
  String get settingsDeleteAccountBody => 'এই কাজ আর ফেরানো যাবে না। বই, বিনিময়, মেসেজসহ আপনার সব তথ্য স্থায়ীভাবে মুছে যাবে।';

  @override
  String get settingsDeletingAccount => 'আপনার অ্যাকাউন্ট মুছে ফেলা হচ্ছে…';

  @override
  String get settingsAccountDeleted => 'আপনার অ্যাকাউন্ট মুছে ফেলা হয়েছে';

  @override
  String get settingsDeleteNeedsLogin => 'নিরাপত্তার জন্য একবার সাইন আউট করে আবার সাইন ইন করুন, তারপর অ্যাকাউন্ট মুছুন।';

  @override
  String get settingsDeleteFailed => 'আপনার অ্যাকাউন্ট মুছে ফেলা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get aboutTitle => 'পরিচিতি';

  @override
  String aboutVersion(String version) {
    return 'ভার্সন $version';
  }

  @override
  String get aboutMissionLabel => 'আমাদের লক্ষ্য';

  @override
  String aboutMissionBody(String appName) {
    return '$appName পাঠকদের হাতে গড়া একটি প্ল্যাটফর্ম, যেখানে বইপ্রেমীরা একে অপরের সঙ্গে বই বিনিময় ও দান করেন। আমরা চাই জ্ঞান পৌঁছে যাক সবার কাছে, আর পড়ে থাকা বই নতুন পাঠকের হাতে গিয়ে নতুন জীবন পাক—তাতে অপচয়ও কমে।';
  }

  @override
  String get aboutFeaturesLabel => 'যা যা করতে পারবেন';

  @override
  String get aboutFeatureDiscoverTitle => 'কাছেই খুঁজুন';

  @override
  String get aboutFeatureDiscoverBody => 'আপনার এলাকায় বিনিময় বা দানের জন্য রাখা বই খুঁজে নিন';

  @override
  String get aboutFeatureExchangeTitle => 'বিনিময় ও দান';

  @override
  String get aboutFeatureExchangeBody => 'বিনিময় বা দানের মাধ্যমে আপনার বই অন্যদের হাতে তুলে দিন';

  @override
  String get aboutFeatureConnectTitle => 'যুক্ত হোন';

  @override
  String get aboutFeatureConnectBody => 'বইয়ের মালিকদের সঙ্গে চ্যাট করুন, গড়ে তুলুন পাঠকদের একটি পরিবার';

  @override
  String get aboutContactLabel => 'যোগাযোগ';

  @override
  String get aboutEmailUs => 'ইমেইল করুন';

  @override
  String get aboutVisitWebsite => 'আমাদের ওয়েবসাইট দেখুন';

  @override
  String get aboutMadeWith => 'বইপ্রেমীদের জন্য ❤️ দিয়ে তৈরি';

  @override
  String aboutCopyright(String appName) {
    return '© ২০২৪ $appName। সর্বস্বত্ব সংরক্ষিত।';
  }

  @override
  String aboutNoEmailApp(String email) {
    return 'কোনো ইমেইল অ্যাপ পাওয়া যায়নি। আমাদের লিখুন: $email';
  }

  @override
  String aboutCouldNotOpen(String url) {
    return '$url খোলা যায়নি';
  }

  @override
  String get legalLabel => 'আইনি বিষয়';

  @override
  String get legalPrivacyTitle => 'গোপনীয়তা নীতি';

  @override
  String get legalTermsTitle => 'শর্তাবলি';

  @override
  String legalLastUpdated(String date) {
    return 'সর্বশেষ হালনাগাদ: $date';
  }

  @override
  String get legalEnglishOnlyNotice => 'এই নথিটি আপাতত শুধু ইংরেজিতে পাওয়া যাচ্ছে।';
}
