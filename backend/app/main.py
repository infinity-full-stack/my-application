from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.core.database import create_tables, get_db
from app.routers import auth, scan, stores, parts, maps
from app.admin.router import router as admin_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    await create_tables()
    yield


app = FastAPI(
    title="Master Scan API",
    description="AI-powered auto parts marketplace",
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(scan.router)
app.include_router(stores.router)
app.include_router(parts.router)
app.include_router(maps.router)
app.include_router(admin_router)


@app.get("/")
async def root():
    return {"message": "Master Scan API is running", "version": "1.0.0"}


@app.get("/health")
async def health():
    return {"status": "ok"}


@app.post("/api/setup-admin")
async def setup_admin(email: str, db: AsyncSession = Depends(get_db)):
    """One-time: make a user admin by email"""
    from app.models.user import User, UserRole
    result = await db.execute(select(User).where(User.email == email))
    user = result.scalar_one_or_none()
    if not user:
        return {"error": "User not found"}
    user.role = UserRole.ADMIN
    await db.flush()
    return {"message": f"{email} is now admin"}
