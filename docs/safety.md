# Safety Engine & SOS Emergency

## Overview
Automated crash detection heuristics, high-g acceleration analysis, emergency contact broadcasting, and SOS countdown timer.

## Components
- **SosController**: Manages 5-second emergency countdown state lifecycle and user cancellation.
- **CrashDetectionEngine**: Analyzes accelerometer & gyroscope vector magnitudes to detect sudden impact forces.
- **SafetyScoreCalculator**: Computes rider safety rating based on cornering speed, hard braking events, and speed compliance.
