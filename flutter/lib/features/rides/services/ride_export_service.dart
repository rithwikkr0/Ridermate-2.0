import 'dart:convert';
import '../models/ride_engine_model.dart';

abstract class RideExportService {
  Future<String> exportToJson(RideEngineModel ride);
  Future<String> exportToGpx(RideEngineModel ride);
  Future<String> exportToCsv(RideEngineModel ride);
  Future<List<int>> exportToPdfBytes(RideEngineModel ride);
}

class MockRideExportService implements RideExportService {
  @override
  Future<String> exportToJson(RideEngineModel ride) async {
    return jsonEncode(ride.toJson());
  }

  @override
  Future<String> exportToGpx(RideEngineModel ride) async {
    final buf = StringBuffer();
    buf.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buf.writeln('<gpx version="1.1" creator="RiderMate 2.0">');
    buf.writeln('  <trk><name>${ride.title}</name><trkseg>');
    for (final p in ride.routePoints) {
      buf.writeln('    <trkpt lat="${p.latitude}" lon="${p.longitude}"><ele>${p.elevationMeters}</ele></trkpt>');
    }
    buf.writeln('  </trkseg></trk>');
    buf.writeln('</gpx>');
    return buf.toString();
  }

  @override
  Future<String> exportToCsv(RideEngineModel ride) async {
    final buf = StringBuffer();
    buf.writeln('latitude,longitude,speedKmh,elevationMeters,timestamp');
    for (final p in ride.routePoints) {
      buf.writeln('${p.latitude},${p.longitude},${p.speedKmh},${p.elevationMeters},${p.timestamp}');
    }
    return buf.toString();
  }

  @override
  Future<List<int>> exportToPdfBytes(RideEngineModel ride) async {
    // Return mock PDF binary bytes
    return utf8.encode('%PDF-1.4 Mock RiderMate 2.0 Ride Summary PDF');
  }
}
