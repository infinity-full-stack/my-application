from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from typing import List
from app.core.database import get_db
from app.models.user import User, UserRole
from app.models.store import Store
from app.models.part import Part
from app.models.scan import Scan
from app.schemas.user import UserOut
from app.schemas.store import StoreOut
from app.schemas.part import PartCreate, PartUpdate, PartOut
from app.auth.dependencies import get_current_admin

router = APIRouter(prefix="/api/admin", tags=["Admin"])


@router.get("/dashboard")
async def dashboard(
    db: AsyncSession = Depends(get_db),
    admin: User = Depends(get_current_admin),
):
    total_users = await db.scalar(select(func.count(User.id)))
    total_stores = await db.scalar(select(func.count(Store.id)))
    verified_stores = await db.scalar(select(func.count(Store.id)).where(Store.verified == True))
    pending_stores = await db.scalar(select(func.count(Store.id)).where(Store.verified == False))
    total_scans = await db.scalar(select(func.count(Scan.id)))
    total_parts = await db.scalar(select(func.count(Part.id)))

    return {
        "total_users": total_users,
        "total_stores": total_stores,
        "verified_stores": verified_stores,
        "pending_stores": pending_stores,
        "total_scans": total_scans,
        "total_parts": total_parts,
    }


# ── Users ──────────────────────────────────────────────
@router.get("/users", response_model=List[UserOut])
async def list_users(
    skip: int = 0, limit: int = 50,
    db: AsyncSession = Depends(get_db),
    admin: User = Depends(get_current_admin),
):
    result = await db.execute(select(User).offset(skip).limit(limit))
    return result.scalars().all()


@router.put("/users/{user_id}/deactivate")
async def deactivate_user(
    user_id: int,
    db: AsyncSession = Depends(get_db),
    admin: User = Depends(get_current_admin),
):
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="Foydalanuvchi topilmadi")
    user.is_active = False
    return {"message": "Foydalanuvchi bloklandi"}


# ── Stores ─────────────────────────────────────────────
@router.get("/stores/pending", response_model=List[StoreOut])
async def pending_stores(
    db: AsyncSession = Depends(get_db),
    admin: User = Depends(get_current_admin),
):
    result = await db.execute(select(Store).where(Store.verified == False))
    return result.scalars().all()


@router.get("/stores", response_model=List[StoreOut])
async def all_stores(
    db: AsyncSession = Depends(get_db),
    admin: User = Depends(get_current_admin),
):
    result = await db.execute(select(Store))
    return result.scalars().all()


@router.put("/stores/{store_id}/approve")
async def approve_store(
    store_id: int,
    db: AsyncSession = Depends(get_db),
    admin: User = Depends(get_current_admin),
):
    result = await db.execute(select(Store).where(Store.id == store_id))
    store = result.scalar_one_or_none()
    if not store:
        raise HTTPException(status_code=404, detail="Do'kon topilmadi")
    store.verified = True
    return {"message": f"'{store.name}' tasdiqlandi"}


@router.put("/stores/{store_id}/reject")
async def reject_store(
    store_id: int,
    db: AsyncSession = Depends(get_db),
    admin: User = Depends(get_current_admin),
):
    result = await db.execute(select(Store).where(Store.id == store_id))
    store = result.scalar_one_or_none()
    if not store:
        raise HTTPException(status_code=404, detail="Do'kon topilmadi")
    await db.delete(store)
    return {"message": "So'rov rad etildi"}


# ── Parts ──────────────────────────────────────────────
@router.get("/parts", response_model=List[PartOut])
async def list_parts(
    db: AsyncSession = Depends(get_db),
    admin: User = Depends(get_current_admin),
):
    result = await db.execute(select(Part))
    return result.scalars().all()


@router.post("/parts", response_model=PartOut)
async def create_part(
    data: PartCreate,
    db: AsyncSession = Depends(get_db),
    admin: User = Depends(get_current_admin),
):
    part = Part(**data.model_dump())
    db.add(part)
    await db.flush()
    await db.refresh(part)
    return part


@router.put("/parts/{part_id}", response_model=PartOut)
async def update_part(
    part_id: int,
    data: PartUpdate,
    db: AsyncSession = Depends(get_db),
    admin: User = Depends(get_current_admin),
):
    result = await db.execute(select(Part).where(Part.id == part_id))
    part = result.scalar_one_or_none()
    if not part:
        raise HTTPException(status_code=404, detail="Qism topilmadi")
    for key, value in data.model_dump(exclude_none=True).items():
        setattr(part, key, value)
    await db.flush()
    await db.refresh(part)
    return part


@router.delete("/parts/{part_id}")
async def delete_part(
    part_id: int,
    db: AsyncSession = Depends(get_db),
    admin: User = Depends(get_current_admin),
):
    result = await db.execute(select(Part).where(Part.id == part_id))
    part = result.scalar_one_or_none()
    if not part:
        raise HTTPException(status_code=404, detail="Qism topilmadi")
    await db.delete(part)
    return {"message": "Qism o'chirildi"}


# ── Analytics ──────────────────────────────────────────
@router.get("/analytics/top-scans")
async def top_scanned_parts(
    limit: int = 10,
    db: AsyncSession = Depends(get_db),
    admin: User = Depends(get_current_admin),
):
    result = await db.execute(
        select(Scan.part_name, func.count(Scan.id).label("count"))
        .group_by(Scan.part_name)
        .order_by(func.count(Scan.id).desc())
        .limit(limit)
    )
    return [{"part_name": row[0], "count": row[1]} for row in result.all()]
