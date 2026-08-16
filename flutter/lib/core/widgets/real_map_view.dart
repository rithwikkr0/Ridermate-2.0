import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as platform;

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../widgets/glass_card.dart';
import '../services/location_service.dart';
import '../models/ride_point_model.dart';
import '../errors/app_error.dart';

/// RiderMate 2.0 — Real Map Component powered by OpenStreetMap & FlutterMap.
/// Displays real hardware GPS device location marker, heading arrow, accuracy circle,
/// follow mode, recenter controls, tile load error handling, and permission banners.
class RealMapView extends StatefulWidget {
  final double initialZoom;
  final bool showRecenterButton;
  final bool showControls;
  final bool followUserLocation;
  final Widget? overlayChild;
  final List<LatLng>? polylinePoints;
  final List<Marker>? extraMarkers;

  const RealMapView({
    super.key,
    this.initialZoom = 15.0,
    this.showRecenterButton = true,
    this.showControls = true,
    this.followUserLocation = true,
    this.overlayChild,
    this.polylinePoints,
    this.extraMarkers,
  });


  @override
  State<RealMapView> createState() => _RealMapViewState();
}

class _RealMapViewState extends State<RealMapView> with WidgetsBindingObserver {
  final MapController _mapController = MapController();
  final DeviceLocationService _locationService = const DeviceLocationService();

  StreamSubscription<RidePointModel>? _locationSubscription;
  RidePointModel? _currentLocation;
  bool _isFollowingUser = true;

