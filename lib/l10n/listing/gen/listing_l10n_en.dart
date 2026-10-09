// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'listing_l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class ListingL10nEn extends ListingL10n {
  ListingL10nEn([String locale = 'en']) : super(locale);

  @override
  String get addBookTitle => 'Add a book';

  @override
  String get editBookTitle => 'Edit book';

  @override
  String get stepCoverLabel => 'Cover';

  @override
  String get stepDetailsLabel => 'Details';

  @override
  String get stepSharingLabel => 'Sharing';

  @override
  String stepProgress(int step, int total) {
    final intl.NumberFormat stepNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String stepString = stepNumberFormat.format(step);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Step $stepString of $totalString';
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

    return 'Step $stepString of $totalString, $label';
  }

  @override
  String get stepCoverTitle => 'Start with the cover';

  @override
  String get stepCoverSubtitle =>
      'A clear photo of the front helps readers recognise the book.';

  @override
  String get stepDetailsTitle => 'Tell readers about it';

  @override
  String get stepDetailsSubtitle =>
      'The title and author are all you need to continue.';

  @override
  String get stepSharingTitle => 'How will you share it?';

  @override
  String get stepSharingSubtitle =>
      'Choose what you would like in return, and where to meet.';

  @override
  String get actionSnapCover => 'Snap the cover';

  @override
  String get actionRetakePhoto => 'Retake photo';

  @override
  String get actionChooseFromGallery => 'Choose from gallery';

  @override
  String get actionShareBook => 'Share this book';

  @override
  String get actionSaveChanges => 'Save changes';

  @override
  String get loadingSharingBook => 'Sharing your book…';

  @override
  String get loadingSaving => 'Saving…';

  @override
  String get coverDropHint => 'Front of the book, in good light';

  @override
  String get coverReading => 'Reading the cover…';

  @override
  String get coverRequired => 'A cover photo is required';

  @override
  String get snackCoverRequired => 'Add a photo of the cover to continue';

  @override
  String get errorCameraOpen =>
      'We couldn\'t open the camera. Check the camera permission and try again.';

  @override
  String get errorGalleryOpen =>
      'We couldn\'t open your gallery. Check the photos permission and try again.';

  @override
  String get scanIsbnFoundTitle => 'ISBN filled in for you';

  @override
  String scanIsbnFoundMessage(String isbn) {
    return 'We read $isbn from the photo. You can check it next.';
  }

  @override
  String get scanInProgress => 'Reading the photo for an ISBN…';

  @override
  String get scanNotFound =>
      'No ISBN spotted in this photo. You can type it in on the next step, or leave it out.';

  @override
  String get scanHint =>
      'When you take the photo with the camera, we look for an ISBN in it and fill it in for you.';

  @override
  String get detailsHeading => 'Details';

  @override
  String get fieldTitleLabel => 'Title';

  @override
  String get fieldTitleHint => 'As printed on the cover';

  @override
  String get validationTitleRequired => 'Please enter a title';

  @override
  String get validationTitleTooLong => 'Title is too long';

  @override
  String get fieldAuthorLabel => 'Author';

  @override
  String get fieldAuthorHint => 'Who wrote it?';

  @override
  String get validationAuthorRequired => 'Please enter the author\'s name';

  @override
  String get fieldIsbnLabel => 'ISBN (optional)';

  @override
  String get fieldIsbnHint => 'The number above the barcode';

  @override
  String get fieldDescriptionLabel => 'Description (optional)';

  @override
  String get fieldDescriptionHint =>
      'What is it about? Any notes, marks or missing pages?';

  @override
  String get conditionHeading => 'Condition';

  @override
  String get conditionHint => 'Be honest, it builds trust.';

  @override
  String get conditionLikeNewExplanation =>
      'Looks unread, with no marks or creases.';

  @override
  String get conditionVeryGoodExplanation =>
      'Read gently. Clean pages, barely any wear.';

  @override
  String get conditionGoodExplanation => 'A well-kept copy with light wear.';

  @override
  String get conditionFairExplanation =>
      'Clear wear, or some notes and highlights.';

  @override
  String get conditionWornExplanation => 'Heavily used, but still readable.';

  @override
  String get genresHeading => 'Genres';

  @override
  String get genresHint => 'Pick any that fit, so readers can find it.';

  @override
  String get genresOptional => 'Optional';

  @override
  String genresSelected(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString selected';
  }

  @override
  String get modeDonateTitle => 'Give it away';

  @override
  String get modeDonateDescription => 'Free for any reader who asks for it.';

  @override
  String get modeExchangeTitle => 'Swap for another book';

  @override
  String get modeExchangeDescription =>
      'Readers offer one of their books in return.';

  @override
  String get sharingHeading => 'How you share it';

  @override
  String get sharingHint => 'Choose what you would like in return.';

  @override
  String get pickupHeading => 'Pickup location';

  @override
  String get pickupHint => 'Where readers can collect the book.';

  @override
  String get pickupEmptyTitle => 'Choose a spot';

  @override
  String get pickupEmptySubtitle =>
      'Search, tap the map or use your current location.';

  @override
  String get pickupChange => 'Change';

  @override
  String get pickupRequired => 'A pickup location is required';

  @override
  String get snackPickupRequired => 'Choose a pickup location to continue';

  @override
  String get pickupPublicPlaceTip =>
      'Nearby readers see this spot on the map, so a public place such as a campus gate or a café works well.';

  @override
  String get snackBookAdded => 'Your book is on the shelf for nearby readers';

  @override
  String get snackChangesSaved => 'Your changes are saved';

  @override
  String get discardNewTitle => 'Discard this book?';

  @override
  String get discardNewMessage =>
      'The photo and details you added won\'t be saved.';

  @override
  String get discardEditTitle => 'Discard your changes?';

  @override
  String get discardEditMessage =>
      'The edits you made to this book won\'t be saved.';

  @override
  String get discardKeepEditing => 'Keep editing';

  @override
  String get discardConfirm => 'Discard';

  @override
  String get editingEyebrow => 'Editing';

  @override
  String get editSummaryNote =>
      'The cover photo and pickup location stay as they are.';

  @override
  String get locationDisclosureTitle => 'Location access required';

  @override
  String get locationDisclosureMessage =>
      'Boichokro needs your location to help you pinpoint your current address for assigning a pickup location to a book you upload, or finding a nearby book.';

  @override
  String get locationDisclosureDeny => 'Deny';

  @override
  String get locationDisclosureAccept => 'Accept';

  @override
  String get errorLocationUnavailable =>
      'We couldn\'t get your location. Please try again, or pick the spot on the map.';

  @override
  String get snackAddressNotFound => 'Address not found';

  @override
  String get errorAddressSearch =>
      'Could not find that address. Try a different search or tap the spot on the map.';

  @override
  String get actionUseThisLocation => 'Use this location';

  @override
  String get searchHint => 'Search an area, road or landmark';

  @override
  String get searchTooltip => 'Search';

  @override
  String get mapTapHint => 'Tap the map to place the pin';

  @override
  String get tooltipUseCurrentLocation => 'Use my current location';

  @override
  String get issueDeniedTitle => 'Location access is off';

  @override
  String get issueDeniedMessage =>
      'No problem. Search for an address or tap the map to place the pin yourself.';

  @override
  String get issueBlockedTitle => 'Location access is blocked';

  @override
  String get issueBlockedMessage =>
      'Allow location for Boichokro in your phone settings, or search and tap the map instead.';

  @override
  String get actionOpenSettings => 'Open settings';

  @override
  String get issueServiceOffTitle => 'Location is turned off';

  @override
  String get issueServiceOffMessage =>
      'Turn on location on your phone and try again, or search and tap the map instead.';

  @override
  String get actionOpenLocationSettings => 'Open location settings';

  @override
  String get noSpotTitle => 'No spot chosen yet';

  @override
  String get noSpotSubtitle => 'Pick where readers can collect the book.';

  @override
  String get actionLocateMe => 'Locate me';

  @override
  String get selectedSpotEyebrow => 'Selected spot';

  @override
  String get pinnedSpotNoAddress => 'Pinned spot (no street address found)';
}
