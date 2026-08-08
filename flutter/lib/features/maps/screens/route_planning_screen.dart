import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/real_map_view.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/location_service.dart';
import '../models/navigation_route_model.dart';
import '../models/group_ride_model.dart';
import '../services/osrm_routing_service.dart';
import '../services/mock_place_search_service.dart';


class RoutePlanningScreen extends StatefulWidget {
  final String? startTitle;
  final double? startLat;
  final double? startLng;
  final String? destTitle;
  final double? destLat;
  final double? destLng;

  const RoutePlanningScreen({
    super.key,
    this.startTitle,
    this.startLat,
    this.startLng,
    this.destTitle,
    this.destLat,
    this.destLng,
  });

  @override
  State<RoutePlanningScreen> createState() => _RoutePlanningScreenState();
}

class _RoutePlanningScreenState extends State<RoutePlanningScreen> {
  final OsrmRoutingService _routingService = OsrmRoutingService();
  final DeviceLocationService _locationService = const DeviceLocationService();

  RideMode _selectedMode = RideMode.solo;
  NavigationRouteModel? _calculatedRoute;
  List<LatLng> _routePolyline = [];
  bool _isLoadingRoute = false;

  String _startName = 'Current Location';
  double _startLat = 0.0;
  double _startLng = 0.0;
  bool _isStartCurrentLocation = true;

  String _destinationName = 'Nandi Hills Peak';
  double _destLat = 13.3702;
  double _destLng = 77.6835;

  @override
  void initState() {
    super.initState();

    if (widget.startTitle != null && widget.startTitle!.isNotEmpty) {
      _startName = widget.startTitle!;
      _isStartCurrentLocation = _startName == 'Current Location' || _startName == 'Current GPS Location';
    }
    if (widget.startLat != null && widget.startLng != null) {
      _startLat = widget.startLat!;
      _startLng = widget.startLng!;
    }

    if (widget.destTitle != null && widget.destTitle!.isNotEmpty) {
      _destinationName = widget.destTitle!;
    }
    if (widget.destLat != null && widget.destLng != null) {
      _destLat = widget.destLat!;
      _destLng = widget.destLng!;
    }

    _calculateRoute();
  }

  Future<void> _calculateRoute() async {
    setState(() {
      _isLoadingRoute = true;
    });

    double actualStartLat = _startLat;
    double actualStartLng = _startLng;

    if (_isStartCurrentLocation || (actualStartLat == 0.0 && actualStartLng == 0.0)) {
      final currentPos = await _locationService.getCurrentLocation();
      if (currentPos.isSuccess && currentPos.dataOrNull != null && currentPos.dataOrNull!.isValid) {
        actualStartLat = currentPos.dataOrNull!.latitude;
        actualStartLng = currentPos.dataOrNull!.longitude;
      } else {
        actualStartLat = 12.971598;
        actualStartLng = 77.594566;
      }
    }

    final routes = await _routingService.planRoutes(
      startLat: actualStartLat,
      startLng: actualStartLng,
      destLat: _destLat,
      destLng: _destLng,
    );

    if (!mounted) return;

    if (routes.isNotEmpty) {
      final primaryRoute = routes.first;
      final polyline = primaryRoute.points
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();

      setState(() {
        _startLat = actualStartLat;
        _startLng = actualStartLng;
        _calculatedRoute = primaryRoute;
        _routePolyline = polyline;
        _isLoadingRoute = false;
      });
    } else {
      setState(() {
        _isLoadingRoute = false;
      });
    }
  }

  void _swapLocations() {
    setState(() {
      final tempName = _startName;
      final tempLat = _startLat;
      final tempLng = _startLng;
      final tempIsCurrent = _isStartCurrentLocation;

      _startName = _destinationName;
      _startLat = _destLat;
      _startLng = _destLng;
      _isStartCurrentLocation = false;

      _destinationName = tempName;
      _destLat = tempLat;
      _destLng = tempLng;
    });

    _calculateRoute();
  }

