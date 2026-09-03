/// RiderMate 2.0 — OpenStreetMap & High-Performance Tile Themes
enum MapTheme { dark, light, satellite, terrain }

class MapConfig {
  /// Clean, high-performance dark gray canvas tiles (zero watermark, no API key required)
  static const String darkTileUrl =
      'https://services.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Dark_Gray_Base/MapServer/tile/{z}/{y}/{x}';

  /// Clean, high-performance light gray canvas tiles
  static const String lightTileUrl =
      'https://services.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}';

  static const double defaultZoom = 15.0;
  static const double maxZoom = 18.0;
  static const double minZoom = 3.0;
}
