import httpx
from typing import List, Optional
from app.core.config import settings


async def find_nearby_stores(
    latitude: float,
    longitude: float,
    radius: int = 5000,
    limit: int = 5,
) -> List[dict]:
    """Find nearby auto parts stores using Google Places API."""
    url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
    params = {
        "location": f"{latitude},{longitude}",
        "radius": radius,
        "keyword": "auto parts store car workshop",
        "key": settings.GOOGLE_MAPS_API_KEY,
    }

    async with httpx.AsyncClient(timeout=10.0) as client:
        try:
            response = await client.get(url, params=params)
            response.raise_for_status()
            data = response.json()

            results = []
            for place in data.get("results", [])[:limit]:
                results.append({
                    "place_id": place.get("place_id"),
                    "name": place.get("name"),
                    "address": place.get("vicinity"),
                    "latitude": place["geometry"]["location"]["lat"],
                    "longitude": place["geometry"]["location"]["lng"],
                    "rating": place.get("rating", 0.0),
                    "open_now": place.get("opening_hours", {}).get("open_now"),
                })
            return results
        except Exception:
            return []


async def get_place_details(place_id: str) -> Optional[dict]:
    """Get detailed info about a place."""
    url = "https://maps.googleapis.com/maps/api/place/details/json"
    params = {
        "place_id": place_id,
        "fields": "name,formatted_address,formatted_phone_number,rating,opening_hours,geometry",
        "key": settings.GOOGLE_MAPS_API_KEY,
    }

    async with httpx.AsyncClient(timeout=10.0) as client:
        try:
            response = await client.get(url, params=params)
            response.raise_for_status()
            data = response.json()
            return data.get("result")
        except Exception:
            return None
