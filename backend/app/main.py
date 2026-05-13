from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from app.core.database import create_tables
from app.routers import auth, scan, stores, parts, maps
from app.admin.router import router as admin_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: create tables
    await create_tables()
    yield
    # Shutdown


app = FastAPI(
    title="Master Scan API",
    description="AI-powered auto parts marketplace",
    version="1.0.0",
    lifespan=lifespan,
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Routers
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
