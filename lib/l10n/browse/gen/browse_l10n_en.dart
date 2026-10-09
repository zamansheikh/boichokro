// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'browse_l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class BrowseL10nEn extends BrowseL10n {
  BrowseL10nEn([String locale = 'en']) : super(locale);

  @override
  String get navDiscover => 'Discover';

  @override
  String get navLibrary => 'Library';

  @override
  String get navChats => 'Chats';

  @override
  String get navProfile => 'Profile';

  @override
  String get shareABook => 'Share a book';

  @override
  String get notFoundTitle => 'This page is not here';

  @override
  String get notFoundMessage => 'The link may be old or the book may have moved on.';

  @override
  String get notFoundAction => 'Back to Discover';

  @override
  String get discoverEyebrowNearby => 'Books near you';

  @override
  String get discoverEyebrowCircle => 'Books in the circle';

  @override
  String get discoverTitle => 'Find your next read';

  @override
  String get searchHint => 'Title, author or genre';

  @override
  String get searchClear => 'Clear search';

  @override
  String get filtersTitle => 'Filters';

  @override
  String get filterAll => 'All';

  @override
  String filterWithinKm(int km) {
    final intl.NumberFormat kmNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String kmString = kmNumberFormat.format(km);

    return 'Within $kmString km';
  }

  @override
  String get filterAvailableNow => 'Available now';

  @override
  String conditionOrBetter(String condition) {
    return '$condition or better';
  }

  @override
  String get loadErrorTitle => 'Could not load books';

  @override
  String resultCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString books',
      one: '1 book',
    );
    return '$_temp0';
  }

  @override
  String get resultSortNearest => 'nearest first';

  @override
  String get resultSortAround => 'from readers around you';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get emptyTitle => 'No books here yet';

  @override
  String get emptyMessage => 'Be the first to put a book into the circle. Someone nearby is probably looking for it.';

  @override
  String get noResultsTitle => 'No books match';

  @override
  String noResultsNearby(int km) {
    final intl.NumberFormat kmNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String kmString = kmNumberFormat.format(km);

    return 'Nothing within $kmString km right now. Try a wider search or fewer filters.';
  }

  @override
  String get noResultsGeneric => 'Try a different title or author, or loosen the filters.';

  @override
  String get statusShortReserved => 'Reserved';

  @override
  String get statusShortGone => 'Gone';

  @override
  String get mapLoading => 'Finding books around you';

  @override
  String mapBookCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString books on the map',
      one: '1 book on the map',
      zero: 'No books match here',
    );
    return '$_temp0';
  }

  @override
  String get mapMyLocation => 'My location';

  @override
  String get mapNothingMatches => 'Nothing matches your search and filters.';

  @override
  String get mapClear => 'Clear';

  @override
  String get previewTitle => 'On the map';

  @override
  String get previewViewBook => 'View this book';

  @override
  String distanceAway(String distance) {
    return '$distance away';
  }

  @override
  String get locationServicesOff => 'Turn on location services to see nearby books.';

  @override
  String get locationDialogTitle => 'Location Access Required';

  @override
  String locationDialogBody(String appName) {
    return '$appName needs your location to find and display nearby books available for exchange. Your location is only used locally to calculate distance and is not continuously tracked.';
  }

  @override
  String get locationDeny => 'Deny';

  @override
  String get locationAccept => 'Accept';

  @override
  String get locationPermissionNeeded => 'Location permission is needed to show books near you.';

  @override
  String get locationOpenSettings => 'Settings';

  @override
  String get locationFailed => 'Could not determine your location. Please try again.';

  @override
  String get viewList => 'List view';

  @override
  String get viewMap => 'Map view';

  @override
  String get filterSheetSubtitle => 'Narrow down the books you see';

  @override
  String get filterSheetReset => 'Reset';

  @override
  String filterSheetApply(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Show $countString books',
      one: 'Show 1 book',
      zero: 'No books match',
    );
    return '$_temp0';
  }

  @override
  String get filterSectionMode => 'How it is shared';

  @override
  String get filterFreeToTake => 'Free to take';

  @override
  String get filterSectionGenre => 'Genre';

  @override
  String get filterAnyGenre => 'Any genre';

  @override
  String get filterSectionCondition => 'Condition';

  @override
  String get filterAnyCondition => 'Any condition';

  @override
  String filterNearMe(int km) {
    final intl.NumberFormat kmNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String kmString = kmNumberFormat.format(km);

    return 'Within $kmString km of me';
  }

  @override
  String get filterLocating => 'Finding your location…';

  @override
  String get filterNearMeHint => 'Uses your location only to measure distance';

  @override
  String get filterAvailableHint => 'Hide books that are already requested';
}
