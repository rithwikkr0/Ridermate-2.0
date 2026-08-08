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

class RoutePlanningScreen extends StatefulWidget {
  final String? destTitle;
  final double? destLat;
  final double? destLng;

  const RoutePlanningScreen({
    super.key,
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

  String _destinationName = 'Nandi Hills Peak';
  double _destLat = 13.3702;
  double _destLng = 77.6835;

  @override
  void initState() {
    super.initState();
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

    final currentPos = await _locationService.getCurrentLocation();
    double startLat = 12.971598;
    double startLng = 77.594566;

    if (currentPos.isSuccess && currentPos.dataOrNull != null && currentPos.dataOrNull!.isValid) {
      startLat = currentPos.dataOrNull!.latitude;
      startLng = currentPos.dataOrNull!.longitude;
    }


    final routes = await _routingService.planRoutes(
      startLat: startLat,
      startLng: startLng,
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
        title: Text('Route Preview', style: AppTextStyles.headlineMd()),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Real OpenStreetMap View with OSRM Route Polyline
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.55,
            child: RealMapView(
              initialZoom: 13.0,
              showControls: true,
              followUserLocation: false,
              polylinePoints: _routePolyline,
              extraMarkers: [
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
                  height: MediaQuery.of(context).size.height * 0.5,
                  padding: const EdgeInsets.all(AppSpacing.marginMobile),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark.withValues(alpha: 0.9),
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

                      // Destination Details Card
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            children: [
                              const Icon(Icons.my_location, color: AppColors.circuitOrange, size: 24),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('FROM: Current GPS Location',
                                        style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
                                    Text('TO: $_destinationName',
                                        style: AppTextStyles.bodyLg(color: AppColors.onSurface)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.search, color: AppColors.circuitOrange),
                                onPressed: () => context.push(AppRoutes.searchDest),
                              ),
                            ],
                          ),
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
                                    _selectedMode == RideMode.solo ? 'START SOLO RIDE' : 'START GROUP RIDE',
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
