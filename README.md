<div align="center">

# 🔍 Master Scan

**AI-powered auto parts recognition & marketplace app**

![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![Railway](https://img.shields.io/badge/Railway-0B0D0E?style=for-the-badge&logo=railway&logoColor=white)
![AI](https://img.shields.io/badge/Groq_LLaMA_4-FF6B35?style=for-the-badge&logo=meta&logoColor=white)

> 📸 Scan any auto part with your camera → AI identifies it instantly → Find it in nearby stores

</div>

---

## 📌 About

**Master Scan** is a smart mobile application for the Uzbek auto parts market. Users simply take a photo of any car part — the AI recognizes it and returns its name, description, and category in Uzbek. The app then shows where to buy it, at what price, and on an interactive map.

---

## ✨ Key Features

- 🤖 **AI Scan** — Photo → LLaMA 4 identifies the part → name, description, category in Uzbek
- 🗺️ **Map** — Google Maps shows nearby auto parts stores & workshops
- 💰 **Price Comparison** — Compare part prices across different stores
- 🏪 **Store Directory** — Verified stores with address, hours, phone, rating
- 🔐 **Authentication** — Register → Gmail 6-digit verification → JWT login
- 👑 **Admin Panel** — Dashboard, user management, store approvals, analytics
- 📊 **Scan History** — All previous scans saved with confidence score
- 🔄 **3 Roles** — User, Store Owner, Admin

---

## 🛠️ Tech Stack

### Backend
| Technology | Purpose |
|---|---|
| Python + FastAPI | Async REST API |
| PostgreSQL + SQLAlchemy | Database (async) |
| Alembic | Migrations |
| Groq LLaMA 4 Scout | AI part recognition |
| Google Gemini API | Backup AI |
| Google Maps / Places API | Nearby stores |
| Gmail SMTP | Email verification |
| JWT + Passlib | Auth & security |
| Railway | Deployment & hosting |

### Mobile
| Technology | Purpose |
|---|---|
| Flutter + Dart | Cross-platform mobile |
| Riverpod | State management |
| Dio + Retrofit | HTTP client |
| Go Router | Navigation |
| Google Maps Flutter | Interactive map |
| Geolocator | Location detection |
| Image Picker + Camera | Photo capture |
| Freezed + JSON Serializable | Model generation |

---

## 📁 Project Structure

    master-scan/
    ├── backend/
    │   ├── app/
    │   │   ├── admin/        # Admin router & dashboard
    │   │   ├── auth/         # JWT dependencies
    │   │   ├── core/         # Config, DB, Security
    │   │   ├── models/       # SQLAlchemy models
    │   │   ├── routers/      # API endpoints
    │   │   ├── schemas/      # Pydantic v2 schemas
    │   │   ├── services/     # AI, Email, Maps, Image
    │   │   └── main.py
    │   ├── Procfile
    │   ├── railway.json
    │   └── requirements.txt
    └── mobile/
        ├── lib/
        │   ├── core/         # Constants, Network, Theme, Router
        │   └── features/     # Auth, Scan, Stores, Maps, Parts, Admin
        └── pubspec.yaml

---

## 🗄️ Database Models

| Table | Description |
|---|---|
| `users` | Users with role, email verification, status |
| `stores` | Stores with type, coordinates, hours, rating |
| `parts` | Auto parts catalog |
| `prices` | Part + store + price + availability |
| `scans` | Scan history with confidence score |

---

## 🔌 API Endpoints

| Endpoint | Description |
|---|---|
| `/api/auth` | Register, login, verify email, resend code |
| `/api/scan` | Upload image (AI analysis), scan history |
| `/api/stores` | Store list, store request submission |
| `/api/parts` | Parts catalog |
| `/api/maps` | Nearby stores via Google Places |
| `/api/admin` | Admin dashboard & management |

---

## 🏪 Store Types

`Parts Store` • `Tuning Shop` • `Paint Shop` • `Electronics` • `Workshop` • `Tire Service` • `Oil Service` • `Body Shop` • `Diagnostic`

---

## 🚀 Getting Started

### Backend

    cd backend
    python -m venv venv
    venv\Scripts\activate
    pip install -r requirements.txt
    alembic upgrade head
    uvicorn app.main:app --reload

### Environment Variables

    DATABASE_URL=postgresql+asyncpg://...
    SECRET_KEY=your_secret_key
    GROQ_API_KEY=your_groq_key
    GEMINI_API_KEY=your_gemini_key
    GOOGLE_MAPS_API_KEY=your_maps_key
    GMAIL_USER=your_gmail
    GMAIL_PASSWORD=your_app_password

### Mobile

    cd mobile
    flutter pub get
    flutter run

---

## 🌐 Deployment

- **Backend** → Railway (auto-deploy from GitHub)
- **Database** → PostgreSQL (Railway hosted)
- **Mobile** → Android / iOS (Flutter build)

---

## 👨‍💻 Developer

**Muhammadqodir** — Fullstack & Flutter Developer

[![Telegram](https://img.shields.io/badge/Telegram-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/infinity_x7)
[![GitHub](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/infinity-full-stack)
