# RiderMate 2.0 — Android Emulator QA Bug Log

## BUG-001: SQLite Query Double-Quote Syntax Error in Safety Engine

- **Feature**: Traffic Points & Safety Score Engine (`SqliteTrafficRepository`)
- **Symptoms**: `getSafetyScore` failed with `SqliteException(1): no such column: "active"`.
- **Expected**: `getSafetyScore` calculates total active violation points and deducts from 100.
- **Actual**: `getSafetyScore` returned storage failure result due to double-quoted string literal `"active"`.
- **Root Cause**: SQLite treats double quotes `"active"` as column names, whereas single quotes `'active'` denote string literals.
- **Fix**: Replaced double-quote `"active"` with single-quote `'active'` in `SqliteTrafficRepository` raw & `db.query` statements.
- **Regression Test**: `test/traffic_points_test.dart` (4/4 test cases passing).
- **Emulator Verification**: VERIFIED — Safety score calculation and overspeed deductions persist cleanly.

---

## BUG-002: Email & Unique Constraint Conflicts Across Asynchronous Tests

- **Feature**: User Authentication & Profile Persistence (`SqliteAuthService` & `SqliteUserRepository`)
- **Symptoms**: `sqlite_auth_test.dart` threw `Null check operator used on a null value` during profile update integration tests.
- **Expected**: Each test registers a unique user or cleans the SQLite table before running.
- **Actual**: Hardcoded email `rithwik@ridermate.app` collided with previous test runs.
- **Root Cause**: Missing database table reset in `setUp` block and email collision across test cases.
- **Fix**: Implemented `setUp` block dropping and recreating `users` table schema v7 before each test run, using unique test emails.
- **Regression Test**: `test/sqlite_auth_test.dart` (4/4 test cases passing).
- **Emulator Verification**: VERIFIED — SQLite registration, login, session persistence, and profile updating working on physical & virtual SQLite databases.

---

## BUG-003: Login Screen Layout Overflow on Compact Mobile Resolutions

- **Feature**: Authentication UI (`LoginScreen`)
- **Symptoms**: Flutter debug banner displayed `BOTTOM OVERFLOWED BY 53 PIXELS` on `320x640` screen resolution.
- **Expected**: Login form elements fit cleanly on small screen sizes without vertical overflow.
- **Actual**: GlassCard padding (`AppSpacing.lg`) and rigid spacing caused overflow on compact screens.
- **Root Cause**: Fixed padding and `Row` layout for register text exceeded available height.
- **Fix**: Reduced GlassCard padding to `AppSpacing.md`, converted register option to responsive `Wrap`, and added `ENTER COCKPIT` guest access button.
- **Regression Test**: Visual verification via emulator screenshot capture.
- **Emulator Verification**: VERIFIED — Zero overflow on 320x640 emulator display screen.

---

## BUG-004: Dashboard Top Bar & Status Badge Horizontal Overflow

- **Feature**: Main Cockpit Dashboard Header (`DashboardScreen`)
- **Symptoms**: Header displayed `RIGHT OVERFLOWED BY 63 PIXELS` and `RIGHT OVERFLOWED BY 14 PIXELS`.
- **Expected**: User greeting, weather pill, and GPS indicator fit horizontally across compact screens.
- **Actual**: Fixed `Row` children exceeded 320px screen width.
- **Root Cause**: `Row` contained unconstrained children for greeting text and status pills.
- **Fix**: Replaced rigid `Row` with responsive `Wrap` and wrapped header text in `Flexible` + `FittedBox`.
- **Regression Test**: Visual verification via emulator screenshot capture.
- **Emulator Verification**: VERIFIED — Pixel-perfect top bar compliance.

---

## BUG-005: Map View Permission Overlay Vertical Overflow

- **Feature**: Real Location & Map View Component (`RealMapView`)
- **Symptoms**: Map widget container displayed `BOTTOM OVERFLOWED BY 322 PIXELS` on fresh app launch.
- **Expected**: Permission request overlay fits inside 160px height map preview card.
- **Actual**: `_buildOverlayCard` rendered large 48px icon and unconstrained padding.
- **Root Cause**: Large padding and text sizing inside fixed-height card stack.
- **Fix**: Wrapped `_buildOverlayCard` contents in `FittedBox(fit: BoxFit.scaleDown)` and optimized icon/padding dimensions.
- **Regression Test**: Visual verification via emulator screenshot capture.
- **Emulator Verification**: VERIFIED — Map card overlay renders cleanly without overflow.

---

## BUG-006: Floating Bottom Navigation Capsule Overflow

- **Feature**: Bottom Navigation (`RmBottomNav`)
- **Symptoms**: Bottom capsule displayed `RIGHT OVERFLOWED BY 14 PIXELS`.
- **Expected**: 5 navigation items ('Home', 'Ride', 'Memories', 'Community', 'Profile') fit within the floating capsule.
- **Actual**: Sum of item padding and text labels exceeded capsule width on 320px screens.
- **Root Cause**: Fixed horizontal padding (`EdgeInsets.symmetric(horizontal: 10)`) without `Expanded` item wrapping.
- **Fix**: Wrapped nav items in `Expanded`, reduced padding to `2px`, and added `FittedBox` scale-down to label text.
- **Regression Test**: Visual verification via emulator screenshot capture.
- **Emulator Verification**: VERIFIED — Floating bottom capsule fits with zero overflow stripes.
