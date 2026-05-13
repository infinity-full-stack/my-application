from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.core.database import get_db
from app.models.user import User
from app.models.scan import Scan
from app.schemas.scan import ScanOut
from app.auth.dependencies import get_current_user
from app.services.ai_service import identify_part_from_image
from app.services.image_service import compress_image
from typing import List

router = APIRouter(prefix="/api/scan", tags=["Scan"])

ALLOWED_TYPES = {"image/jpeg", "image/png", "image/webp", "image/jpg"}
MAX_FILE_SIZE = 10 * 1024 * 1024


@router.post("/", response_model=ScanOut)
async def scan_part(
    file: UploadFile = File(...),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if file.content_type not in ALLOWED_TYPES:
        raise HTTPException(status_code=400, detail="Faqat JPEG, PNG rasm yuklang")

    image_bytes = await file.read()
    if len(image_bytes) > MAX_FILE_SIZE:
        raise HTTPException(status_code=400, detail="Fayl hajmi 10MB dan oshmasin")

    compressed = compress_image(image_bytes)
    result = await identify_part_from_image(compressed)

    scan = Scan(
        user_id=current_user.id,
        part_name=result.part_name,
        category=result.category,
        description=result.description,
        confidence_score=result.confidence_score,
    )
    db.add(scan)
    await db.flush()
    await db.refresh(scan)
    return scan


@router.get("/history", response_model=List[ScanOut])
async def get_scan_history(
    skip: int = 0,
    limit: int = 50,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(Scan)
        .where(Scan.user_id == current_user.id)
        .order_by(Scan.created_at.desc())
        .offset(skip)
        .limit(limit)
    )
    return result.scalars().all()
