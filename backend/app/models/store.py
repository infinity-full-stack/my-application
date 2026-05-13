from sqlalchemy import Column, Integer, String, Float, Boolean, ForeignKey, DateTime, Text, Enum, Time
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import enum
from app.core.database import Base


class StoreType(str, enum.Enum):
    # Do'konlar
    PARTS_STORE = "PARTS_STORE"       # Mashina qismlari do'koni
    TUNING_SHOP = "TUNING_SHOP"       # Tyuning do'koni
    PAINT_SHOP = "PAINT_SHOP"         # Rang-bo'yoqlar do'koni
    ELECTRONICS = "ELECTRONICS"       # Avto elektronika
    # Ustaxonalar
    WORKSHOP = "WORKSHOP"             # Umumiy ustaxona
    TIRE_SERVICE = "TIRE_SERVICE"     # Shina xizmati
    OIL_SERVICE = "OIL_SERVICE"       # Moy almashtirish
    BODY_SHOP = "BODY_SHOP"           # Kuzov ta'mirlash
    DIAGNOSTIC = "DIAGNOSTIC"         # Diagnostika
    OTHER = "OTHER"


class StoreCategory(str, enum.Enum):
    # Do'kon kategoriyalari
    ENGINE_PARTS = "ENGINE_PARTS"
    BODY_PARTS = "BODY_PARTS"
    ELECTRICAL = "ELECTRICAL"
    TIRES_WHEELS = "TIRES_WHEELS"
    INTERIOR = "INTERIOR"
    PAINT_COATING = "PAINT_COATING"
    TUNING = "TUNING"
    TINTING = "TINTING"
    FLOOR_MATS = "FLOOR_MATS"
    OILS_FLUIDS = "OILS_FLUIDS"
    BRAKES = "BRAKES"
    SUSPENSION = "SUSPENSION"
    GLASS = "GLASS"
    # Ustaxona xizmat kategoriyalari
    TIRE_SERVICE = "TIRE_SERVICE"
    ENGINE_REPAIR = "ENGINE_REPAIR"
    CHASSIS = "CHASSIS"
    OIL_CHANGE = "OIL_CHANGE"
    DIAGNOSTICS = "DIAGNOSTICS"
    WELDING = "WELDING"
    OTHER = "OTHER"


class Store(Base):
    __tablename__ = "stores"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(200), nullable=False)
    description = Column(Text, nullable=True)
    owner_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    store_type = Column(Enum(StoreType), default=StoreType.PARTS_STORE)
    category = Column(Enum(StoreCategory), default=StoreCategory.OTHER)
    address = Column(String(500), nullable=True)
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    phone = Column(String(20), nullable=True)
    working_hours = Column(String(100), nullable=True)
    work_start = Column(Time, nullable=True)
    work_end = Column(Time, nullable=True)
    social_links = Column(String(500), nullable=True)
    image_url = Column(String(500), nullable=True)
    verified = Column(Boolean, default=False)
    rating = Column(Float, default=0.0)
    applicant_name = Column(String(100), nullable=True)
    applicant_email = Column(String(255), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    owner = relationship("User", back_populates="stores")
    prices = relationship("Price", back_populates="store")
