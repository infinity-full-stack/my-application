# Master Scan

AI-powered auto parts marketplace with location-based store discovery.

## Project Structure

```
master_scan/
├── backend/          # FastAPI backend
│   ├── app/
│   │   ├── admin/    # Admin panel routes
│   │   ├── auth/     # Auth dependencies
│   │   ├── core/     # Config, DB, Security
│   │   ├── models/   # SQLAlchemy models
│   │   ├── routers/  # API routes
│   │   ├── schemas/  # Pydantic schemas
│   │   ├── services/ # AI, Maps, Image services
│   │   └── main.py
│   ├── .env
│   └── requirements.txt
├── mobile/           # Flutter app
│   └── lib/
│       ├── core/     # Theme, Router, Network, Providers
│       └── features/ # auth, home, scan, stores, parts, maps, profile
└── .env
```

## Backend Setup

```bash
cd backend
pip install -r requirements.txt
# Edit .env with your keys
python run.py
```

API docs: http://localhost:8000/docs

## Mobile Setup

```bash
cd mobile
flutter pub get
flutter run
```

## Build APK

```bash
cd mobile
flutter build apk --release
# APK: build/app/outputs/flutter-apk/app-release.apk
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/auth/register | Register user |
| POST | /api/auth/login | Login |
| GET | /api/auth/me | Current user |
| POST | /api/scan/ | Scan car part (image) |
| GET | /api/scan/history | Scan history |
| GET | /api/stores/ | List verified stores |
| POST | /api/stores/ | Create store |
| GET | /api/parts/ | List/search parts |
| GET | /api/maps/nearby | Nearby stores |
| GET | /api/admin/dashboard | Admin dashboard |
| GET | /api/admin/stores/pending | Pending stores |
| PUT | /api/admin/stores/{id}/approve | Approve store |

## User Roles

- **user** — scan parts, search stores
- **store_owner** — register store, add parts/prices
- **admin** — full control panel

## Environment Variables

See `backend/.env` for all required variables.
