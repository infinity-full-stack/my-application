from fastapi import APIRouter, Depends, Query
from app.auth.dependencies import get_current_user
from app.models.user import User
from app.services.maps_service import find_nearby_stores, get_place_details
from typing import List

router = APIRouter(prefix="/api/maps", tags=["Maps"])


@router.get("/nearby")
async def nearby_stores(
    lat: float = Query(..., description="Latitude"),
    lng: float = Query(..., description="Longitude"),
    radius: int = Query(5000, description="Search radius in meters"),
    current_user: User = Depends(get_current_user),
):
    stores = await find_nearby_stores(lat, lng, radius)
    return {"stores": stores, "count": len(stores)}


@router.get("/place/{place_id}")
async def place_details(
    place_id: str,
    current_user: User = Depends(get_current_user),
):
    details = await get_place_details(place_id)
    if not details:
        return {"error": "Place not found"}
    return details
