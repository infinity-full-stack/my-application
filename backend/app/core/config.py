from pydantic_settings import BaseSettings
from functools import lru_cache
import os


class Settings(BaseSettings):
    # Database (Railway injects DATABASE_URL automatically)
    DATABASE_URL: str = os.getenv("DATABASE_URL", "postgresql://postgres:2006@localhost:5432/master_scan")

    # Auth
    SECRET_KEY: str = os.getenv("SECRET_KEY", "master-scan-super-secret-key-change-in-production-2024")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60

    # OpenAI (not used, replaced by Gemini)
    OPENAI_API_KEY: str = "not-used"

    # Google Gemini Vision API
    GEMINI_API_KEY: str = ""

    # Groq Vision API
    GROQ_API_KEY: str = ""

    # Google Maps
    GOOGLE_MAPS_API_KEY: str = os.getenv("GOOGLE_MAPS_API_KEY", "")

    # Email
    SMTP_HOST: str = "smtp.gmail.com"
    SMTP_PORT: int = 587
    SMTP_USER: str = ""
    SMTP_PASSWORD: str = ""
    EMAIL_FROM: str = ""

    # App
    APP_ENV: str = "development"
    BACKEND_URL: str = "http://10.0.2.2:8000"

    model_config = {"env_file": ".env", "extra": "ignore"}


@lru_cache()
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
