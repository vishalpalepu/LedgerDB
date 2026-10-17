import os
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    """Application configuration loaded from environment variables."""
    # Placeholder for the PostgreSQL connection string; replace with actual value in production
    DATABASE_URL: str = os.getenv("POSTGRES_URL", "postgresql://user:password@localhost:5432/ledgerdb")
    # JWT secret key – in production this must be a strong secret
    JWT_SECRET_KEY: str = os.getenv("JWT_SECRET_KEY", "your-secret-key")
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60  # token validity (minutes)

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"

settings = Settings()
