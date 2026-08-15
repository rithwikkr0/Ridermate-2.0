import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// RiderMate 2.0 — Android POST_NOTIFICATIONS Runtime Permission Service
///
/// Android 13+ (API 33+) requires explicit runtime permission for notifications.
/// This service handles the full permission lifecycle:
///   not_requested → granted
///   not_requested → denied
///   denied → permanently_denied → settings deeplink
class NotificationPermissionService {
  static final NotificationPermissionService instance =
      NotificationPermissionService._();
  NotificationPermissionService._();

  /// Returns true if the current platform requires and has granted
  /// notification permission (Android 13+ API 33+).
  /// On Android < 13, always returns true (no runtime permission needed).
  Future<bool> isPermissionGranted() async {
    if (!Platform.isAndroid) return true;
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  /// Returns true if permission was previously denied and is now
  /// permanently denied (user selected "Don't ask again").
  Future<bool> isPermanentlyDenied() async {
    if (!Platform.isAndroid) return false;
    final status = await Permission.notification.status;
    return status.isPermanentlyDenied;
  }

  /// Requests notification permission.
  ///
  /// Returns [PermissionResult] indicating granted, denied, or permanentlyDenied.
  /// Only requests once per session — if already granted, returns immediately.
  Future<PermissionResult> requestPermission() async {
    if (!Platform.isAndroid) return PermissionResult.granted;

    final currentStatus = await Permission.notification.status;
    if (currentStatus.isGranted) return PermissionResult.granted;
    if (currentStatus.isPermanentlyDenied) return PermissionResult.permanentlyDenied;

    final result = await Permission.notification.request();
    if (result.isGranted) return PermissionResult.granted;
    if (result.isPermanentlyDenied) return PermissionResult.permanentlyDenied;
    return PermissionResult.denied;
  }

  /// Opens the Android app notification settings page.
  /// Call this when permission is permanently denied to guide the user.
  Future<void> openSettings() async {
    await openAppSettings();
  }

  /// Shows a rationale dialog explaining why notifications are needed,
  /// then requests the permission.
  ///
  /// Returns [PermissionResult] after user responds to both dialog and system prompt.
  Future<PermissionResult> requestWithRationale(BuildContext context) async {
    if (!Platform.isAndroid) return PermissionResult.granted;

    final alreadyGranted = await isPermissionGranted();
    if (alreadyGranted) return PermissionResult.granted;

    final permanentlyDenied = await isPermanentlyDenied();
    if (permanentlyDenied) {
      if (context.mounted) {
        await _showPermanentlyDeniedDialog(context);
      }
      return PermissionResult.permanentlyDenied;
    }

    // Show rationale
    if (context.mounted) {
      final proceed = await _showRationaleDialog(context);
      if (!proceed) return PermissionResult.denied;
    }

    return requestPermission();
  }

  Future<bool> _showRationaleDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.notifications_active, color: Color(0xFFFF6B00)),
            const SizedBox(width: 8),
            const Text(
              'Enable Notifications',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'RiderMate needs notifications to alert you about:\n\n'
          '🚨  Emergency SOS alerts\n'
          '⚡  Safety warnings during rides\n'
          '🏍️  Ride start/stop events\n'
          '🔧  Maintenance reminders\n\n'
          'Emergency alerts cannot be disabled for your safety.',
          style: TextStyle(color: Color(0xFFAAAAAA), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Skip', style: TextStyle(color: Color(0xFF8E8E93))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B00),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Allow Notifications', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _showPermanentlyDeniedDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Notifications Blocked',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Notification permission was permanently denied. To enable emergency SOS alerts and ride notifications, please allow notifications in Settings.',
          style: TextStyle(color: Color(0xFFAAAAAA), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8E8E93))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B00),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              openSettings();
            },
            child: const Text('Open Settings', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

enum PermissionResult { granted, denied, permanentlyDenied }
