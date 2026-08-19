# RiderMate 2.0 — Garage & Vehicle Management Architecture

> **Document Type**: Garage Architecture & Vehicle Management Specification  
> **Status**: Verified & Unit Tested with Mock Repository Pipeline  
> **Future Hardware Pluggability**: Bluetooth 5.0 OBD-II Diagnostic Scanner Interface

---

## 1. Overview
The Garage Engine manages motorcycle telemetry, fuel efficiency, expense calculations, insurance/PUC validity, challan tracking, and automated maintenance reminders.

### Key Features
- **FuelManagerService**: Logs fuel fills, calculates average mileage (km/L), total fuel spent, and cost-per-km trends.
- **MaintenanceService**: Tracks engine oil, chain lube, brake pads, and tire wear schedules based on odometer readings.
- **GarageReminderEngine**: Triggers upcoming maintenance alerts when mileage thresholds are approached.
- **Vehicle Intelligence & Challan Tracking**: Validates Indian registration number formats and tracks traffic challans with status badges.

---

## 2. System Architecture Diagram

```
+-------------------------------------------------------------------------+
|                       RiderMate 2.0 Garage UI                           |
|       (My Garage, Fuel Logs, Maintenance History, Insurance, Gear)      |
+------------------------------------^------------------------------------+
                                     | Vehicle State & Reminders Stream
+------------------------------------+------------------------------------+
|                          GarageController                               |
|        (loadGarageData(), addFuelLog(), addServiceRecord())            |
+-----------------^-----------------------------------^-------------------+
                  |                                   |
+-----------------+-------------------+   +-----------+-------------------+
|        FuelManagerService           |   |       MaintenanceService          |
| (Fuel Logs, Mileage & Expenses)     |   | (Workshop History & Parts)        |
+-----------------^-------------------+   +-------------------------------+
                  |
+-----------------+-------------------------------------------------------+
|                    Future Hardware Adaptor Layer                        |
|  (MockGarageRepository -> Future Bluetooth OBD-II Diagnostic Stream)   |
+-------------------------------------------------------------------------+
```

---

## 2. Cost Per Kilometer Formula

`Cost per KM = (Total Fuel Expenses + Total Maintenance Expenses) / Total Odometer KM`
