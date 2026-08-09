from pydantic import BaseModel
from datetime import datetime
from enum import Enum

class Severity(str, Enum):
    low = "low"
    medium = "medium"
    high = "high"
    critical = "critical"

class Incident(BaseModel):
    id: str
    title: str
    description: str
    severity: Severity
    created_at: datetime