from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    app_name: str = "AI Incident Response Platform"
    environment: str = "dev"
    log_level: str = "INFO"

    class Config:
        env_file = ".env"  # permite sobrescrever via arquivo .env local

settings = Settings()