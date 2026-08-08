import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'mock_place_search_service.dart';

/// RiderMate 2.0 — Real OpenStreetMap Nominatim Geocoding Service
class NominatimPlaceSearchService implements PlaceSearchService {
  static const String _recentKey = 'ridermate_recent_places';

  @override
  Future<List<PlaceItem>> searchPlaces(String query) async {
    if (query.trim().length < 2) {
      return getRecentSearches();
    }

    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=5&addressdetails=1',
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'RiderMateApp/2.0 (com.ridermate.ridermate)',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final List<PlaceItem> results = [];

        for (var i = 0; i < data.length; i++) {
          final item = data[i];
          final lat = double.tryParse(item['lat']?.toString() ?? '') ?? 0.0;
          final lon = double.tryParse(item['lon']?.toString() ?? '') ?? 0.0;
          final displayName = item['display_name']?.toString() ?? 'Unknown';

          final parts = displayName.split(',');
          final title = parts.isNotEmpty ? parts.first.trim() : displayName;
          final subtitle = parts.length > 1
              ? parts.sublist(1, parts.length > 3 ? 3 : parts.length).join(',').trim()
              : 'Location';

          if (lat != 0.0 && lon != 0.0) {
            results.add(
              PlaceItem(
                id: 'nom_${item['place_id'] ?? i}',
                title: title,
                subtitle: subtitle,
                latitude: lat,
                longitude: lon,
              ),
            );
          }
        }

        if (results.isNotEmpty) {
          _saveRecentSearches(results.first);
        }

        return results;
      }
    } catch (_) {
      // Fallback gracefully on network / timeout errors
    }

    // Fallback search in recent searches / saved places
    final recents = await getRecentSearches();
    return recents
        .where((p) => p.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<List<PlaceItem>> getRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_recentKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List list = jsonDecode(jsonStr);
        return list.map((item) {
          return PlaceItem(
            id: item['id'] ?? '',
            title: item['title'] ?? '',
            subtitle: item['subtitle'] ?? '',
            latitude: (item['lat'] as num).toDouble(),
            longitude: (item['lng'] as num).toDouble(),
            isFavorite: item['isFavorite'] ?? false,
          );
        }).toList();
      }
    } catch (_) {}

    return const [
      PlaceItem(
        id: 'rec_1',
        title: 'Nandi Hills Peak',
        subtitle: 'Chikkaballapur, KA',
        latitude: 13.3702,
        longitude: 77.6835,
      ),
      PlaceItem(
        id: 'rec_2',
        title: 'Bangalore Palace',
        subtitle: 'Vasanth Nagar, Bengaluru',
        latitude: 12.9988,
        longitude: 77.5921,
      ),
    ];
  }

  @override
  Future<List<PlaceItem>> getSavedPlaces() async {
    return const [
      PlaceItem(
        id: 'sav_1',
        title: 'Home Base',
        subtitle: 'Koramangala, Bengaluru',
        latitude: 12.9352,
        longitude: 77.6245,
        isFavorite: true,
      ),
      PlaceItem(
        id: 'sav_2',
        title: 'Tech Park Work',
        subtitle: 'Outer Ring Rd, Bellandur',
        latitude: 12.9279,
        longitude: 77.6811,
        isFavorite: true,
      ),
    ];
  }

  Future<void> _saveRecentSearches(PlaceItem newPlace) async {
    try {
      final current = await getRecentSearches();
      final updated = [
        newPlace,
        ...current.where((p) => p.title != newPlace.title),
      ].take(5).toList();

      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(updated
          .map((p) => {
                'id': p.id,
                'title': p.title,
                'subtitle': p.subtitle,
                'lat': p.latitude,
                'lng': p.longitude,
                'isFavorite': p.isFavorite,
              })
          .toList());
      await prefs.setString(_recentKey, encoded);
    } catch (_) {}
  }
}
