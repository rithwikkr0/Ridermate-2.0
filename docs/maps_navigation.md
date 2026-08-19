# RiderMate 2.0 — Maps & Navigation Module Architecture

> **Document Type**: Maps Architecture & Navigation Specification  
> **Framework**: MapLibre Flutter / OpenStreetMap Tile Standards  
> **Cost Model**: 100% Free / Zero API Key & Billing Requirements

---

## 1. Overview
Powered by OpenStreetMap (OSM) tile standards with `flutter_map` / `latlong2`, delivering vector/raster map rendering, offline tile caching, route planning via OSRM, and live group ride heatmaps.

### Key Components
- **MapConfig**: Central configuration for dark vector tiles, tile servers, and map styles.
- **RoutePlanningService**: Calculates route options (Fastest, Scenic, Mountain) with elevation profiles.
- **HeatmapService**: Renders popular rider routes using custom canvas heat dot overlays.
- **LiveGroupMap**: Displays real-time locations of squad members during group rides.
- **RealMapView**: Reusable embedded map widget for live tracking, navigation, and location selection.

---

## 2. System Architecture Diagram

```
+-------------------------------------------------------------------------+
|                         RiderMate 2.0 Maps UI                           |
|  (Live Navigation, Search Destination, Heatmap Explorer, Group Map)     |
+------------------------------------^------------------------------------+
                                     | Navigation & Telemetry Stream
+------------------------------------+------------------------------------+
|                       NavigationController                              |
|           (startNavigation(), pauseNavigation(), stopNavigation())      |
+-----------------^-----------------------------------^-------------------+
                  |                                   |
+-----------------+-------------------+   +-----------+-------------------+
|         MockGpsProvider             |   |    MockRoutePlanningService   |
|   (1-sec GPS Position & Heading)    |   | (Fastest, Scenic, Eco Routes) |
+-------------------------------------+   +-------------------------------+
                  |
+-----------------+-------------------------------------------------------+
|                       OfflineTileService & Storage                      |
| (OpenStreetMap CartoDB Dark/Light Tile Caching & Pre-download Region)   |
+-------------------------------------------------------------------------+
```

---

## 2. Tile Provider & OpenStreetMap Integration

- **Dark Theme Map Tile Server**: `https://cartodb-basemaps-a.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png`
- **Light Theme Map Tile Server**: `https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png`
- **Zero Cost Guarantee**: Standard OpenStreetMap / CartoDB tiles require no proprietary API key or paid subscriptions.

---

## 3. Offline Strategy

1. **Pre-download Region**: `OfflineTileService.downloadRegion()` specifies tile bounds (`minLat`, `minLng`, `maxLat`, `maxLng`) and downloads vector/raster tiles into local SQLite tile cache.
2. **Storage Management**: Users can monitor cached tile storage usage (e.g. `450 MB`) and clear tile caches on demand.

---

## 4. Navigation Features Overview

- **Turn-by-Turn Instruction Stream**: Displays directional maneuvers, next road name, and distance to turn.
- **Group Ride Telemetry**: Streams mock coordinates and positions for 4-5 group riders with leader indicators.
- **Heatmap Explorer**: Renders gradient density overlays on high-traffic motorcycling routes.
