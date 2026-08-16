import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Singleton SQLite database helper for RiderMate 2.0.
/// Owns the single `ridermate.db` connection shared across all repositories.
/// Schema migrations are handled via the `version` and `onUpgrade` callbacks.
class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Database? _database;

  Future<Database> get database async =>
      _database ??= await _openDatabase();

  static const int _version = 11;

  Future<Database> _openDatabase() async {
    final path = join(await getDatabasesPath(), 'ridermate.db');
    return openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // ── Users / Auth ─────────────────────────────────────
    await db.execute('''
      CREATE TABLE users (
        id           TEXT PRIMARY KEY,
        username     TEXT NOT NULL UNIQUE,
        full_name    TEXT NOT NULL,
        email        TEXT NOT NULL UNIQUE,
        phone        TEXT NOT NULL DEFAULT '',
        photo_url    TEXT NOT NULL DEFAULT '',
        bio          TEXT NOT NULL DEFAULT '',
        rider_level  TEXT NOT NULL DEFAULT 'Novice',
        xp           INTEGER NOT NULL DEFAULT 0,
        distance_km  REAL NOT NULL DEFAULT 0.0,
        total_rides  INTEGER NOT NULL DEFAULT 0,
        achievements TEXT NOT NULL DEFAULT '[]',
        preferences  TEXT NOT NULL DEFAULT '{}',
        password_hash TEXT NOT NULL,
        created_at   TEXT NOT NULL,
        updated_at   TEXT NOT NULL
      )
    ''');

    // ── Rides ─────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE rides (
        id               TEXT PRIMARY KEY,
        title            TEXT NOT NULL,
        vehicle          TEXT NOT NULL DEFAULT '',
        start_time       INTEGER NOT NULL,
        end_time         INTEGER,
        duration_seconds INTEGER NOT NULL DEFAULT 0,
        distance_km      REAL NOT NULL DEFAULT 0.0,
        average_speed    REAL NOT NULL DEFAULT 0.0,
        max_speed        REAL NOT NULL DEFAULT 0.0,
        elevation        REAL NOT NULL DEFAULT 0.0,
        calories         INTEGER NOT NULL DEFAULT 0,
        weather          TEXT NOT NULL DEFAULT '',
        ride_score       INTEGER NOT NULL DEFAULT 0,
        status           TEXT NOT NULL DEFAULT 'completed',
        ride_mode        TEXT NOT NULL DEFAULT 'solo',
        user_id          TEXT NOT NULL DEFAULT '',
        origin           TEXT NOT NULL DEFAULT '',
        destination      TEXT NOT NULL DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE ride_points (
        ride_id     TEXT NOT NULL,
        point_index INTEGER NOT NULL,
        latitude    REAL NOT NULL,
        longitude   REAL NOT NULL,
        speed       REAL NOT NULL DEFAULT 0.0,
        timestamp   INTEGER NOT NULL,
        elevation   REAL NOT NULL DEFAULT 0.0,
        heading     REAL NOT NULL DEFAULT 0.0,
        accuracy    REAL NOT NULL DEFAULT 0.0,
        PRIMARY KEY (ride_id, point_index),
        FOREIGN KEY (ride_id) REFERENCES rides(id) ON DELETE CASCADE
      )
    ''');

    // ── Vehicles & Garage ──────────────────────────────────
    await _createGarageAndVehicleTables(db);

    // ── Emergency & SOS ───────────────────────────────────
    await _createEmergencyTables(db);

    // ── Traffic & Violations ──────────────────────────────
    await _createTrafficTables(db);

    // ── Friendships & Social ──────────────────────────────
    await _createFriendshipTables(db);

    // ── Community Social System (Posts, Likes, Comments, Squads, Stories)
    await _createCommunitySocialTables(db);

    // ── Memories ──────────────────────────────────────────
    await _createMemoriesTable(db);

    // ── Notifications ─────────────────────────────────────
    await _createNotificationsTables(db);

    // ── Active Ride Cold-Start Draft ──────────────────────
    await _createActiveRideDraftTables(db);

    // ── Gamification ──────────────────────────────────────
    await _createGamificationTables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 11) {
      await _createGamificationTables(db);
    }
    if (oldVersion < 10) {
      await _createCommunitySocialTables(db);
    }
    // Migration to version 9:
    // 1. Rebuild emergency_contacts table if it has old column schema ('phone' instead of 'phone_number')
    // 2. Guarantee all tables and columns are created without data loss.
    if (oldVersion < 9) {
      await _createGarageAndVehicleTables(db);
      await _createEmergencyTables(db);
      await _createNotificationsTables(db);
      await _createTrafficTables(db);
      await _createFriendshipTables(db);
      await _createMemoriesTable(db);
      await _createActiveRideDraftTables(db);

      try {
        final tableInfo = await db.rawQuery("PRAGMA table_info(emergency_contacts)");
        final columnNames = tableInfo.map((row) => (row['name'] as String).toLowerCase()).toSet();

        final hasPhoneNumber = columnNames.contains('phone_number');
        final hasPhone = columnNames.contains('phone');

        if (hasPhone || !hasPhoneNumber) {
          // Perform safe SQLite table rebuild migration to preserve all user data
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
        }
      } catch (_) {
        await _createEmergencyTables(db);
      }

      // Extend vehicles table columns if not present
      try {
        await db.execute("ALTER TABLE vehicles ADD COLUMN variant TEXT NOT NULL DEFAULT ''");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE vehicles ADD COLUMN odometer_km REAL NOT NULL DEFAULT 0.0");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE vehicles ADD COLUMN purchase_date TEXT");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE vehicles ADD COLUMN insurance_expiry TEXT");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE vehicles ADD COLUMN puc_expiry TEXT");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE vehicles ADD COLUMN last_service_date TEXT");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE vehicles ADD COLUMN next_service_date TEXT");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE vehicles ADD COLUMN last_service_odometer REAL NOT NULL DEFAULT 0.0");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE vehicles ADD COLUMN service_interval_km REAL NOT NULL DEFAULT 5000.0");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE vehicles ADD COLUMN service_interval_days INTEGER NOT NULL DEFAULT 180");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE vehicles ADD COLUMN is_primary INTEGER NOT NULL DEFAULT 0");
      } catch (_) {}
    }
    if (oldVersion < 8) {
      try {
        await _createActiveRideDraftTables(db);
      } catch (_) {}
    }
    // Migration from version 1 (SqliteRideRepository schema) to version 2
    if (oldVersion < 2) {
      // Users and contacts table — new in v2
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS users (
            id            TEXT PRIMARY KEY,
            username      TEXT NOT NULL UNIQUE,
            full_name     TEXT NOT NULL,
            email         TEXT NOT NULL UNIQUE,
            phone         TEXT NOT NULL DEFAULT '',
            photo_url     TEXT NOT NULL DEFAULT '',
            bio           TEXT NOT NULL DEFAULT '',
            rider_level   TEXT NOT NULL DEFAULT 'Novice',
            xp            INTEGER NOT NULL DEFAULT 0,
            distance_km   REAL NOT NULL DEFAULT 0.0,
            total_rides   INTEGER NOT NULL DEFAULT 0,
            achievements  TEXT NOT NULL DEFAULT '[]',
            preferences   TEXT NOT NULL DEFAULT '{}',
            password_hash TEXT NOT NULL,
            created_at    TEXT NOT NULL,
            updated_at    TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS vehicles (
            id                   TEXT PRIMARY KEY,
            user_id              TEXT NOT NULL,
            brand                TEXT NOT NULL,
            model                TEXT NOT NULL,
            year                 INTEGER NOT NULL,
            registration_number  TEXT NOT NULL DEFAULT '',
            fuel_type            TEXT NOT NULL DEFAULT 'Petrol',
            engine_cc            INTEGER NOT NULL DEFAULT 0,
            color                TEXT NOT NULL DEFAULT '',
            service_due_date     TEXT,
            is_default           INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS emergency_contacts (
            id          TEXT PRIMARY KEY,
            user_id     TEXT NOT NULL,
            name        TEXT NOT NULL,
            relation    TEXT NOT NULL,
            phone       TEXT NOT NULL,
            order_index INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
          )
        ''');
      } catch (_) {
        // Tables may already exist in some edge cases
      }
    }

    // Migration from version 2 to version 3
    // Adds ride_mode, user_id, origin, destination to the rides table
    if (oldVersion < 3) {
      try {
        await db.execute(
            "ALTER TABLE rides ADD COLUMN ride_mode TEXT NOT NULL DEFAULT 'solo'");
      } catch (_) {}
      try {
        await db.execute(
            "ALTER TABLE rides ADD COLUMN user_id TEXT NOT NULL DEFAULT ''");
      } catch (_) {}
      try {
        await db.execute(
            "ALTER TABLE rides ADD COLUMN origin TEXT NOT NULL DEFAULT ''");
      } catch (_) {}
      try {
        await db.execute(
            "ALTER TABLE rides ADD COLUMN destination TEXT NOT NULL DEFAULT ''");
      } catch (_) {}
    }

    // Migration from version 3 to version 4
    // Adds memories table and indexes
    if (oldVersion < 4) {
      await _createMemoriesTable(db);
    }

    // Migration from version 4 to version 5
    // Adds emergency_contacts and sos_events tables and indexes
    if (oldVersion < 5) {
      await _createEmergencyTables(db);
      try {
        await db.execute(
            "ALTER TABLE emergency_contacts ADD COLUMN is_primary INTEGER NOT NULL DEFAULT 0");
      } catch (_) {}
    }

    // Migration from version 5 to version 6
    // Adds notifications and notification_preferences tables and indexes
    if (oldVersion < 6) {
      await _createNotificationsTables(db);
    }

    // Migration from version 6 to version 7
    // Adds maintenance_records, traffic_violations, friendships, friend_requests,
    // and extends vehicles & memories tables.
    if (oldVersion < 7) {
      await _createGarageAndVehicleTables(db);
      await _createTrafficTables(db);
      await _createFriendshipTables(db);

      // Extend vehicles table columns if not present
      try {
        await db.execute("ALTER TABLE vehicles ADD COLUMN variant TEXT NOT NULL DEFAULT ''");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE vehicles ADD COLUMN odometer_km REAL NOT NULL DEFAULT 0.0");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE vehicles ADD COLUMN purchase_date TEXT");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE vehicles ADD COLUMN insurance_expiry TEXT");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE vehicles ADD COLUMN puc_expiry TEXT");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE vehicles ADD COLUMN last_service_date TEXT");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE vehicles ADD COLUMN next_service_date TEXT");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE vehicles ADD COLUMN last_service_odometer REAL NOT NULL DEFAULT 0.0");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE vehicles ADD COLUMN service_interval_km REAL NOT NULL DEFAULT 5000.0");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE vehicles ADD COLUMN service_interval_days INTEGER NOT NULL DEFAULT 180");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE vehicles ADD COLUMN is_primary INTEGER NOT NULL DEFAULT 0");
      } catch (_) {}

      // Extend memories table
      try {
        await db.execute("ALTER TABLE memories ADD COLUMN share_with_friends INTEGER NOT NULL DEFAULT 0");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE memories ADD COLUMN synced_to_cloud INTEGER NOT NULL DEFAULT 0");
      } catch (_) {}
    }
  }

  static Future<void> _createMemoriesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS memories (
        id             TEXT PRIMARY KEY,
        user_id        TEXT NOT NULL,
        ride_id        TEXT,
        image_path     TEXT NOT NULL,
        thumbnail_path TEXT,
        caption        TEXT NOT NULL DEFAULT '',
        latitude       REAL,
        longitude      REAL,
        location_name  TEXT,
        created_at     TEXT NOT NULL,
        updated_at     TEXT NOT NULL,
        privacy        TEXT NOT NULL DEFAULT 'private',
        ride_distance  REAL,
        ride_duration  INTEGER
      )
    ''');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_memories_user_id ON memories(user_id)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_memories_created_at ON memories(created_at)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_memories_ride_id ON memories(ride_id)');
  }

  static Future<void> _createEmergencyTables(Database db) async {
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
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_emergency_contacts_user_id ON emergency_contacts(user_id)');

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
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_sos_events_user_id ON sos_events(user_id)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_sos_events_created_at ON sos_events(started_at)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_sos_events_status ON sos_events(status)');
  }

  static Future<void> _createNotificationsTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS notifications (
        id         TEXT PRIMARY KEY,
        user_id    TEXT NOT NULL,
        type       TEXT NOT NULL,
        title      TEXT NOT NULL,
        body       TEXT NOT NULL,
        created_at TEXT NOT NULL,
        read_at    TEXT,
        route      TEXT,
        entity_id  TEXT,
        priority   TEXT NOT NULL DEFAULT 'normal',
        payload    TEXT,
        image_url  TEXT,
        expires_at TEXT
      )
    ''');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_notifications_read_at ON notifications(read_at)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_notifications_type ON notifications(type)');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS notification_preferences (
        user_id             TEXT PRIMARY KEY,
        emergency_enabled   INTEGER NOT NULL DEFAULT 1,
        safety_enabled      INTEGER NOT NULL DEFAULT 1,
        ride_enabled        INTEGER NOT NULL DEFAULT 1,
        social_enabled      INTEGER NOT NULL DEFAULT 1,
        ai_enabled          INTEGER NOT NULL DEFAULT 1,
        maintenance_enabled INTEGER NOT NULL DEFAULT 1,
        achievement_enabled INTEGER NOT NULL DEFAULT 1,
        system_enabled      INTEGER NOT NULL DEFAULT 1,
        sound_enabled       INTEGER NOT NULL DEFAULT 1,
        vibration_enabled   INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }

  static Future<void> _createGarageAndVehicleTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS vehicles (
        id                   TEXT PRIMARY KEY,
        user_id              TEXT NOT NULL,
        brand                TEXT NOT NULL,
        model                TEXT NOT NULL,
        variant              TEXT NOT NULL DEFAULT '',
        year                 INTEGER NOT NULL,
        registration_number  TEXT NOT NULL DEFAULT '',
        fuel_type            TEXT NOT NULL DEFAULT 'Petrol',
        engine_cc            INTEGER NOT NULL DEFAULT 0,
        color                TEXT NOT NULL DEFAULT '',
        odometer_km          REAL NOT NULL DEFAULT 0.0,
        purchase_date        TEXT,
        insurance_expiry     TEXT,
        puc_expiry           TEXT,
        last_service_date    TEXT,
        next_service_date    TEXT,
        last_service_odometer REAL NOT NULL DEFAULT 0.0,
        service_interval_km  REAL NOT NULL DEFAULT 5000.0,
        service_interval_days INTEGER NOT NULL DEFAULT 180,
        is_default           INTEGER NOT NULL DEFAULT 0,
        is_primary           INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_vehicles_user_id ON vehicles(user_id)');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS maintenance_records (
        id                  TEXT PRIMARY KEY,
        vehicle_id          TEXT NOT NULL,
        user_id             TEXT NOT NULL,
        service_type        TEXT NOT NULL,
        date                TEXT NOT NULL,
        odometer            REAL NOT NULL DEFAULT 0.0,
        cost                REAL NOT NULL DEFAULT 0.0,
        workshop            TEXT NOT NULL DEFAULT '',
        notes               TEXT NOT NULL DEFAULT '',
        parts_replaced_json TEXT NOT NULL DEFAULT '[]',
        created_at          TEXT NOT NULL,
        FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_maintenance_vehicle_id ON maintenance_records(vehicle_id)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_maintenance_user_id ON maintenance_records(user_id)');
  }

  static Future<void> _createTrafficTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS traffic_violations (
        id          TEXT PRIMARY KEY,
        user_id     TEXT NOT NULL,
        ride_id     TEXT,
        vehicle_id  TEXT,
        type        TEXT NOT NULL,
        severity    TEXT NOT NULL DEFAULT 'low',
        points      INTEGER NOT NULL DEFAULT 0,
        timestamp   TEXT NOT NULL,
        latitude    REAL,
        longitude   REAL,
        speed       REAL NOT NULL DEFAULT 0.0,
        speed_limit REAL NOT NULL DEFAULT 80.0,
        confidence  REAL NOT NULL DEFAULT 1.0,
        source      TEXT NOT NULL DEFAULT 'telemetry',
        evidence    TEXT NOT NULL DEFAULT '',
        status      TEXT NOT NULL DEFAULT 'active',
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_traffic_violations_user_id ON traffic_violations(user_id)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_traffic_violations_timestamp ON traffic_violations(timestamp)');
  }

  static Future<void> _createFriendshipTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS friendships (
        id         TEXT PRIMARY KEY,
        user_id    TEXT NOT NULL,
        friend_id  TEXT NOT NULL,
        status     TEXT NOT NULL DEFAULT 'accepted',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_friendships_user_id ON friendships(user_id)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_friendships_friend_id ON friendships(friend_id)');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS friend_requests (
        id          TEXT PRIMARY KEY,
        sender_id   TEXT NOT NULL,
        receiver_id TEXT NOT NULL,
        status      TEXT NOT NULL DEFAULT 'pending',
        created_at  TEXT NOT NULL
      )
    ''');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_friend_requests_receiver ON friend_requests(receiver_id)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_friend_requests_sender ON friend_requests(sender_id)');
  }

  Future<void> _createActiveRideDraftTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS active_ride_draft (
        id              TEXT PRIMARY KEY,
        user_id         TEXT NOT NULL,
        ride_mode       TEXT NOT NULL DEFAULT 'solo',
        origin          TEXT NOT NULL DEFAULT '',
        destination     TEXT NOT NULL DEFAULT '',
        start_time      INTEGER NOT NULL,
        paused_total_ms INTEGER NOT NULL DEFAULT 0,
        is_paused       INTEGER NOT NULL DEFAULT 0,
        paused_at       INTEGER,
        distance_km     REAL NOT NULL DEFAULT 0.0,
        max_speed       REAL NOT NULL DEFAULT 0.0,
        updated_at      INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS active_ride_points (
        draft_id    TEXT NOT NULL,
        point_index INTEGER NOT NULL,
        latitude    REAL NOT NULL,
        longitude   REAL NOT NULL,
        speed       REAL NOT NULL DEFAULT 0.0,
        timestamp   INTEGER NOT NULL,
        elevation   REAL NOT NULL DEFAULT 0.0,
        heading     REAL NOT NULL DEFAULT 0.0,
        accuracy    REAL NOT NULL DEFAULT 0.0,
        PRIMARY KEY (draft_id, point_index),
        FOREIGN KEY (draft_id) REFERENCES active_ride_draft(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> _createCommunitySocialTables(Database db) async {
    // ── Social Posts ───────────────────────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS social_posts (
        id            TEXT PRIMARY KEY,
        user_id       TEXT NOT NULL,
        author_name   TEXT NOT NULL,
        author_avatar TEXT NOT NULL DEFAULT '',
        type          TEXT NOT NULL DEFAULT 'text',
        caption       TEXT NOT NULL DEFAULT '',
        media_url     TEXT NOT NULL DEFAULT '',
        thumbnail_url TEXT NOT NULL DEFAULT '',
        ride_id       TEXT,
        memory_id     TEXT,
        privacy       TEXT NOT NULL DEFAULT 'friends',
        like_count    INTEGER NOT NULL DEFAULT 0,
        comment_count INTEGER NOT NULL DEFAULT 0,
        share_count   INTEGER NOT NULL DEFAULT 0,
        save_count    INTEGER NOT NULL DEFAULT 0,
        status        TEXT NOT NULL DEFAULT 'active',
        created_at    TEXT NOT NULL,
        updated_at    TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_social_posts_user_id ON social_posts(user_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_social_posts_created_at ON social_posts(created_at)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_social_posts_privacy ON social_posts(privacy)');

    // ── Post Likes ─────────────────────────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS post_likes (
        id         TEXT PRIMARY KEY,
        post_id    TEXT NOT NULL,
        user_id    TEXT NOT NULL,
        created_at TEXT NOT NULL,
        UNIQUE(post_id, user_id),
        FOREIGN KEY (post_id) REFERENCES social_posts(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_post_likes_post_id ON post_likes(post_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_post_likes_user_id ON post_likes(user_id)');

    // ── Comments ───────────────────────────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS comments (
        id                TEXT PRIMARY KEY,
        post_id           TEXT NOT NULL,
        user_id           TEXT NOT NULL,
        author_name       TEXT NOT NULL,
        author_avatar     TEXT NOT NULL DEFAULT '',
        text              TEXT NOT NULL,
        parent_comment_id TEXT,
        created_at        TEXT NOT NULL,
        updated_at        TEXT NOT NULL,
        FOREIGN KEY (post_id) REFERENCES social_posts(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_comments_post_id ON comments(post_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_comments_user_id ON comments(user_id)');

    // ── Saved Posts ────────────────────────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS saved_posts (
        id         TEXT PRIMARY KEY,
        user_id    TEXT NOT NULL,
        post_id    TEXT NOT NULL,
        created_at TEXT NOT NULL,
        UNIQUE(user_id, post_id),
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (post_id) REFERENCES social_posts(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_saved_posts_user_id ON saved_posts(user_id)');

    // ── Squads / Clubs ─────────────────────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS squads (
        id           TEXT PRIMARY KEY,
        creator_id   TEXT NOT NULL,
        name         TEXT NOT NULL,
        description  TEXT NOT NULL DEFAULT '',
        avatar_url   TEXT NOT NULL DEFAULT '',
        member_count INTEGER NOT NULL DEFAULT 1,
        is_private   INTEGER NOT NULL DEFAULT 0,
        invite_code  TEXT NOT NULL UNIQUE,
        created_at   TEXT NOT NULL,
        updated_at   TEXT NOT NULL,
        FOREIGN KEY (creator_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_squads_creator_id ON squads(creator_id)');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS squad_members (
        id        TEXT PRIMARY KEY,
        squad_id  TEXT NOT NULL,
        user_id   TEXT NOT NULL,
        role      TEXT NOT NULL DEFAULT 'member',
        joined_at TEXT NOT NULL,
        UNIQUE(squad_id, user_id),
        FOREIGN KEY (squad_id) REFERENCES squads(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_squad_members_squad_id ON squad_members(squad_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_squad_members_user_id ON squad_members(user_id)');

    // ── Group Rides ────────────────────────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS group_rides (
        id             TEXT PRIMARY KEY,
        squad_id       TEXT,
        creator_id     TEXT NOT NULL,
        title          TEXT NOT NULL,
        description    TEXT NOT NULL DEFAULT '',
        start_time     TEXT NOT NULL,
        start_location TEXT NOT NULL DEFAULT '',
        destination    TEXT NOT NULL DEFAULT '',
        status         TEXT NOT NULL DEFAULT 'upcoming',
        privacy        TEXT NOT NULL DEFAULT 'squad',
        created_at     TEXT NOT NULL,
        FOREIGN KEY (creator_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_group_rides_creator ON group_rides(creator_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_group_rides_status ON group_rides(status)');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS group_ride_members (
        id                  TEXT PRIMARY KEY,
        group_ride_id       TEXT NOT NULL,
        user_id             TEXT NOT NULL,
        status              TEXT NOT NULL DEFAULT 'joined',
        is_sharing_location INTEGER NOT NULL DEFAULT 0,
        last_latitude       REAL,
        last_longitude      REAL,
        last_updated        TEXT,
        UNIQUE(group_ride_id, user_id),
        FOREIGN KEY (group_ride_id) REFERENCES group_rides(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_group_ride_members ON group_ride_members(group_ride_id, user_id)');

    // ── Moderation Reports & Blocked Users ─────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS reports (
        id                 TEXT PRIMARY KEY,
        reporter_id        TEXT NOT NULL,
        reported_item_id   TEXT NOT NULL,
        reported_item_type TEXT NOT NULL,
        reason             TEXT NOT NULL,
        details            TEXT NOT NULL DEFAULT '',
        status             TEXT NOT NULL DEFAULT 'pending',
        created_at         TEXT NOT NULL,
        FOREIGN KEY (reporter_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_reports_item ON reports(reported_item_id)');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS blocked_users (
        id              TEXT PRIMARY KEY,
        user_id         TEXT NOT NULL,
        blocked_user_id TEXT NOT NULL,
        created_at      TEXT NOT NULL,
        UNIQUE(user_id, blocked_user_id),
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (blocked_user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_blocked_users ON blocked_users(user_id, blocked_user_id)');

    // ── Stories / Moments ──────────────────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS stories (
        id            TEXT PRIMARY KEY,
        user_id       TEXT NOT NULL,
        author_name   TEXT NOT NULL,
        author_avatar TEXT NOT NULL DEFAULT '',
        media_url     TEXT NOT NULL,
        caption       TEXT NOT NULL DEFAULT '',
        created_at    TEXT NOT NULL,
        expires_at    TEXT NOT NULL,
        privacy       TEXT NOT NULL DEFAULT 'friends',
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_stories_user_id ON stories(user_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_stories_expires_at ON stories(expires_at)');

    // ── Offline Sync Queue ─────────────────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS offline_sync_queue (
        id           TEXT PRIMARY KEY,
        user_id      TEXT NOT NULL,
        action_type  TEXT NOT NULL,
        payload_json TEXT NOT NULL,
        status       TEXT NOT NULL DEFAULT 'pending',
        created_at   TEXT NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_sync_queue_user_id ON offline_sync_queue(user_id)');
  }

  /// Closes the database connection. Call only on app dispose.
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
