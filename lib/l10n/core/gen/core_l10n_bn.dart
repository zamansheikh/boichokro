// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'core_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class CoreL10nBn extends CoreL10n {
  CoreL10nBn([String locale = 'bn']) : super(locale);

  @override
  String get appName => 'বইচক্র';

  @override
  String get appTagline => 'বই ঘুরুক হাতে হাতে';

  @override
  String get languageBangla => 'বাংলা';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTitle => 'ভাষা';

  @override
  String get languageSubtitle => 'যে ভাষায় পড়তে স্বচ্ছন্দ, সেটি বেছে নিন';

  @override
  String get commonCancel => 'বাতিল';

  @override
  String get commonSave => 'সংরক্ষণ';

  @override
  String get commonDelete => 'মুছুন';

  @override
  String get commonClose => 'বন্ধ করুন';

  @override
  String get commonDone => 'হয়ে গেছে';

  @override
  String get commonOk => 'ঠিক আছে';

  @override
  String get commonRetry => 'আবার চেষ্টা করুন';

  @override
  String get commonRefresh => 'রিফ্রেশ';

  @override
  String get commonBack => 'পেছনে';

  @override
  String get commonContinue => 'এগিয়ে যান';

  @override
  String get commonYes => 'হ্যাঁ';

  @override
  String get commonNo => 'না';

  @override
  String get commonLoading => 'লোড হচ্ছে…';

  @override
  String get commonView => 'দেখুন';

  @override
  String get commonEdit => 'সম্পাদনা';

  @override
  String get commonShare => 'শেয়ার';

  @override
  String get errorGenericTitle => 'কিছু একটা সমস্যা হয়েছে';

  @override
  String get aReader => 'একজন পাঠক';

  @override
  String get newMember => 'নতুন সদস্য';

  @override
  String swapCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countStringটি বিনিময়';
  }

  @override
  String get modeDonate => 'দান';

  @override
  String get modeExchange => 'বিনিময়';

  @override
  String get offerFree => 'বিনামূল্যে';

  @override
  String get offerSwap => 'বিনিময়';

  @override
  String get bookStatusAvailable => 'পাওয়া যাচ্ছে';

  @override
  String get bookStatusRequested => 'অনুরোধ এসেছে';

  @override
  String get bookStatusPending => 'বিনিময় চলছে';

  @override
  String get bookStatusCompleted => 'সম্পন্ন';

  @override
  String get requestStatusPending => 'অপেক্ষমাণ';

  @override
  String get requestStatusAccepted => 'গৃহীত';

  @override
  String get requestStatusDeclined => 'প্রত্যাখ্যাত';

  @override
  String get requestStatusCancelled => 'বাতিল';

  @override
  String get requestStatusCompleted => 'সম্পন্ন';

  @override
  String get exchangeMeetup => 'সরাসরি দেখা করে';

  @override
  String get exchangeCourier => 'কুরিয়ারে';

  @override
  String get conditionLikeNew => 'একদম নতুনের মতো';

  @override
  String get conditionVeryGood => 'খুব ভালো';

  @override
  String get conditionGood => 'ভালো';

  @override
  String get conditionFair => 'মোটামুটি';

  @override
  String get conditionWorn => 'পুরোনো';

  @override
  String get genreFiction => 'কথাসাহিত্য';

  @override
  String get genreNonFiction => 'প্রবন্ধ ও তথ্যমূলক';

  @override
  String get genreScienceFiction => 'বিজ্ঞান কল্পকাহিনি';

  @override
  String get genreFantasy => 'ফ্যান্টাসি';

  @override
  String get genreMystery => 'রহস্য';

  @override
  String get genreThriller => 'থ্রিলার';

  @override
  String get genreRomance => 'রোমান্স';

  @override
  String get genreBiography => 'জীবনী';

  @override
  String get genreHistory => 'ইতিহাস';

  @override
  String get genreSelfHelp => 'আত্মউন্নয়ন';

  @override
  String get genreBusiness => 'ব্যবসা';

  @override
  String get genreScience => 'বিজ্ঞান';

  @override
  String get genrePhilosophy => 'দর্শন';

  @override
  String get genrePoetry => 'কবিতা';

  @override
  String get genreComics => 'কমিকস';

  @override
  String get genreChildren => 'শিশুতোষ';

  @override
  String get genreYoungAdult => 'কিশোর';

  @override
  String get genreOther => 'অন্যান্য';

  @override
  String get timeJustNow => 'এইমাত্র';

  @override
  String timeMinutesAgo(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString মিনিট আগে';
  }

  @override
  String timeHoursAgo(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString ঘণ্টা আগে';
  }

  @override
  String timeDaysAgo(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString দিন আগে';
  }

  @override
  String timeMonthsAgo(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString মাস আগে';
  }

  @override
  String timeYearsAgo(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString বছর আগে';
  }

  @override
  String distanceMeters(int value) {
    final intl.NumberFormat valueNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString মি';
  }

  @override
  String distanceKm(String value) {
    return '$value কিমি';
  }
}
