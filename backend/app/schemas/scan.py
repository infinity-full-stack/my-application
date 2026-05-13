from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class ScanResult(BaseModel):
    part_name: str
    description: str
    category: str
    confidence_score: float


class ScanOut(BaseModel):
    id: int
    user_id: int
    part_name: Optional[str]
    category: Optional[str]
    description: Optional[str]
    confidence_score: Optional[float]
    created_at: datetime

    class Config:
        from_attributes = True
