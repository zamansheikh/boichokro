import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../features/discover/domain/entities/book.dart';
import '../../features/library/domain/entities/request.dart';
import '../../l10n/core/gen/core_l10n.dart';
import '../utils/constants.dart';

export '../../l10n/core/gen/core_l10n.dart';
export 'locale_controller.dart';

/// `context.core` gives the strings shared by every feature (common actions,
/// statuses, conditions, genres, relative time).
extension CoreL10nContext on BuildContext {
  CoreL10n get core => CoreL10n.of(this);

  /// A number in the reader's digits, e.g. 12 → ১২ in Bangla.
  String number(num value) {
    return NumberFormat.decimalPattern(core.localeName).format(value);
  }

  /// A date in the reader's language, e.g. `context.date(d, 'MMM d, yyyy')`.
  String date(DateTime value, String pattern) {
    return DateFormat(pattern, core.localeName).format(value);
  }

  /// "Just now", "5m ago", "3d ago" in the reader's language.
  String relativeTime(DateTime value) {
    final difference = DateTime.now().difference(value);
    if (difference.inDays > 365) {
      return core.timeYearsAgo((difference.inDays / 365).floor());
    } else if (difference.inDays > 30) {
      return core.timeMonthsAgo((difference.inDays / 30).floor());
    } else if (difference.inDays > 0) {
      return core.timeDaysAgo(difference.inDays);
    } else if (difference.inHours > 0) {
      return core.timeHoursAgo(difference.inHours);
    } else if (difference.inMinutes > 0) {
      return core.timeMinutesAgo(difference.inMinutes);
    }
    return core.timeJustNow;
  }

  /// "850 m" / "2.4 km" from a distance in metres.
  String distance(double meters) {
    if (meters < 1000) return core.distanceMeters(meters.round());
    final km = meters / 1000;
    return core.distanceKm(
      number(km >= 10 ? km.round() : (km * 10).round() / 10),
    );
  }

  /// Label for a stored condition index, 0 (Like New) to 4 (Worn).
  String conditionLabel(int index) {
    final l = core;
    final labels = [
      l.conditionLikeNew,
      l.conditionVeryGood,
      l.conditionGood,
      l.conditionFair,
      l.conditionWorn,
    ];
    return labels[index.clamp(0, labels.length - 1)];
  }

  /// Label for a genre. Genres are stored in English ([AppConstants.bookGenres]);
  /// anything unknown is shown as stored.
  String genreLabel(String stored) {
    final l = core;
    switch (stored) {
      case 'Fiction':
        return l.genreFiction;
      case 'Non-Fiction':
        return l.genreNonFiction;
      case 'Science Fiction':
        return l.genreScienceFiction;
      case 'Fantasy':
        return l.genreFantasy;
      case 'Mystery':
        return l.genreMystery;
      case 'Thriller':
        return l.genreThriller;
      case 'Romance':
        return l.genreRomance;
      case 'Biography':
        return l.genreBiography;
      case 'History':
        return l.genreHistory;
      case 'Self-Help':
        return l.genreSelfHelp;
      case 'Business':
        return l.genreBusiness;
      case 'Science':
        return l.genreScience;
      case 'Philosophy':
        return l.genrePhilosophy;
      case 'Poetry':
        return l.genrePoetry;
      case 'Comics':
        return l.genreComics;
      case 'Children':
        return l.genreChildren;
      case 'Young Adult':
        return l.genreYoungAdult;
      case 'Other':
        return l.genreOther;
    }
    return stored;
  }
}

extension BookModeL10n on BookMode {
  /// "Donate" / "Exchange".
  String label(BuildContext context) => this == BookMode.donate
      ? context.core.modeDonate
      : context.core.modeExchange;

  /// Short reader-facing form: "Free" / "Swap".
  String offer(BuildContext context) =>
      this == BookMode.donate ? context.core.offerFree : context.core.offerSwap;
}

extension BookStatusL10n on BookStatus {
  String label(BuildContext context) {
    final l = context.core;
    switch (this) {
      case BookStatus.available:
        return l.bookStatusAvailable;
      case BookStatus.requested:
        return l.bookStatusRequested;
      case BookStatus.pending:
        return l.bookStatusPending;
      case BookStatus.completed:
        return l.bookStatusCompleted;
    }
  }
}

extension RequestStatusL10n on RequestStatus {
  String label(BuildContext context) {
    final l = context.core;
    switch (this) {
      case RequestStatus.pending:
        return l.requestStatusPending;
      case RequestStatus.accepted:
        return l.requestStatusAccepted;
      case RequestStatus.declined:
        return l.requestStatusDeclined;
      case RequestStatus.cancelled:
        return l.requestStatusCancelled;
      case RequestStatus.completed:
        return l.requestStatusCompleted;
    }
  }
}

extension ExchangeMethodL10n on ExchangeMethod {
  String label(BuildContext context) => this == ExchangeMethod.meetup
      ? context.core.exchangeMeetup
      : context.core.exchangeCourier;
}
