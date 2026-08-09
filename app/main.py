from fastapi import FastAPI
from core.config import settings
from api.routes import health, incidents

app = FastAPI(title=settings.app_name)

app.include_router(health.router, tags=["health"])
app.include_router(incidents.router, tags=["incidents"])

@app.get("/")
def root():
    return {"message": f"{settings.app_name} is running", "environment": settings.environment}