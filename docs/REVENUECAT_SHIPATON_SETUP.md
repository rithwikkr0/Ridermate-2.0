# RiderMate 2.0 — RevenueCat / Shipaton Setup

## Branch

RevenueCat work lives on:

`feature/revenuecat`

The stable `main` branch is not modified by this integration.

## RevenueCat configuration

Create an Android app in RevenueCat for package:

`com.ridermate.ridermate`

Create:

- Entitlement: `rider_pro`
- Offering: `default`
- Monthly product: `ridermate_pro_monthly`
- Annual product: `ridermate_pro_yearly`

Attach both products to the `rider_pro` entitlement and the `default` offering.

For Next Gen development, RevenueCat Test Store can be used.

## Flutter build

The public Android RevenueCat SDK key is supplied at build time. Do not commit it.

PowerShell example:

```powershell
flutter pub get
flutter run --dart-define=REVENUECAT_ANDROID_API_KEY=goog_REPLACE_WITH_PUBLIC_KEY
```

Release example:

```powershell
flutter build apk --release --dart-define=REVENUECAT_ANDROID_API_KEY=goog_REPLACE_WITH_PUBLIC_KEY
```

## Premium policy

Essential safety remains free:

- SOS
- Emergency contacts
- Crash/safety features
- Basic ride tracking
- Basic navigation

Pro is intended for advanced analytics, AI ride insights, vehicle intelligence, long-term trends, and enhanced cloud features.

## Source of truth

Premium access is determined by the RevenueCat `rider_pro` entitlement. Do not use a local boolean or SharedPreferences value as the authority for paid access.

## Shipaton checklist

- [ ] Create RevenueCat project
- [ ] Configure Android application
- [ ] Create Test Store products
- [ ] Create `rider_pro` entitlement
- [ ] Create `default` offering
- [ ] Verify test purchase
- [ ] Verify restore
- [ ] Verify logout/login customer isolation
- [ ] Record premium demo
- [ ] Update Devpost
- [ ] Enter RevenueCat Project ID
- [ ] Add student email if entering Next Gen
- [ ] Keep repository public with MIT license
