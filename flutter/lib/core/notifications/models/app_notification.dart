import 'dart:convert';
import 'notification_type.dart';

/// RiderMate 2.0 — Canonical Notification Record Data Model
class AppNotification {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? route;
  final String? entityId;
  final NotificationPriority priority;
  final Map<String, dynamic>? payload;
  final String? imageUrl;
  final DateTime? expiresAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.readAt,
    this.route,
    this.entityId,
    this.priority = NotificationPriority.normal,
    this.payload,
    this.imageUrl,
    this.expiresAt,
  });

  bool get isRead => readAt != null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.name,
      'title': title,
      'body': body,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'route': route,
      'entity_id': entityId,
      'priority': priority.name,
      'payload': payload != null ? jsonEncode(payload) : null,
      'image_url': imageUrl,
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic>? parsedPayload;
    if (map['payload'] != null && map['payload'] is String && (map['payload'] as String).isNotEmpty) {
      try {
        parsedPayload = jsonDecode(map['payload'] as String) as Map<String, dynamic>?;
      } catch (_) {}
    } else if (map['payload'] is Map<String, dynamic>) {
      parsedPayload = map['payload'] as Map<String, dynamic>;
    }

    return AppNotification(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? '',
      type: NotificationType.fromString(map['type'] as String? ?? 'system'),
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      readAt: map['read_at'] != null ? DateTime.tryParse(map['read_at'] as String) : null,
      route: map['route'] as String?,
      entityId: map['entity_id'] as String?,
      priority: NotificationPriority.fromString(map['priority'] as String? ?? 'normal'),
      payload: parsedPayload,
      imageUrl: map['image_url'] as String?,
      expiresAt: map['expires_at'] != null ? DateTime.tryParse(map['expires_at'] as String) : null,
    );
  }

  AppNotification copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? body,
    DateTime? createdAt,
    DateTime? readAt,
    bool clearReadAt = false,
    String? route,
    String? entityId,
    NotificationPriority? priority,
    Map<String, dynamic>? payload,
    String? imageUrl,
    DateTime? expiresAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      readAt: clearReadAt ? null : (readAt ?? this.readAt),
      route: route ?? this.route,
      entityId: entityId ?? this.entityId,
      priority: priority ?? this.priority,
      payload: payload ?? this.payload,
      imageUrl: imageUrl ?? this.imageUrl,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
