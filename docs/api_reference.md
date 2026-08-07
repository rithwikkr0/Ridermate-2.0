# API Reference

## OpenWeather API Service
- `getCurrentWeather({double lat, double lon})`: Fetches current temperature, humidity, wind speed/direction, condition, and calculates ride suitability score (0-100%).

## FastAPI Backend Endpoints
- `POST /api/v1/auth/register`: Create user account via Supabase Auth.
- `POST /api/v1/auth/login`: Authenticate user and return JWT session token.
- `GET /api/v1/weather/current`: Retrieve live weather telemetry.
- `GET /api/v1/rides/`: Fetch ride history list.
- `POST /api/v1/rides/`: Upload newly recorded ride.
- `POST /api/v1/safety/sos`: Trigger emergency SOS alert broadcast.
