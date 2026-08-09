from fastapi import APIRouter, HTTPException
from models.incidents import Incident
from datetime import datetime
import uuid

router = APIRouter()

# "banco de dados" fake em memória, só pra começar
incidents_db: dict[str, Incident] = {}

@router.get("/incidents")
def list_incidents():
    return list(incidents_db.values())

@router.post("/incidents")
def create_incident(title: str, description: str, severity: str):
    incident = Incident(
        id=str(uuid.uuid4()),
        title=title,
        description=description,
        severity=severity,
        created_at=datetime.utcnow(),
    )
    incidents_db[incident.id] = incident
    return incident

@router.get("/incidents/{incident_id}")
def get_incident(incident_id: str):
    incident = incidents_db.get(incident_id)
    if not incident:
        raise HTTPException(status_code=404, detail="Incident not found")
    return incident