import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart' as platform;

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/services/location_service.dart';
import '../../../core/models/ride_point_model.dart';
import '../../../core/errors/app_error.dart';

/// Temporary Internal / Debug GPS Verification Screen.
/// Used to physically test and verify Android hardware GPS sensor performance,
/// live location streams, permission states, and telemetry data on device.
class GpsDebugScreen extends StatefulWidget {
  const GpsDebugScreen({super.key});

  @override
  State<GpsDebugScreen> createState() => _GpsDebugScreenState();
}

class _GpsDebugScreenState extends State<GpsDebugScreen> {
  final DeviceLocationService _locationService = const DeviceLocationService();

  LocationPermission _permissionStatus = LocationPermission.denied;
  bool _isGpsEnabled = false;
  bool _isStreaming = false;
  int _updateCount = 0;

  RidePointModel? _currentPoint;
  StreamSubscription<RidePointModel>? _streamSubscription;
  String? _errorMessage;
  String? _errorCode;

  @override
  void initState() {
    super.initState();
    _refreshStatus();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _refreshStatus() async {
    final enabled = await _locationService.isGpsEnabled();
    final perm = await _locationService.checkPermissionStatus();
    setState(() {
      _isGpsEnabled = enabled;
      _permissionStatus = perm;
    });
  }

  Future<void> _requestPermission() async {
    final result = await _locationService.requestPermission();
    setState(() {
      _permissionStatus = result;
      _errorMessage = null;
      _errorCode = null;
    });
    if (result == LocationPermission.whileInUse ||
        result == LocationPermission.always) {
      _startLiveStream();
    }
  }

  Future<void> _getOneTimeLocation() async {
    setState(() {
      _errorMessage = null;
      _errorCode = null;
    });
    final result = await _locationService.getCurrentLocation();
    if (result.isSuccess) {
      setState(() {
        _currentPoint = result.dataOrNull!;
        _updateCount++;
      });
    } else {
      final err = result.errorOrNull!;
      setState(() {
        _errorMessage = err.message;
        _errorCode = err.code;
      });
    }
  }

  void _startLiveStream() {
    _streamSubscription?.cancel();
    setState(() {
      _isStreaming = true;
      _errorMessage = null;
      _errorCode = null;
    });

    try {
      _streamSubscription = _locationService.getLocationStream().listen(
        (point) {
          setState(() {
            _currentPoint = point;
            _updateCount++;
          });
        },
        onError: (error) {
          setState(() {
            _isStreaming = false;
            if (error is AppError) {
              _errorMessage = error.message;
              _errorCode = error.code;
            } else {
              _errorMessage = error.toString();
              _errorCode = 'stream_error';
            }
          });
        },
      );
    } catch (e) {
      setState(() {
        _isStreaming = false;
        _errorMessage = e.toString();
        _errorCode = 'stream_init_error';
      });
    }
  }

  void _stopStream() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    setState(() {
      _isStreaming = false;
    });
  }

