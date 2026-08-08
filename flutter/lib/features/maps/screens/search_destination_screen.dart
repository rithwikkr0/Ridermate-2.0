import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/router/app_router.dart';
import '../services/mock_place_search_service.dart';
import '../services/nominatim_place_search_service.dart';

class SearchDestinationScreen extends StatefulWidget {
  final String mode; // 'origin' or 'destination'

  const SearchDestinationScreen({
    super.key,
    this.mode = 'destination',
  });

  @override
  State<SearchDestinationScreen> createState() => _SearchDestinationScreenState();
}

class _SearchDestinationScreenState extends State<SearchDestinationScreen> {
  final NominatimPlaceSearchService _searchService = NominatimPlaceSearchService();
  final TextEditingController _searchController = TextEditingController();

  List<PlaceItem> _searchResults = [];
  List<PlaceItem> _recentSearches = [];
  List<PlaceItem> _savedPlaces = [];
  bool _isSearching = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final recent = await _searchService.getRecentSearches();
    final saved = await _searchService.getSavedPlaces();
    if (!mounted) return;
    setState(() {
      _recentSearches = recent;
      _savedPlaces = saved;
    });
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().length < 2) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 400), () async {
      final results = await _searchService.searchPlaces(query);
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    });
  }

  void _selectPlace(PlaceItem place) {
    if (widget.mode == 'origin') {
      context.push(
        '${AppRoutes.routePlanning}?startTitle=${Uri.encodeComponent(place.title)}&startLat=${place.latitude}&startLng=${place.longitude}',
      );
    } else {
      context.push(
        '${AppRoutes.routePlanning}?destTitle=${Uri.encodeComponent(place.title)}&destLat=${place.latitude}&destLng=${place.longitude}',
      );
    }
  }

  void _selectCurrentLocation() {
    context.push(
      '${AppRoutes.routePlanning}?startTitle=${Uri.encodeComponent('Current GPS Location')}&startLat=0.0&startLng=0.0',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOriginMode = widget.mode == 'origin';
    final hintText = isOriginMode ? 'Search starting location...' : 'Search destination location...';

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Container(
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            style: const TextStyle(color: AppColors.onSurface),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: AppColors.onSurfaceVariant),
              prefixIcon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.onSurfaceVariant),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.7, -0.4),
                radius: 1.2,
                colors: [Color(0x0DFF6B00), Colors.transparent],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Option to use Current GPS Location
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: ListTile(
                      onTap: _selectCurrentLocation,
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.circuitOrange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.circuitOrange),
                        ),
                        child: const Icon(Icons.my_location, color: AppColors.circuitOrange),
                      ),
                      title: Text('Use Current GPS Location',
                          style: AppTextStyles.bodyLg().copyWith(color: AppColors.circuitOrange)),
                      subtitle: Text('Real-time physical GPS sensor position',
                          style: AppTextStyles.bodyMd().copyWith(color: AppColors.onSurfaceVariant)),
                    ),
                  ),

                  if (_isSearching)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.circuitOrange,
                        ),
                      ),
                    ),

                  if (_searchResults.isNotEmpty) ...[
                    Text('SEARCH RESULTS', style: AppTextStyles.labelCaps()).animate().fadeIn(),
                    const SizedBox(height: AppSpacing.md),
                    ..._searchResults.map(
                      (place) => _buildPlaceTile(place, 'RESULT'),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  if (_recentSearches.isNotEmpty) ...[
                    Text('RECENT SEARCHES', style: AppTextStyles.labelCaps()).animate().fadeIn(),
                    const SizedBox(height: AppSpacing.md),
                    ..._recentSearches.map(
                      (place) => _buildPlaceTile(place, 'RECENT'),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  if (_savedPlaces.isNotEmpty) ...[
                    Text('SAVED PLACES', style: AppTextStyles.labelCaps()).animate().fadeIn(),
                    const SizedBox(height: AppSpacing.md),
                    ..._savedPlaces.map(
                      (place) => _buildPlaceTile(place, 'SAVED'),
                    ),
                  ],

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceTile(PlaceItem place, String tag) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        onTap: () => _selectPlace(place),
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: const Icon(Icons.place_outlined, color: AppColors.circuitOrange),
        ),
        title: Text(place.title, style: AppTextStyles.bodyLg().copyWith(color: AppColors.onSurface)),
        subtitle: Text(place.subtitle, style: AppTextStyles.bodyMd().copyWith(color: AppColors.onSurfaceVariant)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(tag, style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant)),
        ),
      ),
    );
  }
}
