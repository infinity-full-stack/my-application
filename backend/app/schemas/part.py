from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class PartCreate(BaseModel):
    name: str
    description: Optional[str] = None
    category: Optional[str] = None


class PartUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    category: Optional[str] = None


class PartOut(BaseModel):
    id: int
    name: str
    description: Optional[str]
    category: Optional[str]
    created_at: datetime

    class Config:
        from_attributes = True