  String _formatTimestamp(int epochMs) {
    if (epochMs == 0) return 'N/A';
    final dt = DateTime.fromMillisecondsSinceEpoch(epochMs).toLocal();
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}.${(dt.millisecond ~/ 100)}';
  }

  String _headingToDirection(double heading) {
    if (heading >= 337.5 || heading < 22.5) return 'N (North)';
    if (heading >= 22.5 && heading < 67.5) return 'NE (North-East)';
    if (heading >= 67.5 && heading < 112.5) return 'E (East)';
    if (heading >= 112.5 && heading < 157.5) return 'SE (South-East)';
    if (heading >= 157.5 && heading < 202.5) return 'S (South)';
    if (heading >= 202.5 && heading < 247.5) return 'SW (South-West)';
    if (heading >= 247.5 && heading < 292.5) return 'W (West)';
    if (heading >= 292.5 && heading < 337.5) return 'NW (North-West)';
    return '${heading.toStringAsFixed(1)}°';
  }

  Color _accuracyColor(double accuracy) {
    if (accuracy == 0) return AppColors.onSurfaceVariant;
    if (accuracy <= 10) return Colors.greenAccent;
    if (accuracy <= 30) return Colors.yellowAccent;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('GPS Sensor Telemetry Debug'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Live GPS Banner ─────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _isStreaming
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.grey.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isStreaming
                            ? Colors.greenAccent
                            : Colors.grey.shade600,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.gps_fixed,
                          color: _isStreaming
                              ? Colors.greenAccent
                              : Colors.grey,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isStreaming ? 'LIVE GPS ACTIVE' : 'GPS IDLE',
                          style: AppTextStyles.labelCapsSm(
                            color: _isStreaming
                                ? Colors.greenAccent
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Updates: $_updateCount',
                    style: AppTextStyles.labelCapsSm(
                        color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Status Header Card ───────────────────────────────────────
              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      _buildStatusRow(
                        'GPS Hardware Status:',
                        _isGpsEnabled ? 'ENABLED' : 'DISABLED',
                        _isGpsEnabled ? Colors.greenAccent : Colors.redAccent,
                      ),
                      const Divider(color: Colors.white10),
                      _buildStatusRow(
                        'Permission Status:',
                        _permissionStatus.name.toUpperCase(),
                        _permissionStatus == LocationPermission.whileInUse ||
                                _permissionStatus == LocationPermission.always
                            ? Colors.greenAccent
                            : Colors.orangeAccent,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Error Alert Banner ───────────────────────────────────────
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.redAccent),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: Colors.redAccent),
                          const SizedBox(width: 8),
                          Text(
                            'GPS ERROR [${_errorCode ?? "UNKNOWN"}]',
                            style: AppTextStyles.labelCaps(
                                color: Colors.redAccent),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _errorMessage!,
                        style: AppTextStyles.bodyMd(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // ── Telemetry Grid ──────────────────────────────────────────
              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HARDWARE TELEMETRY',
                        style: AppTextStyles.labelCaps(
                            color: AppColors.circuitOrange),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildTelemetryRow(
                        'Latitude:',
                        _currentPoint != null
                            ? _currentPoint!.latitude.toStringAsFixed(6)
                            : '--.------',
                      ),
                      _buildTelemetryRow(
                        'Longitude:',
                        _currentPoint != null
                            ? _currentPoint!.longitude.toStringAsFixed(6)
                            : '--.------',
                      ),
                      _buildTelemetryRow(
                        'Accuracy:',
                        _currentPoint != null
                            ? '${_currentPoint!.accuracy.toStringAsFixed(1)} meters'
                            : '-- m',
                        valueColor: _currentPoint != null
                            ? _accuracyColor(_currentPoint!.accuracy)
                            : null,
                      ),
                      _buildTelemetryRow(
                        'Speed:',
                        _currentPoint != null
                            ? '${_currentPoint!.speed.toStringAsFixed(1)} km/h'
                            : '-- km/h',
                      ),
                      _buildTelemetryRow(
                        'Heading:',
                        _currentPoint != null
                            ? '${_currentPoint!.heading.toStringAsFixed(1)}° (${_headingToDirection(_currentPoint!.heading)})'
                            : '--°',
                      ),
                      _buildTelemetryRow(
                        'Timestamp:',
                        _currentPoint != null
                            ? _formatTimestamp(_currentPoint!.timestamp)
                            : '--:--:--',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Control Actions ──────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      text: _isStreaming ? 'STOP STREAM' : 'START LIVE GPS',
                      onPressed: _isStreaming ? _stopStream : _startLiveStream,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: PrimaryButton(
                      text: 'GET FIX ONCE',
                      onPressed: _getOneTimeLocation,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.security, color: Colors.white),
                      label: const Text('PERMISSIONS',
                          style: TextStyle(color: Colors.white)),
                      onPressed: _requestPermission,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      label: const Text('SYS SETTINGS',
                          style: TextStyle(color: Colors.white)),
                      onPressed: () => platform.openAppSettings(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.location_on, color: AppColors.primary),
                  label: const Text('OPEN GPS SETTINGS',
                      style: TextStyle(color: AppColors.primary)),
                  onPressed: () => Geolocator.openLocationSettings(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
        Text(value, style: AppTextStyles.labelCaps(color: valueColor)),
      ],
    );
  }

  Widget _buildTelemetryRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
          Text(
            value,
            style: AppTextStyles.bodyMd(color: valueColor ?? Colors.white)
                .copyWith(fontWeight: FontWeight.bold),
          ),

        ],
      ),
    );
  }
}
