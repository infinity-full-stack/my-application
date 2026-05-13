from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import datetime, time
from app.models.store import StoreType, StoreCategory


class StoreRequest(BaseModel):
    name: str
    store_type: StoreType
    category: StoreCategory
    description: Optional[str] = None
    address: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    phone: str
    work_start: Optional[str] = None   # "09:00"
    work_end: Optional[str] = None     # "18:00"
    social_links: Optional[str] = None
    image_url: Optional[str] = None
    applicant_name: str
    applicant_email: str


class StoreCreate(BaseModel):
    name: str
    store_type: StoreType = StoreType.PARTS_STORE
    category: StoreCategory = StoreCategory.OTHER
    description: Optional[str] = None
    address: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    phone: Optional[str] = None
    working_hours: Optional[str] = None


class StoreUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    address: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    phone: Optional[str] = None
    working_hours: Optional[str] = None


class StoreOut(BaseModel):
    id: int
    name: str
    store_type: StoreType
    category: StoreCategory
    description: Optional[str] = None
    owner_id: Optional[int] = None
    address: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    phone: Optional[str] = None
    working_hours: Optional[str] = None
    work_start: Optional[time] = None
    work_end: Optional[time] = None
    social_links: Optional[str] = None
    image_url: Optional[str] = None
    verified: bool
    rating: float
    applicant_name: Optional[str] = None
    applicant_email: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True
