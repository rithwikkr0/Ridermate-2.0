import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ridermate/core/services/database_service.dart';
import 'package:ridermate/features/safety/models/emergency_contact_model.dart';
import 'package:ridermate/features/safety/repositories/emergency_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    SharedPreferences.setMockInitialValues({});
  });

  group('Emergency Contacts Schema Migration & CRUD Tests', () {
    test('1. Migration from legacy v8 schema to v9 preserves all contacts and maps phone_number correctly', () async {
      final db = await DatabaseService.instance.database;

      // 1. Simulate old legacy v8 table with 'phone' and 'relation' and 'order_index'
      await db.execute('DROP TABLE IF EXISTS emergency_contacts');
      await db.execute('''
        CREATE TABLE emergency_contacts (
          id          TEXT PRIMARY KEY,
          user_id     TEXT NOT NULL,
          name        TEXT NOT NULL,
          relation    TEXT NOT NULL,
          phone       TEXT NOT NULL,
          order_index INTEGER NOT NULL DEFAULT 0
        )
      ''');

      // Populate legacy data
      await db.insert('emergency_contacts', {
        'id': 'legacy_1',
        'user_id': 'user_A',
        'name': 'Hema',
        'relation': 'Friend',
        'phone': '8951563449',
        'order_index': 0,
      });

      await db.insert('emergency_contacts', {
        'id': 'legacy_2',
        'user_id': 'user_A',
        'name': 'Priya',
        'relation': 'Sister',
        'phone': '9876543210',
        'order_index': 1,
      });

      // 2. Perform Migration v9 on existing DB
      final tableInfo = await db.rawQuery("PRAGMA table_info(emergency_contacts)");
      final columnNames = tableInfo.map((row) => (row['name'] as String).toLowerCase()).toSet();
      expect(columnNames.contains('phone'), true);
      expect(columnNames.contains('phone_number'), false);

      // Safe SQLite table rebuild migration
      await db.execute('''
        CREATE TABLE IF NOT EXISTS emergency_contacts_v9_tmp (
          id           TEXT PRIMARY KEY,
          user_id      TEXT NOT NULL,
          name         TEXT NOT NULL,
          phone_number TEXT NOT NULL,
          relationship TEXT NOT NULL DEFAULT 'Contact',
          is_primary   INTEGER NOT NULL DEFAULT 0,
          created_at   TEXT NOT NULL,
          updated_at   TEXT NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )
      ''');

      final now = DateTime.now().toIso8601String();
      final oldRows = await db.query('emergency_contacts');
      for (final row in oldRows) {
        final id = row['id']?.toString() ?? 'c_\${DateTime.now().millisecondsSinceEpoch}';
        final userId = row['user_id']?.toString() ?? 'user_guest';
        final name = row['name']?.toString() ?? 'Contact';
        final phoneNum = row['phone_number']?.toString() ?? row['phone']?.toString() ?? '';
        final relation = row['relationship']?.toString() ?? row['relation']?.toString() ?? 'Contact';
        final isPrimaryVal = (row['is_primary'] == 1 || row['is_primary'] == true || row['order_index'] == 0) ? 1 : 0;
        final createdAt = row['created_at']?.toString() ?? now;
        final updatedAt = row['updated_at']?.toString() ?? now;

        await db.insert(
          'emergency_contacts_v9_tmp',
          {
            'id': id,
            'user_id': userId,
            'name': name,
            'phone_number': phoneNum,
            'relationship': relation,
            'is_primary': isPrimaryVal,
            'created_at': createdAt,
            'updated_at': updatedAt,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await db.execute('DROP TABLE emergency_contacts');
      await db.execute('ALTER TABLE emergency_contacts_v9_tmp RENAME TO emergency_contacts');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_emergency_contacts_user_id ON emergency_contacts(user_id)');

      // 3. Verify columns in new table
      final newTableInfo = await db.rawQuery("PRAGMA table_info(emergency_contacts)");
      final newColumnNames = newTableInfo.map((row) => (row['name'] as String).toLowerCase()).toSet();
      expect(newColumnNames.contains('phone_number'), true);
      expect(newColumnNames.contains('relationship'), true);
      expect(newColumnNames.contains('is_primary'), true);

      // 4. Verify existing records survived with correct column mapping
      final repo = SqliteEmergencyRepository();
      final contactsRes = await repo.getContacts(userId: 'user_A');
      expect(contactsRes.isSuccess, true);
      final contacts = contactsRes.dataOrNull!;
      expect(contacts.length, 2);

      final hema = contacts.firstWhere((c) => c.name == 'Hema');
      expect(hema.phoneNumber, '8951563449');
      expect(hema.relationship, 'Friend');
      expect(hema.isPrimary, true);

      final priya = contacts.firstWhere((c) => c.name == 'Priya');
      expect(priya.phoneNumber, '9876543210');
      expect(priya.relationship, 'Sister');
      expect(priya.isPrimary, false);
    });

    test('2. Insert new contact into migrated table succeeds without exception (Issue Reproduction Fix)', () async {
      final repo = SqliteEmergencyRepository();

      final newContact = EmergencyContact(
        id: 'contact_hema_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'user_A',
        name: 'Hema',
        phoneNumber: '8951563449',
        relationship: 'Friend',
        isPrimary: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final saveRes = await repo.saveContact(newContact);
      expect(saveRes.isSuccess, true);

      final fetched = (await repo.getContacts(userId: 'user_A')).dataOrNull!;
      expect(fetched.any((c) => c.name == 'Hema' && c.phoneNumber == '8951563449'), true);
    });

    test('3. Edit and Update contact persists correctly', () async {
      final repo = SqliteEmergencyRepository();
      final contacts = (await repo.getContacts(userId: 'user_A')).dataOrNull!;
      final hema = contacts.firstWhere((c) => c.name == 'Hema');

      final updatedHema = hema.copyWith(
        relationship: 'Best Friend',
        phoneNumber: '8951563449',
        updatedAt: DateTime.now(),
      );

      final updateRes = await repo.saveContact(updatedHema);
      expect(updateRes.isSuccess, true);

      final updatedList = (await repo.getContacts(userId: 'user_A')).dataOrNull!;
      final reloadedHema = updatedList.firstWhere((c) => c.id == hema.id);
      expect(reloadedHema.relationship, 'Best Friend');
    });

    test('4. Primary contact switching enforces single primary contact', () async {
      final repo = SqliteEmergencyRepository();

      // Add Contact B as non-primary
      final contactB = EmergencyContact(
        id: 'contact_b_1',
        userId: 'user_A',
        name: 'Rohan',
        phoneNumber: '9988776655',
        relationship: 'Brother',
        isPrimary: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await repo.saveContact(contactB);

      // Make Rohan primary via setPrimaryContact
      final setRes = await repo.setPrimaryContact('contact_b_1', userId: 'user_A');
      expect(setRes.isSuccess, true);

      final primaryContact = (await repo.getPrimaryContact(userId: 'user_A')).dataOrNull!;
      expect(primaryContact.id, 'contact_b_1');
      expect(primaryContact.name, 'Rohan');

      // Verify other contacts are no longer primary
      final allContacts = (await repo.getContacts(userId: 'user_A')).dataOrNull!;
      final otherContacts = allContacts.where((c) => c.id != 'contact_b_1');
      for (final other in otherContacts) {
        expect(other.isPrimary, false);
      }
    });

    test('5. Delete contact removes record cleanly', () async {
      final repo = SqliteEmergencyRepository();
      final delRes = await repo.deleteContact('contact_b_1', userId: 'user_A');
      expect(delRes.isSuccess, true);

      final remaining = (await repo.getContacts(userId: 'user_A')).dataOrNull!;
      expect(remaining.any((c) => c.id == 'contact_b_1'), false);
    });

    test('6. User Isolation: User A contacts are isolated from User B', () async {
      final repo = SqliteEmergencyRepository();

      // Create contact for User B
      final contactUserB = EmergencyContact(
        id: 'contact_user_b_1',
        userId: 'user_B',
        name: 'Vikram',
        phoneNumber: '9123456780',
        relationship: 'Father',
        isPrimary: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await repo.saveContact(contactUserB);

      final userAContacts = (await repo.getContacts(userId: 'user_A')).dataOrNull!;
      final userBContacts = (await repo.getContacts(userId: 'user_B')).dataOrNull!;

      expect(userAContacts.any((c) => c.userId == 'user_B'), false);
      expect(userBContacts.length, 1);
      expect(userBContacts.first.name, 'Vikram');
    });

    test('7. Database Schema Self-Check: All required tables and columns exist in DatabaseService', () async {
      final db = await DatabaseService.instance.database;

      final expectedTableColumns = {
        'emergency_contacts': {'id', 'user_id', 'name', 'phone_number', 'relationship', 'is_primary', 'created_at', 'updated_at'},
        'vehicles': {'id', 'user_id', 'brand', 'model', 'year', 'registration_number', 'fuel_type', 'engine_cc', 'color', 'odometer_km', 'is_primary'},
        'maintenance_records': {'id', 'vehicle_id', 'user_id', 'service_type', 'date', 'odometer', 'cost', 'workshop', 'notes'},
        'traffic_violations': {'id', 'user_id', 'type', 'severity', 'points', 'timestamp', 'speed', 'speed_limit'},
        'friendships': {'id', 'user_id', 'friend_id', 'status', 'created_at', 'updated_at'},
        'friend_requests': {'id', 'sender_id', 'receiver_id', 'status', 'created_at'},
        'memories': {'id', 'user_id', 'image_path', 'caption', 'created_at', 'updated_at'},
        'notifications': {'id', 'user_id', 'type', 'title', 'body', 'created_at'},
        'active_ride_draft': {'id', 'user_id', 'ride_mode', 'start_time', 'distance_km', 'max_speed'},
      };

      for (final entry in expectedTableColumns.entries) {
        final tableName = entry.key;
        final requiredCols = entry.value;

        final tableInfo = await db.rawQuery('PRAGMA table_info($tableName)');
        expect(tableInfo.isNotEmpty, true, reason: 'Table $tableName must exist in DatabaseService');

        final presentCols = tableInfo.map((row) => (row['name'] as String).toLowerCase()).toSet();
        for (final col in requiredCols) {
          expect(presentCols.contains(col.toLowerCase()), true,
              reason: 'Column $col must exist in table $tableName');
        }
      }
    });
  });
}
