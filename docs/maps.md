# Maps & Navigation Engine

## Overview
Powered by MapLibre GL & OpenStreetMap (OSM), delivering high-fps vector map rendering, offline tile caching, route planning, and heatmaps.

## Components
- **MapConfig**: Central configuration for dark vector tiles, tile servers, and map styles.
- **RoutePlanningService**: Calculates route options (Fastest, Scenic, Mountain) with elevation profiles.
- **HeatmapService**: Renders popular rider routes using custom canvas heat dot overlays.
- **LiveGroupMap**: Displays real-time locations of squad members during group rides.
