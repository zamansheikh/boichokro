// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'core_l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class CoreL10nEn extends CoreL10n {
  CoreL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Boichokro';

  @override
  String get appTagline => 'Books that keep moving';

  @override
  String get languageBangla => 'বাংলা';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSubtitle => 'Choose the language you read best';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonClose => 'Close';

  @override
  String get commonDone => 'Done';

  @override
  String get commonOk => 'OK';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonRefresh => 'Refresh';

  @override
  String get commonBack => 'Back';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonView => 'View';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonShare => 'Share';

  @override
  String get errorGenericTitle => 'Something went wrong';

  @override
  String get aReader => 'A reader';

  @override
  String get newMember => 'New member';

  @override
  String swapCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString swaps',
      one: '1 swap',
    );
    return '$_temp0';
  }

  @override
  String get modeDonate => 'Donate';

  @override
  String get modeExchange => 'Exchange';

  @override
  String get offerFree => 'Free';

  @override
  String get offerSwap => 'Swap';

  @override
  String get bookStatusAvailable => 'Available';

  @override
  String get bookStatusRequested => 'Requested';

  @override
  String get bookStatusPending => 'Exchange pending';

  @override
  String get bookStatusCompleted => 'Completed';

  @override
  String get requestStatusPending => 'Pending';

  @override
  String get requestStatusAccepted => 'Accepted';

  @override
  String get requestStatusDeclined => 'Declined';

  @override
  String get requestStatusCancelled => 'Cancelled';

  @override
  String get requestStatusCompleted => 'Completed';

  @override
  String get exchangeMeetup => 'Meet in person';

  @override
  String get exchangeCourier => 'Courier service';

  @override
  String get conditionLikeNew => 'Like New';

  @override
  String get conditionVeryGood => 'Very Good';

  @override
  String get conditionGood => 'Good';

  @override
  String get conditionFair => 'Fair';

  @override
  String get conditionWorn => 'Worn';

  @override
  String get genreFiction => 'Fiction';

  @override
  String get genreNonFiction => 'Non-Fiction';

  @override
  String get genreScienceFiction => 'Science Fiction';

  @override
  String get genreFantasy => 'Fantasy';

  @override
  String get genreMystery => 'Mystery';

  @override
  String get genreThriller => 'Thriller';

  @override
  String get genreRomance => 'Romance';

  @override
  String get genreBiography => 'Biography';

  @override
  String get genreHistory => 'History';

  @override
  String get genreSelfHelp => 'Self-Help';

  @override
  String get genreBusiness => 'Business';

  @override
  String get genreScience => 'Science';

  @override
  String get genrePhilosophy => 'Philosophy';

  @override
  String get genrePoetry => 'Poetry';

  @override
  String get genreComics => 'Comics';

  @override
  String get genreChildren => 'Children';

  @override
  String get genreYoungAdult => 'Young Adult';

  @override
  String get genreOther => 'Other';

  @override
  String get timeJustNow => 'Just now';

  @override
  String timeMinutesAgo(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '${countString}m ago';
  }

  @override
  String timeHoursAgo(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '${countString}h ago';
  }

  @override
  String timeDaysAgo(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '${countString}d ago';
  }

  @override
  String timeMonthsAgo(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '${countString}mo ago';
  }

  @override
  String timeYearsAgo(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '${countString}y ago';
  }

  @override
  String distanceMeters(int value) {
    final intl.NumberFormat valueNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString m';
  }

  @override
  String distanceKm(String value) {
    return '$value km';
  }
}
