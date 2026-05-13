from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class PriceCreate(BaseModel):
    part_id: int
    store_id: int
    price: float
    in_stock: bool = True


class PriceUpdate(BaseModel):
    price: Optional[float] = None
    in_stock: Optional[bool] = None


class PriceOut(BaseModel):
    id: int
    part_id: int
    store_id: int
    price: float
    in_stock: bool
    created_at: datetime

    class Config:
        from_attributes = True
