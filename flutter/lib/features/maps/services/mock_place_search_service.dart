class PlaceItem {
  final String id;
  final String title;
  final String subtitle;
  final double latitude;
  final double longitude;
  final bool isFavorite;

  const PlaceItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.latitude,
    required this.longitude,
    this.isFavorite = false,
  });
}

abstract class PlaceSearchService {
  Future<List<PlaceItem>> searchPlaces(String query);
  Future<List<PlaceItem>> getRecentSearches();
  Future<List<PlaceItem>> getSavedPlaces();
}

class MockPlaceSearchService implements PlaceSearchService {
  final List<PlaceItem> _places = const [
    PlaceItem(id: 'p1', title: 'Marine Drive Coastal Pass', subtitle: 'Mumbai, MH', latitude: 18.944, longitude: 72.823, isFavorite: true),
    PlaceItem(id: 'p2', title: 'Lonavala Western Ghats', subtitle: 'Pune Highway', latitude: 18.755, longitude: 73.409, isFavorite: true),
    PlaceItem(id: 'p3', title: 'Bandra-Worli Sea Link', subtitle: 'Mumbai, MH', latitude: 19.033, longitude: 72.819),
  ];

  @override
  Future<List<PlaceItem>> searchPlaces(String query) async {
    if (query.isEmpty) return _places;
    return _places.where((p) => p.title.toLowerCase().contains(query.toLowerCase())).toList();
  }

  @override
  Future<List<PlaceItem>> getRecentSearches() async => _places.take(2).toList();

  @override
  Future<List<PlaceItem>> getSavedPlaces() async => _places.where((p) => p.isFavorite).toList();
}
