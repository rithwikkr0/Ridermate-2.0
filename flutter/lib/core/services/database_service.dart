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

  static const int _version = 6;

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

    await db.execute('''
      CREATE TABLE vehicles (
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
      CREATE TABLE emergency_contacts (
        id          TEXT PRIMARY KEY,
        user_id     TEXT NOT NULL,
        name        TEXT NOT NULL,
        relation    TEXT NOT NULL,
        phone       TEXT NOT NULL,
        order_index INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
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

    // ── Memories ──────────────────────────────────────────
    await _createMemoriesTable(db);

    // ── Emergency & SOS ───────────────────────────────────
    await _createEmergencyTables(db);

    // ── Notifications ─────────────────────────────────────
    await _createNotificationsTables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
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

  /// Closes the database connection. Call only on app dispose.
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
