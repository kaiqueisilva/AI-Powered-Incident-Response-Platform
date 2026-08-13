# Pipeline CI/CD testado em 2026

from fastapi import FastAPI
from core.config import settings
from api.routes import health, incidents
from prometheus_fastapi_instrumentator import Instrumentator

app = FastAPI(title=settings.app_name)

app.include_router(health.router, tags=["health"])
app.include_router(incidents.router, tags=["incidents"])

Instrumentator().instrument(app).expose(app)

@app.get("/")
def root():
    return {"message": f"{settings.app_name} is running", "environment": settings.environment}