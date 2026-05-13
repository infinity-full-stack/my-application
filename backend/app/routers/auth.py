from datetime import datetime, timedelta, timezone
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.core.database import get_db
from app.core.security import hash_password, verify_password, create_access_token
from app.models.user import User
from app.schemas.user import (
    UserCreate, UserLogin, UserOut, TokenOut,
    VerifyEmailRequest, ResendCodeRequest, RegisterResponse,
)
from app.auth.dependencies import get_current_user
from app.services.email_service import send_verification_email, generate_verification_code

router = APIRouter(prefix="/api/auth", tags=["Auth"])

VERIFICATION_EXPIRE_MINUTES = 10


@router.post("/register", response_model=RegisterResponse, status_code=status.HTTP_201_CREATED)
async def register(data: UserCreate, db: AsyncSession = Depends(get_db)):
    # Check duplicate email
    result = await db.execute(select(User).where(User.email == data.email))
    existing = result.scalar_one_or_none()

    if existing:
        if existing.is_verified:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email already registered",
            )
        # Unverified — resend code
        code = generate_verification_code()
        existing.verification_code = code
        existing.verification_expires = datetime.now(timezone.utc) + timedelta(
            minutes=VERIFICATION_EXPIRE_MINUTES
        )
        await db.flush()
        await send_verification_email(existing.email, existing.name, code)
        return RegisterResponse(
            message="Verification code resent to your email",
            email=existing.email,
        )

    # New user — create unverified
    code = generate_verification_code()
    expires = datetime.now(timezone.utc) + timedelta(minutes=VERIFICATION_EXPIRE_MINUTES)

    user = User(
        name=data.name,
        email=data.email,
        password=hash_password(data.password),
        role=data.role,
        is_verified=False,
        verification_code=code,
        verification_expires=expires,
    )
    db.add(user)
    await db.flush()

    # Send email (non-blocking — if fails, user can resend)
    await send_verification_email(data.email, data.name, code)

    return RegisterResponse(
        message="Registration successful. Please check your email for the verification code.",
        email=data.email,
    )


@router.post("/verify-email", response_model=TokenOut)
async def verify_email(data: VerifyEmailRequest, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == data.email))
    user = result.scalar_one_or_none()

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if user.is_verified:
        raise HTTPException(status_code=400, detail="Email already verified")

    if user.verification_code != data.code:
        raise HTTPException(status_code=400, detail="Invalid verification code")

    # Check expiry
    if user.verification_expires:
        expires = user.verification_expires
        # Make timezone-aware if naive
        if expires.tzinfo is None:
            expires = expires.replace(tzinfo=timezone.utc)
        if datetime.now(timezone.utc) > expires:
            raise HTTPException(
                status_code=400,
                detail="Verification code expired. Please request a new one.",
            )

    # Mark verified
    user.is_verified = True
    user.verification_code = None
    user.verification_expires = None
    await db.flush()
    await db.refresh(user)

    token = create_access_token({"sub": str(user.id), "role": user.role})
    return TokenOut(access_token=token, user=UserOut.model_validate(user))


@router.post("/resend-code")
async def resend_code(data: ResendCodeRequest, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == data.email))
    user = result.scalar_one_or_none()

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if user.is_verified:
        raise HTTPException(status_code=400, detail="Email already verified")

    code = generate_verification_code()
    user.verification_code = code
    user.verification_expires = datetime.now(timezone.utc) + timedelta(
        minutes=VERIFICATION_EXPIRE_MINUTES
    )
    await db.flush()

    sent = await send_verification_email(user.email, user.name, code)
    if not sent:
        raise HTTPException(status_code=500, detail="Failed to send email. Try again.")

    return {"message": "Verification code sent to your email"}


@router.post("/login", response_model=TokenOut)
async def login(data: UserLogin, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == data.email))
    user = result.scalar_one_or_none()

    if not user or not verify_password(data.password, user.password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Account is deactivated",
        )

    if not user.is_verified:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Please verify your email before logging in",
        )

    token = create_access_token({"sub": str(user.id), "role": user.role})
    return TokenOut(access_token=token, user=UserOut.model_validate(user))


@router.get("/me", response_model=UserOut)
async def get_me(current_user: User = Depends(get_current_user)):
    return current_user