  bool _isGpsEnabled = true;
  LocationPermission _permissionStatus = LocationPermission.whileInUse;
  String? _errorMessage;
  bool _hasTileError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _isFollowingUser = widget.followUserLocation;
    _initializeLocation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _locationSubscription?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkStatusAndSubscribe();
    }
  }

  Future<void> _initializeLocation() async {
    await _checkStatusAndSubscribe();
  }

  Future<void> _checkStatusAndSubscribe() async {
    final enabled = await _locationService.isGpsEnabled();
    final perm = await _locationService.checkPermissionStatus();

    setState(() {
      _isGpsEnabled = enabled;
      _permissionStatus = perm;
    });

    if (!enabled ||
        (perm != LocationPermission.whileInUse &&
            perm != LocationPermission.always)) {
      _locationSubscription?.cancel();
      _locationSubscription = null;
      return;
    }

    // Attempt immediate single fix for fast initial camera centering
    final singleFix = await _locationService.getCurrentLocation();
    if (singleFix.isSuccess && singleFix.dataOrNull != null && singleFix.dataOrNull!.isValid) {
      final loc = singleFix.dataOrNull!;
      if (mounted) {
        setState(() {
          _currentLocation = loc;
        });
        if (_isFollowingUser) {
          _mapController.move(
            LatLng(loc.latitude, loc.longitude),
            widget.initialZoom,
          );
        }
      }
    }

    // Subscribe to continuous real location stream
    _subscribeToStream();
  }


  void _subscribeToStream() {
    _locationSubscription?.cancel();
    _locationSubscription = _locationService.getLocationStream().listen(
      (point) {
        if (!mounted) return;
        setState(() {
          _currentLocation = point;
          _errorMessage = null;
        });

        if (_isFollowingUser && point.isValid) {
          _mapController.move(
            LatLng(point.latitude, point.longitude),
            _mapController.camera.zoom,
          );
        }
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          if (error is AppError) {
            _errorMessage = error.message;
          } else {
            _errorMessage = 'Location stream error: $error';
          }
        });
      },
    );
  }

  void _recenterMap() {
    final loc = _currentLocation;
    if (loc != null && loc.isValid) {
      setState(() {
        _isFollowingUser = true;
      });
      _mapController.move(
        LatLng(loc.latitude, loc.longitude),
        widget.initialZoom,
      );
    } else {
      _checkStatusAndSubscribe();
    }
  }

  void _zoomIn() {
    _mapController.move(
      _mapController.camera.center,
      (_mapController.camera.zoom + 1).clamp(3.0, 18.0),
    );
  }

  void _zoomOut() {
    _mapController.move(
      _mapController.camera.center,
      (_mapController.camera.zoom - 1).clamp(3.0, 18.0),
    );
  }

  Future<void> _requestPermission() async {
    final result = await _locationService.requestPermission();
    setState(() {
      _permissionStatus = result;
    });
    if (result == LocationPermission.whileInUse ||
        result == LocationPermission.always) {
      _checkStatusAndSubscribe();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Default initial center (Bangalore / Mumbai fallback until GPS fix)
    final initialCenter = _currentLocation != null && _currentLocation!.isValid
        ? LatLng(_currentLocation!.latitude, _currentLocation!.longitude)
        : const LatLng(12.971598, 77.594566);

    return Stack(
      children: [
        // ── Map Surface ───────────────────────────────────────────────────
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: widget.initialZoom,
            minZoom: 3.0,
            maxZoom: 18.0,
            onPositionChanged: (position, hasGesture) {
              if (hasGesture && _isFollowingUser) {
                setState(() {
                  _isFollowingUser = false;
                });
              }
            },
          ),
          children: [
            // OpenStreetMap Standard Tiles
            TileLayer(
              urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.ridermate.ridermate',
              errorTileCallback: (tile, error, stackTrace) {
                if (!_hasTileError) {
                  setState(() {
                    _hasTileError = true;
                  });
                }
              },
            ),


            // Polyline Layer for Routes
            if (widget.polylinePoints != null && widget.polylinePoints!.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: widget.polylinePoints!,
                    color: AppColors.circuitOrange,
                    strokeWidth: 5.0,
                  ),
                ],
              ),

            // Accuracy Circle Layer
            if (_currentLocation != null &&
                _currentLocation!.isValid &&
                _currentLocation!.accuracy > 0)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: LatLng(
                        _currentLocation!.latitude, _currentLocation!.longitude),
                    radius: _currentLocation!.accuracy,
                    useRadiusInMeter: true,
                    color: AppColors.circuitOrange.withValues(alpha: 0.15),
                    borderColor: AppColors.circuitOrange.withValues(alpha: 0.5),
                    borderStrokeWidth: 1.5,
                  ),
                ],
              ),

            // Additional Custom Markers (Destination or Group Members)
            if (widget.extraMarkers != null && widget.extraMarkers!.isNotEmpty)
              MarkerLayer(markers: widget.extraMarkers!),

            // Real Device Location Marker Layer
            if (_currentLocation != null && _currentLocation!.isValid)
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(_currentLocation!.latitude,
                        _currentLocation!.longitude),
                    width: 50,
                    height: 50,
                    child: _buildLocationMarker(_currentLocation!),
                  ),
                ],
              ),

          ],
        ),

        // ── Tile Load / Network Warning Banner ────────────────────────────
        if (_hasTileError)
          Positioned(
            top: 50,
            left: AppSpacing.marginMobile,
            right: AppSpacing.marginMobile,
            child: GlassCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off_rounded,
                        color: Colors.amberAccent, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Map tiles offline. Displaying cached/vector position.',
                        style: AppTextStyles.labelCapsSm(
                            color: AppColors.onSurface),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // ── Custom Overlay Child (Passed by screens) ───────────────────────
        if (widget.overlayChild != null) widget.overlayChild!,

        // ── Permission / Disabled Overlays ────────────────────────────────
        if (!_isGpsEnabled)
          _buildOverlayCard(
            title: 'LOCATION SERVICES DISABLED',
            message:
                'Turn on device GPS location services in Android settings to view your position on the map.',
            buttonText: 'OPEN GPS SETTINGS',
            onPressed: () => Geolocator.openLocationSettings(),
            icon: Icons.location_off,
          )
        else if (_permissionStatus == LocationPermission.denied)
          _buildOverlayCard(
            title: 'LOCATION PERMISSION REQUIRED',
            message:
                'Grant location permission so RiderMate can display your position and record your trajectory.',
            buttonText: 'GRANT PERMISSION',
            onPressed: _requestPermission,
            icon: Icons.security,
          )
        else if (_permissionStatus == LocationPermission.deniedForever)
          _buildOverlayCard(
            title: 'PERMANENTLY DENIED',
            message:
                'Location permission is permanently denied. Enable it in system Settings -> Apps -> RiderMate.',
            buttonText: 'OPEN SYSTEM SETTINGS',
            onPressed: () => platform.openAppSettings(),
            icon: Icons.settings,
          ),

        // ── Map Floating Control Buttons (Recenter / Zoom) ─────────────────
        if (widget.showControls)
          Positioned(
            right: AppSpacing.marginMobile,
            bottom: 120,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.showRecenterButton)
                  FloatingActionButton.small(
                    heroTag: 'map_recenter',
                    backgroundColor: _isFollowingUser
                        ? AppColors.circuitOrange
                        : AppColors.surfaceContainerHigh,
                    foregroundColor: Colors.white,
                    onPressed: _recenterMap,
                    child: Icon(
                      _isFollowingUser
                          ? Icons.my_location
                          : Icons.location_searching,
                    ),
                  ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'map_zoom_in',
                  backgroundColor: AppColors.surfaceContainerHigh,
                  foregroundColor: Colors.white,
                  onPressed: _zoomIn,
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 4),
                FloatingActionButton.small(
                  heroTag: 'map_zoom_out',
                  backgroundColor: AppColors.surfaceContainerHigh,
                  foregroundColor: Colors.white,
                  onPressed: _zoomOut,
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLocationMarker(RidePointModel point) {
    final hasHeading = point.heading > 0;
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // YOU label badge
        Positioned(
          top: -18,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.circuitOrange, width: 1),
            ),
            child: const Text(
              'YOU',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // Rotated heading arrow & pulse core
        Transform.rotate(
          angle: hasHeading ? (point.heading * (3.141592653589793 / 180.0)) : 0.0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulse glow
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.circuitOrange.withValues(alpha: 0.3),
                ),
              ),
              // Inner solid core
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.circuitOrange,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.circuitOrange,
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: hasHeading
                    ? const Icon(
                        Icons.navigation_rounded,
                        color: Colors.white,
                        size: 14,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildOverlayCard({
    required String title,
    required String message,
    required String buttonText,
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 32, color: AppColors.circuitOrange),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    title,
                    style: AppTextStyles.labelCaps()
                        .copyWith(color: AppColors.circuitOrange),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    message,
                    style: AppTextStyles.bodySm()
                        .copyWith(color: AppColors.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.circuitOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: onPressed,
                    child: Text(buttonText, style: AppTextStyles.labelCapsSm()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
