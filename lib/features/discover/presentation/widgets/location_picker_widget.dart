import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/design/design.dart';
import '../../../../l10n/listing/gen/listing_l10n.dart';

const String _tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const String _tileUserAgent = 'com.example.boichokro';

/// Formats a coordinate pair for display when no street address is known.
String formatLatLng(LatLng location) =>
    '${location.latitude.toStringAsFixed(6)}, '
    '${location.longitude.toStringAsFixed(6)}';

/// Full-screen picker: search for an address, tap the map or use the device
/// location, then confirm. Reports the result through [onLocationSelected].
class LocationPickerWidget extends StatefulWidget {
  final LatLng? initialLocation;
  final String? initialAddress;
  final Function(LatLng location, String address) onLocationSelected;

  const LocationPickerWidget({
    super.key,
    this.initialLocation,
    this.initialAddress,
    required this.onLocationSelected,
  });

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

/// Why the device location could not be used.
enum _LocationIssue { denied, deniedForever, serviceOff }

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  late MapController _mapController;
  LatLng? _selectedLocation;
  String _selectedAddress = '';
  bool _isLocating = false;
  bool _isSearching = false;
  bool _isResolving = false;
  int _resolveRequest = 0;
  _LocationIssue? _issue;
  final TextEditingController _searchController = TextEditingController();
  final geo.Geocoding _geocoding = geo.Geocoding();

