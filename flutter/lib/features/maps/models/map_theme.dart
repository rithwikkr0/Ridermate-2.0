/// RiderMate 2.0 — OpenStreetMap & MapLibre Tile Themes
enum MapTheme { dark, light, satellite, terrain }

class MapConfig {
  static const String darkTileUrl = 'https://cartodb-basemaps-a.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png';
  static const String lightTileUrl = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const double defaultZoom = 15.0;
  static const double maxZoom = 18.0;
  static const double minZoom = 3.0;
}
