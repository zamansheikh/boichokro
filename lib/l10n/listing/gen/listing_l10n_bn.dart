// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'listing_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class ListingL10nBn extends ListingL10n {
  ListingL10nBn([String locale = 'bn']) : super(locale);

  @override
  String get addBookTitle => 'বই যোগ করুন';

  @override
  String get editBookTitle => 'বই সম্পাদনা';

  @override
  String get stepCoverLabel => 'কভার';

  @override
  String get stepDetailsLabel => 'বিবরণ';

  @override
  String get stepSharingLabel => 'শেয়ার';

  @override
  String stepProgress(int step, int total) {
    final intl.NumberFormat stepNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String stepString = stepNumberFormat.format(step);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'ধাপ $stepString/$totalString';
  }

  @override
  String stepSemantics(int step, int total, String label) {
    final intl.NumberFormat stepNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String stepString = stepNumberFormat.format(step);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$totalStringটি ধাপের মধ্যে $stepString নম্বর ধাপ, $label';
  }

  @override
  String get stepCoverTitle => 'কভার দিয়ে শুরু করুন';

  @override
  String get stepCoverSubtitle =>
      'সামনের কভারের একটি পরিষ্কার ছবি থাকলে পাঠকেরা সহজে বইটি চিনতে পারেন।';

  @override
  String get stepDetailsTitle => 'পাঠকদের বইটির কথা জানান';

  @override
  String get stepDetailsSubtitle =>
      'এগিয়ে যেতে শুধু বইয়ের নাম আর লেখকের নাম দিলেই হবে।';

  @override
  String get stepSharingTitle => 'বইটি কীভাবে দিতে চান?';

  @override
  String get stepSharingSubtitle =>
      'বিনিময়ে কী চান আর কোথায় দেখা করবেন, তা বেছে নিন।';

  @override
  String get actionSnapCover => 'কভারের ছবি তুলুন';

  @override
  String get actionRetakePhoto => 'আবার ছবি তুলুন';

  @override
  String get actionChooseFromGallery => 'গ্যালারি থেকে বেছে নিন';

  @override
  String get actionShareBook => 'বইটি শেয়ার করুন';

  @override
  String get actionSaveChanges => 'পরিবর্তন সংরক্ষণ করুন';

  @override
  String get loadingSharingBook => 'আপনার বই শেয়ার হচ্ছে…';

  @override
  String get loadingSaving => 'সংরক্ষণ হচ্ছে…';

  @override
  String get coverDropHint => 'বইয়ের সামনের দিক, ভালো আলোয়';

  @override
  String get coverReading => 'কভার পড়া হচ্ছে…';

  @override
  String get coverRequired => 'কভারের একটি ছবি আবশ্যক';

  @override
  String get snackCoverRequired => 'এগিয়ে যেতে কভারের একটি ছবি যোগ করুন';

  @override
  String get errorCameraOpen =>
      'ক্যামেরা খোলা যায়নি। ক্যামেরার অনুমতি দেখে নিয়ে আবার চেষ্টা করুন।';

  @override
  String get errorGalleryOpen =>
      'গ্যালারি খোলা যায়নি। ছবির অনুমতি দেখে নিয়ে আবার চেষ্টা করুন।';

  @override
  String get scanIsbnFoundTitle => 'ISBN নিজে থেকেই বসে গেছে';

  @override
  String scanIsbnFoundMessage(String isbn) {
    return 'ছবি থেকে আমরা $isbn পেয়েছি। পরের ধাপে মিলিয়ে নিতে পারবেন।';
  }

  @override
  String get scanInProgress => 'ছবিতে ISBN খোঁজা হচ্ছে…';

  @override
  String get scanNotFound =>
      'এই ছবিতে কোনো ISBN পাওয়া যায়নি। পরের ধাপে নিজে লিখে দিতে পারেন, না দিলেও চলবে।';

  @override
  String get scanHint =>
      'ক্যামেরা দিয়ে ছবি তুললে আমরা তাতে ISBN খুঁজে নিয়ে আপনার হয়ে বসিয়ে দিই।';

  @override
  String get detailsHeading => 'বিবরণ';

  @override
  String get fieldTitleLabel => 'বইয়ের নাম';

  @override
  String get fieldTitleHint => 'কভারে যেমন ছাপা আছে';

  @override
  String get validationTitleRequired => 'বইয়ের নাম লিখুন';

  @override
  String get validationTitleTooLong => 'বইয়ের নাম অনেক বড় হয়ে গেছে';

  @override
  String get fieldAuthorLabel => 'লেখক';

  @override
  String get fieldAuthorHint => 'বইটি কার লেখা?';

  @override
  String get validationAuthorRequired => 'লেখকের নাম লিখুন';

  @override
  String get fieldIsbnLabel => 'ISBN (ঐচ্ছিক)';

  @override
  String get fieldIsbnHint => 'বারকোডের ওপরের নম্বরটি';

  @override
  String get fieldDescriptionLabel => 'বিবরণ (ঐচ্ছিক)';

  @override
  String get fieldDescriptionHint =>
      'বইটি কী নিয়ে? কোনো নোট, দাগ বা হারানো পাতা আছে?';

  @override
  String get conditionHeading => 'বইয়ের অবস্থা';

  @override
  String get conditionHint => 'সত্যিটাই বলুন, এতে আস্থা বাড়ে।';

  @override
  String get conditionLikeNewExplanation =>
      'না-পড়া বইয়ের মতো, কোনো দাগ বা ভাঁজ নেই।';

  @override
  String get conditionVeryGoodExplanation =>
      'যত্ন করে পড়া। পাতা পরিষ্কার, ব্যবহারের ছাপ প্রায় নেই।';

  @override
  String get conditionGoodExplanation =>
      'যত্নে রাখা বই, ব্যবহারের হালকা ছাপ আছে।';

  @override
  String get conditionFairExplanation =>
      'ব্যবহারের ছাপ স্পষ্ট, অথবা কিছু নোট ও হাইলাইট আছে।';

  @override
  String get conditionWornExplanation => 'অনেক ব্যবহৃত, তবে এখনো পড়া যায়।';

  @override
  String get genresHeading => 'ধরন';

  @override
  String get genresHint =>
      'যেগুলো মেলে বেছে নিন, তাতে পাঠকেরা সহজে খুঁজে পাবেন।';

  @override
  String get genresOptional => 'ঐচ্ছিক';

  @override
  String genresSelected(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countStringটি নির্বাচিত';
  }

  @override
  String get modeDonateTitle => 'দান করুন';

  @override
  String get modeDonateDescription => 'যে পাঠক চাইবেন, তিনিই বিনামূল্যে পাবেন।';

  @override
  String get modeExchangeTitle => 'অন্য বইয়ের সঙ্গে বিনিময়';

  @override
  String get modeExchangeDescription => 'পাঠকেরা বদলে তাঁদের একটি বই দেবেন।';

  @override
  String get sharingHeading => 'যেভাবে দিতে চান';

  @override
  String get sharingHint => 'বিনিময়ে কী চান, তা বেছে নিন।';

  @override
  String get pickupHeading => 'সংগ্রহের স্থান';

  @override
  String get pickupHint => 'যেখান থেকে পাঠকেরা বইটি নিতে পারবেন।';

  @override
  String get pickupEmptyTitle => 'একটি জায়গা বেছে নিন';

  @override
  String get pickupEmptySubtitle =>
      'খুঁজুন, ম্যাপে ট্যাপ করুন অথবা আপনার বর্তমান লোকেশন ব্যবহার করুন।';

  @override
  String get pickupChange => 'বদলান';

  @override
  String get pickupRequired => 'সংগ্রহের স্থান আবশ্যক';

  @override
  String get snackPickupRequired => 'এগিয়ে যেতে সংগ্রহের স্থান বেছে নিন';

  @override
  String get pickupPublicPlaceTip =>
      'কাছাকাছি পাঠকেরা ম্যাপে এই জায়গাটি দেখতে পাবেন, তাই ক্যাম্পাসের গেট বা ক্যাফের মতো পাবলিক জায়গা বেছে নেওয়াই ভালো।';

  @override
  String get snackBookAdded =>
      'আপনার বইটি এখন কাছাকাছি পাঠকদের জন্য তাকে সাজানো আছে';

  @override
  String get snackChangesSaved => 'আপনার পরিবর্তন সংরক্ষিত হয়েছে';

  @override
  String get discardNewTitle => 'বইটি বাদ দেবেন?';

  @override
  String get discardNewMessage => 'আপনার যোগ করা ছবি ও তথ্য সংরক্ষিত হবে না।';

  @override
  String get discardEditTitle => 'পরিবর্তনগুলো বাদ দেবেন?';

  @override
  String get discardEditMessage => 'এই বইয়ে করা পরিবর্তনগুলো সংরক্ষিত হবে না।';

  @override
  String get discardKeepEditing => 'সম্পাদনা চালিয়ে যান';

  @override
  String get discardConfirm => 'বাদ দিন';

  @override
  String get editingEyebrow => 'সম্পাদনা চলছে';

  @override
  String get editSummaryNote => 'কভারের ছবি ও সংগ্রহের স্থান আগের মতোই থাকবে।';

  @override
  String get locationDisclosureTitle => 'লোকেশন ব্যবহারের অনুমতি প্রয়োজন';

  @override
  String get locationDisclosureMessage =>
      'আপনি যে বই আপলোড করেন তার সংগ্রহের স্থান নির্ধারণের জন্য আপনার বর্তমান ঠিকানা নির্ভুলভাবে চিহ্নিত করতে, অথবা কাছাকাছি কোনো বই খুঁজে পেতে বইচক্রের আপনার লোকেশন প্রয়োজন।';

  @override
  String get locationDisclosureDeny => 'অনুমতি দেব না';

  @override
  String get locationDisclosureAccept => 'রাজি আছি';

  @override
  String get errorLocationUnavailable =>
      'আপনার লোকেশন পাওয়া যায়নি। আবার চেষ্টা করুন, অথবা ম্যাপে জায়গাটি বেছে নিন।';

  @override
  String get snackAddressNotFound => 'ঠিকানাটি পাওয়া যায়নি';

  @override
  String get errorAddressSearch =>
      'ঠিকানাটি খুঁজে পাওয়া যায়নি। অন্যভাবে খুঁজে দেখুন অথবা ম্যাপে জায়গাটিতে ট্যাপ করুন।';

  @override
  String get actionUseThisLocation => 'এই লোকেশন ব্যবহার করুন';

  @override
  String get searchHint => 'এলাকা, রাস্তা বা পরিচিত স্থান খুঁজুন';

  @override
  String get searchTooltip => 'খুঁজুন';

  @override
  String get mapTapHint => 'পিন বসাতে ম্যাপে ট্যাপ করুন';

  @override
  String get tooltipUseCurrentLocation => 'আমার বর্তমান লোকেশন ব্যবহার করুন';

  @override
  String get issueDeniedTitle => 'লোকেশনের অনুমতি বন্ধ আছে';

  @override
  String get issueDeniedMessage =>
      'সমস্যা নেই। ঠিকানা খুঁজে নিন অথবা ম্যাপে ট্যাপ করে নিজেই পিন বসান।';

  @override
  String get issueBlockedTitle => 'লোকেশনের অনুমতি ব্লক করা আছে';

  @override
  String get issueBlockedMessage =>
      'ফোনের সেটিংসে গিয়ে বইচক্রকে লোকেশনের অনুমতি দিন, অথবা ঠিকানা খুঁজে ম্যাপে ট্যাপ করুন।';

  @override
  String get actionOpenSettings => 'সেটিংস খুলুন';

  @override
  String get issueServiceOffTitle => 'লোকেশন বন্ধ আছে';

  @override
  String get issueServiceOffMessage =>
      'ফোনের লোকেশন চালু করে আবার চেষ্টা করুন, অথবা ঠিকানা খুঁজে ম্যাপে ট্যাপ করুন।';

  @override
  String get actionOpenLocationSettings => 'লোকেশন সেটিংস খুলুন';

  @override
  String get noSpotTitle => 'এখনো কোনো জায়গা বাছা হয়নি';

  @override
  String get noSpotSubtitle => 'পাঠকেরা কোথা থেকে বইটি নেবেন, তা বেছে নিন।';

  @override
  String get actionLocateMe => 'আমার লোকেশন';

  @override
  String get selectedSpotEyebrow => 'নির্বাচিত জায়গা';

  @override
  String get pinnedSpotNoAddress =>
      'পিন করা জায়গা (রাস্তার ঠিকানা পাওয়া যায়নি)';
}
