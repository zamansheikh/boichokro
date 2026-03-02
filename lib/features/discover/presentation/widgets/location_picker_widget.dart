import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;

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

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  late MapController _mapController;
  LatLng? _selectedLocation;
  String _selectedAddress = '';
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

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
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // Prominent Disclosure for Google Play Policy Compliance
        if (mounted) {
          final bool? shouldRequest = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: const Text('Location Access Required'),
                content: const Text(
                  'Boichokro needs your location to help you pinpoint your current address '
                  'for assigning a pickup location to a book you upload, or finding a nearby book.',
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: const Text('Deny'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: const Text('Accept'),
                  ),
                ],
              );
            },
          );

          if (shouldRequest != true) {
            throw Exception('Location permission denied by user');
          }
        }

        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final location = LatLng(position.latitude, position.longitude);
      await _updateLocation(location);

      // Animate to location
      _mapController.move(location, 15.0);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error getting location: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchAddress() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final locations = await geo.locationFromAddress(query);
      if (locations.isNotEmpty) {
        final location = LatLng(
          locations.first.latitude,
          locations.first.longitude,
        );
        await _updateLocation(location);
        _mapController.move(location, 15.0);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Address not found')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not find address. Please try a different search or select location on map.',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateLocation(LatLng location) async {
    setState(() {
      _selectedLocation = location;
      _isLoading = true;
    });

    try {
      // Reverse geocode to get address
      final placemarks = await geo.placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

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
      setState(() => _isLoading = false);
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng location) {
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        actions: [
          if (_selectedLocation != null)
            IconButton(
              onPressed: _confirmLocation,
              icon: const Icon(Icons.check),
              tooltip: 'Confirm Location',
            ),
        ],
      ),
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter:
                  _selectedLocation ?? const LatLng(23.8103, 90.4125), // Dhaka
              initialZoom: _selectedLocation != null ? 15.0 : 12.0,
              onTap: _onMapTap,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.boichokro',
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      width: 60,
                      height: 60,
                      child: Icon(
                        Icons.location_pin,
                        color: colorScheme.error,
                        size: 60,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Search Bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search address...',
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search),
                        ),
                        onSubmitted: (_) => _searchAddress(),
                      ),
                    ),
                    IconButton(
                      onPressed: _searchAddress,
                      icon: const Icon(Icons.arrow_forward),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Current Location Button
          Positioned(
            bottom: 100,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'current_location',
              onPressed: _getCurrentLocation,
              child: const Icon(Icons.my_location),
            ),
          ),

          // Address Display Card
          if (_selectedLocation != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Selected Location',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedAddress.isEmpty
                            ? 'Loading address...'
                            : _selectedAddress,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Loading Indicator
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