  bool get _isBusy => _isLocating || _isSearching || _isResolving;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedLocation = widget.initialLocation;
    _selectedAddress = widget.initialAddress ?? '';
    if (widget.initialAddress != null) {
      _searchController.text = widget.initialAddress!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    if (_isLocating) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _isLocating = true;
      _issue = null;
    });

    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;

        // Prominent disclosure for Google Play policy compliance: shown
        // before the system permission prompt.
        final bool? shouldRequest = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            final l = ListingL10n.of(dialogContext);
            return AlertDialog(
              icon: const Icon(LucideIcons.mapPin),
              title: Text(l.locationDisclosureTitle),
              content: Text(l.locationDisclosureMessage),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(l.locationDisclosureDeny),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(l.locationDisclosureAccept),
                ),
              ],
            );
          },
        );

        if (shouldRequest != true) {
          _showIssue(_LocationIssue.denied);
          return;
        }

        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showIssue(_LocationIssue.denied);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showIssue(_LocationIssue.deniedForever);
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final location = LatLng(position.latitude, position.longitude);
      await _updateLocation(location);
      if (!mounted) return;

      // Animate to location
      _mapController.move(location, 15.0);
    } on LocationServiceDisabledException {
      _showIssue(_LocationIssue.serviceOff);
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (mounted) {
        showAppSnack(
          context,
          ListingL10n.of(context).errorLocationUnavailable,
          tone: AppTone.danger,
        );
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _showIssue(_LocationIssue issue) {
    if (!mounted) return;
    setState(() => _issue = issue);
  }

  Future<void> _searchAddress() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSearching = true);

    try {
      final locations = await _geocoding.locationFromAddress(query);
      if (locations.isNotEmpty) {
        final location = LatLng(
          locations.first.latitude,
          locations.first.longitude,
        );
        await _updateLocation(location);
        if (!mounted) return;
        _mapController.move(location, 15.0);
      } else {
        if (mounted) {
          showAppSnack(
            context,
            ListingL10n.of(context).snackAddressNotFound,
            tone: AppTone.warning,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showAppSnack(
          context,
          ListingL10n.of(context).errorAddressSearch,
          tone: AppTone.warning,
        );
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _updateLocation(LatLng location) async {
    // Only the most recent request may write its result.
    final request = ++_resolveRequest;
    setState(() {
      _selectedLocation = location;
      _isResolving = true;
    });

    try {
      // Reverse geocode to get address
      final placemarks = await _geocoding.placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (!mounted || request != _resolveRequest) return;

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.country,
        ].where((e) => e != null && e.isNotEmpty).join(', ');

        setState(() {
          _selectedAddress = address;
          _searchController.text = address;
        });
      }
    } catch (e) {
      debugPrint('Error reverse geocoding: $e');
    } finally {
      if (mounted && request == _resolveRequest) {
        setState(() => _isResolving = false);
      }
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng location) {
    FocusScope.of(context).unfocus();
    _updateLocation(location);
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      widget.onLocationSelected(_selectedLocation!, _selectedAddress);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final l = ListingL10n.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.pickupHeading)),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.xs,
                AppSpacing.page,
                AppSpacing.md,
              ),
              child: _buildSearchField(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.page,
                ),
                child: _buildMap(context),
              ),
            ),
            if (!keyboardOpen)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.md,
                  AppSpacing.page,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_issue != null) ...[
                      _buildIssueBanner(_issue!),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    _buildAddressCard(context),
                  ],
                ),
              )
            else
              const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: context.colors.outlineVariant)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.md,
              AppSpacing.page,
              AppSpacing.md,
            ),
            child: FilledButton.icon(
              onPressed: _selectedLocation == null ? null : _confirmLocation,
              icon: const Icon(LucideIcons.check, size: 18),
              label: Text(l.actionUseThisLocation),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    final l = ListingL10n.of(context);
    return TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      keyboardType: TextInputType.streetAddress,
      textCapitalization: TextCapitalization.words,
      onSubmitted: (_) => _searchAddress(),
      decoration: InputDecoration(
        hintText: l.searchHint,
        prefixIcon: const Icon(LucideIcons.search, size: 20),
        suffixIcon: _isSearching
            ? const Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : IconButton(
                onPressed: _searchAddress,
                tooltip: l.searchTooltip,
                icon: const Icon(LucideIcons.arrowRight, size: 20),
              ),
      ),
    );
  }

  Widget _buildMap(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.xl);
    final l = ListingL10n.of(context);

    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            Positioned.fill(
              child: ColoredBox(
                color: context.colors.surfaceContainerHighest,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter:
                        _selectedLocation ??
                        const LatLng(23.8103, 90.4125), // Dhaka
                    initialZoom: _selectedLocation != null ? 15.0 : 12.0,
                    onTap: _onMapTap,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: _tileUrl,
                      userAgentPackageName: _tileUserAgent,
                    ),
                    if (_selectedLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _selectedLocation!,
                            width: LocationMapPin.width,
                            height: LocationMapPin.height,
                            alignment: Alignment.topCenter,
                            child: const LocationMapPin(),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            // Progress
            if (_isBusy)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(minHeight: 3),
              ),

            // Hint
            if (_selectedLocation == null)
              Positioned(
                top: AppSpacing.md,
                left: AppSpacing.md,
                right: AppSpacing.md,
                child: Center(
                  child: IgnorePointer(
                    child: _MapLabel(
                      icon: LucideIcons.mapPin,
                      label: l.mapTapHint,
                      style: context.text.labelMedium,
                    ),
                  ),
                ),
              ),

            // Attribution
            Positioned(
              left: AppSpacing.sm,
              bottom: AppSpacing.sm,
              child: IgnorePointer(
                child: _MapLabel(
                  label: '© OpenStreetMap contributors',
                  style: context.text.labelSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  dense: true,
                ),
              ),
            ),

            // Current location button
            Positioned(
              right: AppSpacing.md,
              bottom: AppSpacing.md,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: context.softShadow,
                ),
                child: _isLocating
                    ? Container(
                        width: 48,
                        height: 48,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: context.colors.outlineVariant,
                          ),
                        ),
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : CircleIconButton(
                        icon: LucideIcons.locateFixed,
                        tooltip: l.tooltipUseCurrentLocation,
                        size: 48,
                        onPressed: _getCurrentLocation,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIssueBanner(_LocationIssue issue) {
    final l = ListingL10n.of(context);
    switch (issue) {
      case _LocationIssue.denied:
        return AppBanner(
          tone: AppTone.warning,
          icon: LucideIcons.mapPinOff,
          title: l.issueDeniedTitle,
          message: l.issueDeniedMessage,
          actionLabel: context.core.commonRetry,
          onAction: _getCurrentLocation,
        );
      case _LocationIssue.deniedForever:
        return AppBanner(
          tone: AppTone.warning,
          icon: LucideIcons.mapPinOff,
          title: l.issueBlockedTitle,
          message: l.issueBlockedMessage,
          actionLabel: l.actionOpenSettings,
          onAction: Geolocator.openAppSettings,
        );
      case _LocationIssue.serviceOff:
        return AppBanner(
          tone: AppTone.warning,
          icon: LucideIcons.mapPinOff,
          title: l.issueServiceOffTitle,
          message: l.issueServiceOffMessage,
          actionLabel: l.actionOpenLocationSettings,
          onAction: Geolocator.openLocationSettings,
        );
    }
  }

  Widget _buildAddressCard(BuildContext context) {
    final location = _selectedLocation;
    final l = ListingL10n.of(context);

    if (location == null) {
      return AppCard(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.noSpotTitle, style: context.text.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    l.noSpotSubtitle,
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: _isLocating ? null : _getCurrentLocation,
              icon: const Icon(LucideIcons.locateFixed, size: 16),
              label: Text(l.actionLocateMe),
            ),
          ],
        ),
      );
    }

    final showSkeleton = _isResolving;

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.colors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.mapPin,
              size: 18,
              color: context.colors.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow(l.selectedSpotEyebrow),
                const SizedBox(height: AppSpacing.xs),
                if (showSkeleton) ...[
                  const SizedBox(height: 2),
                  const Skeleton(height: 14),
                  const SizedBox(height: AppSpacing.sm),
                ] else
                  Text(
                    _selectedAddress.isEmpty
                        ? l.pinnedSpotNoAddress
                        : _selectedAddress,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodyMedium?.copyWith(
                      color: context.colors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  formatLatLng(location),
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Small paper label floated over map tiles.
class _MapLabel extends StatelessWidget {
  const _MapLabel({
    required this.label,
    required this.style,
    this.icon,
    this.dense = false,
  });

  final String label;
  final TextStyle? style;
  final IconData? icon;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? AppSpacing.sm : AppSpacing.md,
        vertical: dense ? 3 : AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface.withValues(alpha: dense ? 0.85 : 1),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: dense ? null : Border.all(color: context.colors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: context.colors.primary),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style?.copyWith(color: context.colors.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

/// The pin that marks a pickup spot. Use it in a [Marker] sized
/// [width] x [height] with `alignment: Alignment.topCenter` so that the tip
/// sits on the coordinate.
class LocationMapPin extends StatelessWidget {
  const LocationMapPin({super.key, this.icon = LucideIcons.bookOpen});

  final IconData icon;

  static const double width = 44;
  static const double height = 52;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: colors.surface, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: context.palette.softShadow,
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, size: 18, color: colors.onPrimary),
        ),
        Container(
          width: 3,
          height: 12,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(2),
            ),
          ),
        ),
      ],
    );
  }
}

/// Non-interactive map snapshot centred on [location], used to preview a
/// chosen pickup spot inside a card.
class LocationPreviewMap extends StatelessWidget {
  const LocationPreviewMap({
    super.key,
    required this.location,
    this.height = 136,
    this.pinIcon = LucideIcons.bookOpen,
  });

  final LatLng location;
  final double height;
  final IconData pinIcon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: IgnorePointer(
        child: ColoredBox(
          color: context.colors.surfaceContainerHighest,
          child: FlutterMap(
            // A new key recentres the preview when the spot changes.
            key: ValueKey(location),
            options: MapOptions(
              initialCenter: location,
              initialZoom: 15.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.none,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: _tileUrl,
                userAgentPackageName: _tileUserAgent,
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: location,
                    width: LocationMapPin.width,
                    height: LocationMapPin.height,
                    alignment: Alignment.topCenter,
                    child: LocationMapPin(icon: pinIcon),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