  void _startRide() {
    if (_selectedMode == RideMode.solo) {
      context.push(AppRoutes.liveNavigation);
    } else {
      context.push(AppRoutes.liveGroupMap);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text('Route Planning', style: AppTextStyles.headlineMd()),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Real OpenStreetMap View with OSRM Route Polyline
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.50,
            child: RealMapView(
              initialZoom: 13.0,
              showControls: true,
              followUserLocation: false,
              polylinePoints: _routePolyline,
              extraMarkers: [
                if (_destLat != 0.0 && _destLng != 0.0)
                  Marker(
                    point: LatLng(_destLat, _destLng),
                    width: 44,
                    height: 44,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.circuitOrange,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black45, blurRadius: 6),
                        ],
                      ),
                      child: const Icon(Icons.flag_rounded, color: Colors.white, size: 24),
                    ),
                  ),
              ],
            ),
          ),

          // Route Planning Panel
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.55,
                  padding: const EdgeInsets.all(AppSpacing.marginMobile),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark.withValues(alpha: 0.92),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    border: Border(top: BorderSide(color: AppColors.glassBorder)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mode Selector (Solo vs Group Ride)
                      Row(
                        children: [
                          Expanded(
                            child: _buildModeChip(
                              mode: RideMode.solo,
                              label: 'SOLO RIDE',
                              icon: Icons.person,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _buildModeChip(
                              mode: RideMode.group,
                              label: 'GROUP RIDE',
                              icon: Icons.groups_rounded,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // FROM and TO Cards with Swap Button ⇅
                      GlassCard(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  // FROM Field
                                  InkWell(
                                    onTap: () async {
                                      final result = await context.push<PlaceItem>(
                                        '${AppRoutes.searchDest}?mode=origin',
                                      );
                                      if (result != null && mounted) {
                                        setState(() {
                                          _startName = result.title;
                                          _isStartCurrentLocation =
                                              result.id == 'current_gps';
                                          _startLat = result.latitude;
                                          _startLng = result.longitude;
                                        });
                                        _calculateRoute();
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.my_location, color: AppColors.circuitOrange, size: 20),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('FROM', style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
                                                Text(_startName, style: AppTextStyles.bodyLg(color: AppColors.onSurface), overflow: TextOverflow.ellipsis),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Divider(color: Colors.white10, height: 1),
                                  // TO Field
                                  InkWell(
                                    onTap: () async {
                                      final result = await context.push<PlaceItem>(
                                        '${AppRoutes.searchDest}?mode=destination',
                                      );
                                      if (result != null && mounted) {
                                        setState(() {
                                          _destinationName = result.title;
                                          _destLat = result.latitude;
                                          _destLng = result.longitude;
                                        });
                                        _calculateRoute();
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.place, color: Colors.redAccent, size: 20),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('TO', style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
                                                Text(_destinationName, style: AppTextStyles.bodyLg(color: AppColors.onSurface), overflow: TextOverflow.ellipsis),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Swap Button ⇅
                            IconButton(
                              icon: const Icon(Icons.swap_vert_rounded, color: AppColors.circuitOrange, size: 30),
                              onPressed: _swapLocations,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // OSRM Calculated Stats & Details
                      if (_isLoadingRoute)
                        const Expanded(
                          child: Center(
                            child: CircularProgressIndicator(color: AppColors.circuitOrange),
                          ),
                        )
                      else if (_calculatedRoute != null)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildStatTile('DISTANCE', '${_calculatedRoute!.distanceKm} km'),
                                  _buildStatTile('ETA', '${_calculatedRoute!.estimatedDuration.inMinutes} min'),
                                  _buildStatTile('ROUTING', 'OpenStreetMap OSRM'),
                                ],
                              ),
                              const Spacer(),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.circuitOrange,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 4,
                                  ),
                                  onPressed: _startRide,
                                  child: Text(
                                    _selectedMode == RideMode.solo ? 'START SOLO RIDE' : 'PROCEED TO GROUP RIDE',
                                    style: AppTextStyles.headlineMd(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeChip({required RideMode mode, required String label, required IconData icon}) {
    final isSelected = _selectedMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _selectedMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.circuitOrange.withValues(alpha: 0.2) : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.circuitOrange : AppColors.glassBorder,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(icon, color: isSelected ? AppColors.circuitOrange : AppColors.onSurfaceVariant, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.labelCaps().copyWith(
                color: isSelected ? AppColors.circuitOrange : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.headlineLg(color: AppColors.onSurface)),
      ],
    );
  }
}
