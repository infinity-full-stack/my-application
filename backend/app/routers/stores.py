from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List
from app.core.database import get_db
from app.models.user import User
from app.models.store import Store
from app.schemas.store import StoreCreate, StoreUpdate, StoreOut, StoreRequest
from app.auth.dependencies import get_current_user, get_current_store_owner
from app.services.email_service import send_store_request_notification

router = APIRouter(prefix="/api/stores", tags=["Stores"])


@router.get("/", response_model=List[StoreOut])
async def list_stores(
    skip: int = 0,
    limit: int = 50,
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Store).where(Store.verified == True).offset(skip).limit(limit)
    )
    return result.scalars().all()


@router.get("/{store_id}", response_model=StoreOut)
async def get_store(store_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Store).where(Store.id == store_id))
    store = result.scalar_one_or_none()
    if not store:
        raise HTTPException(status_code=404, detail="Do'kon topilmadi")
    return store


@router.post("/request", status_code=status.HTTP_201_CREATED)
async def request_store(
    data: StoreRequest,
    db: AsyncSession = Depends(get_db),
):
    """Login talab qilmaydi — har kim do'kon qo'shish so'rovi yuborishi mumkin"""
    store = Store(
        name=data.name,
        store_type=data.store_type,
        category=data.category,
        description=data.description,
        address=data.address,
        latitude=data.latitude,
        longitude=data.longitude,
        phone=data.phone,
        working_hours=f"{data.work_start} - {data.work_end}" if data.work_start and data.work_end else None,
        social_links=data.social_links,
        image_url=data.image_url,
        applicant_name=data.applicant_name,
        applicant_email=data.applicant_email,
        verified=False,
    )
    db.add(store)
    await db.flush()
    await db.refresh(store)

    # Admin ga email xabarnoma yuborish
    await send_store_request_notification(data)

    return {
        "message": "So'rovingiz qabul qilindi. Admin ko'rib chiqqandan so'ng do'koningiz qo'shiladi.",
        "store_id": store.id,
    }


@router.post("/", response_model=StoreOut, status_code=status.HTTP_201_CREATED)
async def create_store(
    data: StoreCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_store_owner),
):
    store = Store(**data.model_dump(), owner_id=current_user.id)
    db.add(store)
    await db.flush()
    await db.refresh(store)
    return store


@router.put("/{store_id}", response_model=StoreOut)
async def update_store(
    store_id: int,
    data: StoreUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_store_owner),
):
    result = await db.execute(select(Store).where(Store.id == store_id))
    store = result.scalar_one_or_none()
    if not store:
        raise HTTPException(status_code=404, detail="Do'kon topilmadi")
    if store.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Bu sizning do'koningiz emas")

    for key, value in data.model_dump(exclude_none=True).items():
        setattr(store, key, value)

    await db.flush()
    await db.refresh(store)
    return store
