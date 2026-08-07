-- =============================================================
-- RiderMate 2.0 — PostgreSQL Schema Migration V1
-- Target: Supabase Free Tier (postgres)
-- =============================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================
-- USERS
-- =====================
CREATE TABLE IF NOT EXISTS users (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email        TEXT UNIQUE NOT NULL,
  username     TEXT UNIQUE NOT NULL,
  full_name    TEXT NOT NULL,
  phone        TEXT,
  rider_level  TEXT DEFAULT 'Beginner',
  xp           INTEGER DEFAULT 0,
  bio          TEXT,
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  updated_at   TIMESTAMPTZ DEFAULT NOW()
);

-- =====================
-- VEHICLES
-- =====================
CREATE TABLE IF NOT EXISTS vehicles (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id         UUID REFERENCES users(id) ON DELETE CASCADE,
  brand           TEXT NOT NULL,
  model           TEXT NOT NULL,
  year            INTEGER,
  registration_no TEXT,
  color           TEXT,
  is_default      BOOLEAN DEFAULT FALSE,
  odometer_km     DOUBLE PRECISION DEFAULT 0,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- =====================
-- RIDES
-- =====================
CREATE TABLE IF NOT EXISTS rides (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id         UUID REFERENCES users(id) ON DELETE CASCADE,
  vehicle_id      UUID REFERENCES vehicles(id),
  title           TEXT,
  started_at      TIMESTAMPTZ NOT NULL,
  ended_at        TIMESTAMPTZ,
  distance_km     DOUBLE PRECISION DEFAULT 0,
  avg_speed_kmh   DOUBLE PRECISION DEFAULT 0,
  max_speed_kmh   DOUBLE PRECISION DEFAULT 0,
  duration_secs   INTEGER DEFAULT 0,
  safety_score    INTEGER DEFAULT 100,
  calories        INTEGER DEFAULT 0,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- =====================
-- RIDE POINTS (GPS telemetry)
-- =====================
CREATE TABLE IF NOT EXISTS ride_points (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  ride_id     UUID REFERENCES rides(id) ON DELETE CASCADE,
  latitude    DOUBLE PRECISION NOT NULL,
  longitude   DOUBLE PRECISION NOT NULL,
  altitude_m  DOUBLE PRECISION DEFAULT 0,
  speed_kmh   DOUBLE PRECISION DEFAULT 0,
  recorded_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================
-- FUEL RECORDS
-- =====================
CREATE TABLE IF NOT EXISTS fuel_records (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  vehicle_id      UUID REFERENCES vehicles(id) ON DELETE CASCADE,
  date            DATE NOT NULL,
  liters          DOUBLE PRECISION NOT NULL,
  total_cost      DOUBLE PRECISION NOT NULL,
  odometer_km     DOUBLE PRECISION NOT NULL,
  mileage_kmpl    DOUBLE PRECISION,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- =====================
-- MAINTENANCE RECORDS
-- =====================
CREATE TABLE IF NOT EXISTS maintenance_records (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  vehicle_id      UUID REFERENCES vehicles(id) ON DELETE CASCADE,
  title           TEXT NOT NULL,
  date            DATE NOT NULL,
  cost            DOUBLE PRECISION DEFAULT 0,
  workshop_name   TEXT,
  invoice_number  TEXT,
  notes           TEXT,
  parts_replaced  TEXT[],
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- =====================
-- SAFETY EVENTS
-- =====================
CREATE TABLE IF NOT EXISTS safety_events (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID REFERENCES users(id) ON DELETE CASCADE,
  ride_id     UUID REFERENCES rides(id),
  event_type  TEXT NOT NULL,  -- 'crash', 'sos', 'overspeed', 'harsh_brake'
  severity    TEXT,
  latitude    DOUBLE PRECISION,
  longitude   DOUBLE PRECISION,
  g_force     DOUBLE PRECISION,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- =====================
-- EMERGENCY CONTACTS
-- =====================
CREATE TABLE IF NOT EXISTS emergency_contacts (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID REFERENCES users(id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  phone       TEXT NOT NULL,
  relation    TEXT,
  priority    INTEGER DEFAULT 1,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- =====================
-- RIDE CLUBS
-- =====================
CREATE TABLE IF NOT EXISTS ride_clubs (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name            TEXT UNIQUE NOT NULL,
  icon_emoji      TEXT DEFAULT '🏍️',
  description     TEXT,
  created_by      UUID REFERENCES users(id),
  total_distance  DOUBLE PRECISION DEFAULT 0,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- =====================
-- POSTS (Social Feed)
-- =====================
CREATE TABLE IF NOT EXISTS posts (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID REFERENCES users(id) ON DELETE CASCADE,
  ride_id     UUID REFERENCES rides(id),
  caption     TEXT,
  like_count  INTEGER DEFAULT 0,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- =====================
-- AI CONVERSATIONS
-- =====================
CREATE TABLE IF NOT EXISTS ai_conversations (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID REFERENCES users(id) ON DELETE CASCADE,
  role        TEXT NOT NULL,     -- 'user' | 'model'
  content     TEXT NOT NULL,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================
-- Row Level Security (enable on all tables)
-- =============================================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE rides ENABLE ROW LEVEL SECURITY;
ALTER TABLE fuel_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE maintenance_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE safety_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE emergency_contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_conversations ENABLE ROW LEVEL SECURITY;
