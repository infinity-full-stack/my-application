from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List
from app.core.database import get_db
from app.models.part import Part
from app.models.price import Price
from app.schemas.part import PartCreate, PartUpdate, PartOut
from app.schemas.price import PriceCreate, PriceUpdate, PriceOut
from app.auth.dependencies import get_current_user, get_current_store_owner
from app.models.user import User

router = APIRouter(prefix="/api/parts", tags=["Parts"])


@router.get("/", response_model=List[PartOut])
async def list_parts(
    search: str = "",
    category: str = "",
    skip: int = 0,
    limit: int = 20,
    db: AsyncSession = Depends(get_db),
):
    query = select(Part)
    if search:
        query = query.where(Part.name.ilike(f"%{search}%"))
    if category:
        query = query.where(Part.category == category)
    result = await db.execute(query.offset(skip).limit(limit))
    return result.scalars().all()


@router.get("/{part_id}", response_model=PartOut)
async def get_part(part_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Part).where(Part.id == part_id))
    part = result.scalar_one_or_none()
    if not part:
        raise HTTPException(status_code=404, detail="Part not found")
    return part


@router.post("/", response_model=PartOut, status_code=status.HTTP_201_CREATED)
async def create_part(
    data: PartCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_store_owner),
):
    part = Part(**data.model_dump())
    db.add(part)
    await db.flush()
    await db.refresh(part)
    return part


# Prices
@router.post("/{part_id}/prices", response_model=PriceOut, status_code=status.HTTP_201_CREATED)
async def add_price(
    part_id: int,
    data: PriceCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_store_owner),
):
    data.part_id = part_id
    price = Price(**data.model_dump())
    db.add(price)
    await db.flush()
    await db.refresh(price)
    return price


@router.get("/{part_id}/prices", response_model=List[PriceOut])
async def get_prices(part_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(Price).where(Price.part_id == part_id, Price.in_stock == True)
    )
    return result.scalars().all()
