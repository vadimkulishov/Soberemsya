from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from pydantic import BaseModel
import models
import schemas
from auth import hash_password, verify_password, create_token, require_user

router = APIRouter(prefix="/api/auth", tags=["auth"])


@router.post("/register", response_model=schemas.TokenResponse)
def register(data: schemas.UserCreate, db: Session = Depends(get_db)):
    if db.query(models.User).filter(models.User.email.ilike(data.email)).first():
        raise HTTPException(status_code=400, detail="Email already registered")
    user = models.User(
        email=data.email.lower(),
        username=data.username,
        hashed_password=hash_password(data.password),
        full_name=data.full_name,
        city=data.city,
        phone=data.phone,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return {"access_token": create_token(user.id), "token_type": "bearer", "user": user}


@router.post("/login", response_model=schemas.TokenResponse)
def login(data: schemas.UserLogin, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.email.ilike(data.email)).first()
    if not user or not verify_password(data.password, user.hashed_password):
        raise HTTPException(status_code=401, detail="Неверный email или пароль")
    return {"access_token": create_token(user.id), "token_type": "bearer", "user": user}


@router.get("/profile", response_model=schemas.UserResponse)
def profile(current_user=Depends(require_user)):
    return current_user


@router.post("/change-password")
def change_password(
    data: schemas.ChangePasswordRequest,
    current_user: models.User = Depends(require_user),
    db: Session = Depends(get_db),
):
    if not verify_password(data.old_password, current_user.hashed_password):
        raise HTTPException(status_code=400, detail="Неверный текущий пароль")
    if len(data.new_password) < 6:
        raise HTTPException(status_code=400, detail="Новый пароль должен быть не менее 6 символов")
    current_user.hashed_password = hash_password(data.new_password)
    db.commit()
    return {"message": "Пароль успешно изменён"}


@router.post("/change-email")
def change_email(
    data: schemas.ChangeEmailRequest,
    current_user: models.User = Depends(require_user),
    db: Session = Depends(get_db),
):
    if not verify_password(data.password, current_user.hashed_password):
        raise HTTPException(status_code=400, detail="Неверный пароль")

    # Check if email already exists
    existing = db.query(models.User).filter(
        models.User.email.ilike(data.new_email),
        models.User.id != current_user.id
    ).first()
    if existing:
        raise HTTPException(status_code=400, detail="Email уже зарегистрирован")

    current_user.email = data.new_email.lower()
    db.commit()
    db.refresh(current_user)
    return {"message": "Email успешно изменён", "user": current_user}
