import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ridermate/core/services/database_service.dart';
import 'package:ridermate/features/safety/models/emergency_contact_model.dart';
import 'package:ridermate/features/safety/models/sos_event_model.dart';
import 'package:ridermate/features/safety/repositories/emergency_repository.dart';
import 'package:ridermate/features/safety/services/emergency_sms_service.dart';
import 'package:ridermate/features/safety/controllers/sos_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    SharedPreferences.setMockInitialValues({'user_id': 'user_A', 'user_name': 'Test Rider'});
  });

  group('1. EmergencyContact & SosEventModel Tests', () {
    test('EmergencyContact serialization toMap and fromMap works correctly', () {
      final contact = EmergencyContact(
        id: 'c101',
        userId: 'u999',
        name: 'Ramesh Rider',
        phoneNumber: '+91 98765 43210',
        relationship: 'Father',
        isPrimary: true,
        createdAt: DateTime(2026, 8, 10, 10, 0),
        updatedAt: DateTime(2026, 8, 10, 10, 0),
      );

      final map = contact.toMap();
      expect(map['id'], 'c101');
      expect(map['user_id'], 'u999');
      expect(map['is_primary'], 1);

      final decoded = EmergencyContact.fromMap(map);
      expect(decoded.id, 'c101');
      expect(decoded.name, 'Ramesh Rider');
      expect(decoded.isPrimary, true);
    });

    test('SosEventModel serialization and status enum parsing work', () {
      final event = SosEventModel(
        id: 'sos_123',
        userId: 'u999',
        rideId: 'ride_55',
        status: SosStatus.active,
        latitude: 12.9716,
        longitude: 77.5946,
        accuracy: 10.5,
        startedAt: DateTime(2026, 8, 10, 12, 0),
        contactAttempts: ['SMS sent', 'Call placed'],
        message: 'Emergency Alert',
      );

      final map = event.toMap();
      expect(map['id'], 'sos_123');
      expect(map['status'], 'active');
      expect(map['contact_attempts'], '["SMS sent","Call placed"]');

      final decoded = SosEventModel.fromMap(map);
      expect(decoded.id, 'sos_123');
      expect(decoded.status, SosStatus.active);
      expect(decoded.contactAttempts.length, 2);
    });
  });

  group('2. SqliteEmergencyRepository User-Isolated Database Tests', () {
    late SqliteEmergencyRepository repository;

    setUp(() async {
      final db = await DatabaseService.instance.database;
      await db.execute('DROP TABLE IF EXISTS emergency_contacts');
      await db.execute('DROP TABLE IF EXISTS sos_events');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS emergency_contacts (
          id           TEXT PRIMARY KEY,
          user_id      TEXT NOT NULL,
          name         TEXT NOT NULL,
          phone_number TEXT NOT NULL,
          relationship TEXT NOT NULL DEFAULT 'Contact',
          is_primary   INTEGER NOT NULL DEFAULT 0,
          created_at   TEXT NOT NULL,
          updated_at   TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS sos_events (
          id                 TEXT PRIMARY KEY,
          user_id            TEXT NOT NULL,
          ride_id            TEXT,
          status             TEXT NOT NULL,
          latitude           REAL,
          longitude          REAL,
          accuracy           REAL,
          location_timestamp TEXT,
          started_at         TEXT NOT NULL,
          cancelled_at       TEXT,
          resolved_at        TEXT,
          contact_attempts   TEXT NOT NULL DEFAULT '[]',
          message            TEXT NOT NULL DEFAULT ''
        )
      ''');
      repository = SqliteEmergencyRepository();
    });

    test('Create, retrieve, set primary and delete contact with user isolation', () async {
      final c1 = EmergencyContact(
        id: 'c1',
        userId: 'user_A',
        name: 'Contact A',
        phoneNumber: '9876543210',
        relationship: 'Father',
        isPrimary: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final c2 = EmergencyContact(
        id: 'c2',
        userId: 'user_B',
        name: 'Contact B',
        phoneNumber: '9876543211',
        relationship: 'Friend',
        isPrimary: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final s1 = await repository.saveContact(c1);
      expect(s1.isSuccess, true, reason: s1.error?.message);

      final s2 = await repository.saveContact(c2);
      expect(s2.isSuccess, true, reason: s2.error?.message);

      // Verify user A only sees contact A
      final userAContacts = await repository.getContacts(userId: 'user_A');
      expect(userAContacts.isSuccess, true, reason: userAContacts.error?.message);
      expect(userAContacts.dataOrNull?.length, 1);
      expect(userAContacts.dataOrNull?.first.name, 'Contact A');

      // Verify user B only sees contact B
      final userBContacts = await repository.getContacts(userId: 'user_B');
      expect(userBContacts.isSuccess, true, reason: userBContacts.error?.message);
      expect(userBContacts.dataOrNull?.length, 1);
      expect(userBContacts.dataOrNull?.first.name, 'Contact B');

      // Verify primary contact
      final primaryA = await repository.getPrimaryContact(userId: 'user_A');
      expect(primaryA.isSuccess, true);
      expect(primaryA.dataOrNull?.id, 'c1');

      // Delete contact A
      final delRes = await repository.deleteContact('c1', userId: 'user_A');
      expect(delRes.isSuccess, true);
      expect(delRes.dataOrNull, true);

      final userAEmpty = await repository.getContacts(userId: 'user_A');
      expect(userAEmpty.isSuccess, true);
      expect(userAEmpty.dataOrNull?.isEmpty, true);
    });

    test('Save and query active and historical SosEventModel', () async {
      final eventActive = SosEventModel(
        id: 'sos_act',
        userId: 'user_A',
        status: SosStatus.active,
        latitude: 12.91,
        longitude: 77.61,
        startedAt: DateTime.now(),
      );

      final saveRes = await repository.saveSosEvent(eventActive);
      expect(saveRes.isSuccess, true, reason: saveRes.error?.message);

      final activeRes = await repository.getActiveSosEvent(userId: 'user_A');
      expect(activeRes.isSuccess, true, reason: activeRes.error?.message);
      expect(activeRes.dataOrNull, isNotNull);
      expect(activeRes.dataOrNull?.id, 'sos_act');

      // Resolve event
      final eventResolved = eventActive.copyWith(
        status: SosStatus.completed,
        resolvedAt: DateTime.now(),
      );
      await repository.updateSosEvent(eventResolved);

      final activeAfter = await repository.getActiveSosEvent(userId: 'user_A');
      expect(activeAfter.isSuccess, true);
      expect(activeAfter.dataOrNull, isNull);

      final allEvents = await repository.getSosEvents(userId: 'user_A');
      expect(allEvents.isSuccess, true);
      expect(allEvents.dataOrNull?.length, 1);
      expect(allEvents.dataOrNull?.first.status, SosStatus.completed);
    });
  });

  group('3. EmergencySmsService & SosController State Machine Tests', () {
    test('EmergencySmsService builds valid message with location link', () {
      const smsService = EmergencySmsService();
      final msg = smsService.buildEmergencyMessage(
        riderName: 'Test Rider',
        latitude: 12.9716,
        longitude: 77.5946,
        timestamp: DateTime(2026, 8, 10, 15, 30),
        rideDistanceKm: 15.4,
      );

      expect(msg.contains('RIDERMATE EMERGENCY ALERT'), true);
      expect(msg.contains('Test Rider'), true);
      expect(msg.contains('https://maps.google.com/?q=12.9716,77.5946'), true);
      expect(msg.contains('15.4 km'), true);
    });

    test('SosController trigger, countdown and cancel sequence', () {
      final controller = SosController();
      expect(controller.sosState, SosState.idle);

      controller.triggerSos();
      expect(controller.sosState, SosState.countdown);
      expect(controller.countdownSeconds, 5);

      controller.cancelSos();
      expect(controller.sosState, SosState.cancelled);

      controller.dispose();
    });
  });
}
