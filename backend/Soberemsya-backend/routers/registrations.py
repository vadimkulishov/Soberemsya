from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
import uuid
import models
import schemas
from database import get_db
from auth import get_current_user, require_user, require_organizer, require_admin
from typing import Optional

router = APIRouter(prefix="/api/registrations", tags=["registrations"])


@router.post("/register-event", response_model=schemas.EventRegistrationResponse)
def register_event(
    request: schemas.EventRegistrationRequest,
    current_user: models.User = Depends(require_user),
    db: Session = Depends(get_db)
):
    """Register user for an event"""
    # Check if event exists
    event = db.query(models.Event).filter(models.Event.id == request.event_id).first()
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")

    # Check if already registered
    existing = db.query(models.EventRegistration).filter(
        models.EventRegistration.user_id == current_user.id,
        models.EventRegistration.event_id == request.event_id
    ).first()

    if existing:
        raise HTTPException(status_code=400, detail="Already registered for this event")

    # Create registration
    registration = models.EventRegistration(
        user_id=current_user.id,
        event_id=request.event_id
    )
    db.add(registration)
    db.commit()
    db.refresh(registration)

    return registration


@router.get("/my-tickets", response_model=schemas.UserTicketsResponse)
def get_my_tickets(
    current_user: models.User = Depends(require_user),
    db: Session = Depends(get_db)
):
    """Get all tickets for current user"""
    user = db.query(models.User).filter(models.User.id == current_user.id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    return user


@router.post("/generate-qr", response_model=schemas.UserQRTokenResponse)
def generate_qr_token(
    current_user: models.User = Depends(require_user),
    db: Session = Depends(get_db)
):
    """Generate or refresh QR token (valid for 24 hours)"""
    # Delete old token if exists
    db.query(models.UserQRToken).filter(
        models.UserQRToken.user_id == current_user.id
    ).delete()

    # Create new token
    token = str(uuid.uuid4())
    expires_at = datetime.utcnow() + timedelta(hours=24)

    qr_token = models.UserQRToken(
        user_id=current_user.id,
        token=token,
        expires_at=expires_at
    )
    db.add(qr_token)
    db.commit()
    db.refresh(qr_token)

    return qr_token


@router.get("/get-qr", response_model=schemas.UserQRTokenResponse)
def get_qr_token(
    current_user: models.User = Depends(require_user),
    db: Session = Depends(get_db)
):
    """Get current QR token or generate if not exists"""
    qr_token = db.query(models.UserQRToken).filter(
        models.UserQRToken.user_id == current_user.id
    ).first()

    if not qr_token or datetime.utcnow() > qr_token.expires_at:
        # Generate new token
        token = str(uuid.uuid4())
        expires_at = datetime.utcnow() + timedelta(hours=24)

        if qr_token:
            qr_token.token = token
            qr_token.expires_at = expires_at
            qr_token.created_at = datetime.utcnow()
        else:
            qr_token = models.UserQRToken(
                user_id=current_user.id,
                token=token,
                expires_at=expires_at
            )
            db.add(qr_token)

        db.commit()
        db.refresh(qr_token)

    return qr_token


@router.get("/scan/{token}", response_model=schemas.UserTicketsResponse)
def scan_qr_code(
    token: str,
    current_user: models.User = Depends(require_organizer),
    db: Session = Depends(get_db)
):
    """Scan QR code and get user tickets (organizers only)"""
    qr_token = db.query(models.UserQRToken).filter(
        models.UserQRToken.token == token
    ).first()

    if not qr_token:
        raise HTTPException(status_code=404, detail="Invalid QR code")

    # Check if token is expired
    if datetime.utcnow() > qr_token.expires_at:
        raise HTTPException(status_code=400, detail="QR code expired")

    user = qr_token.user
    return user


@router.get("/scan-with-event/{token}")
def scan_qr_with_event(
    token: str,
    event_id: int = Query(...),
    current_user: models.User = Depends(require_organizer),
    db: Session = Depends(get_db)
):
    """Scan QR code for specific event and check if user is registered. Also return all user tickets."""
    qr_token = db.query(models.UserQRToken).filter(
        models.UserQRToken.token == token
    ).first()

    if not qr_token:
        raise HTTPException(status_code=404, detail="Invalid QR code")

    # Check if token is expired
    if datetime.utcnow() > qr_token.expires_at:
        raise HTTPException(status_code=400, detail="QR code expired")

    user = qr_token.user
    event = db.query(models.Event).filter(models.Event.id == event_id).first()

    if not event:
        raise HTTPException(status_code=404, detail="Event not found")

    # Check if user is registered for this event
    registration = db.query(models.EventRegistration).filter(
        models.EventRegistration.user_id == user.id,
        models.EventRegistration.event_id == event_id
    ).first()

    # Get all user's tickets (registered events)
    all_registrations = db.query(models.EventRegistration).filter(
        models.EventRegistration.user_id == user.id
    ).all()

    tickets = [schemas.EventResponse.from_orm(reg.event) for reg in all_registrations]

    return {
        "user_id": user.id,
        "email": user.email,
        "username": user.username,
        "full_name": user.full_name or user.username,
        "is_registered": registration is not None,
        "registered_at": registration.registered_at if registration else None,
        "tickets": tickets
    }


@router.delete("/unregister/{event_id}")
def unregister_event(
    event_id: int,
    current_user: models.User = Depends(require_user),
    db: Session = Depends(get_db)
):
    """Unregister from an event"""
    registration = db.query(models.EventRegistration).filter(
        models.EventRegistration.user_id == current_user.id,
        models.EventRegistration.event_id == event_id
    ).first()

    if not registration:
        raise HTTPException(status_code=404, detail="Registration not found")

    db.delete(registration)
    db.commit()

    return {"message": "Unregistered successfully"}


# Admin endpoints for user management
@router.get("/admin/users", response_model=list[schemas.UserListResponse])
def get_all_users(
    search: Optional[str] = Query(None),
    current_user: models.User = Depends(require_admin),
    db: Session = Depends(get_db)
):
    """Get list of all users (admins only) - searchable by username or email"""
    query = db.query(models.User)

    if search:
        search_pattern = f"%{search}%"
        query = query.filter(
            (models.User.username.ilike(search_pattern)) |
            (models.User.email.ilike(search_pattern))
        )

    users = query.all()
    return users


@router.post("/admin/change-role", response_model=schemas.RoleChangeResponse)
def change_user_role(
    request: schemas.ChangeUserRoleRequest,
    current_user: models.User = Depends(require_admin),
    db: Session = Depends(get_db)
):
    """Change user role (admins only)"""
    if request.new_role not in ["user", "organizer", "admin"]:
        raise HTTPException(status_code=400, detail="Invalid role. Must be 'user', 'organizer', or 'admin'")

    user = db.query(models.User).filter(models.User.id == request.user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.role = request.new_role
    db.commit()
    db.refresh(user)

    return schemas.RoleChangeResponse(
        id=user.id,
        username=user.username,
        email=user.email,
        role=user.role,
        message=f"Role changed to {request.new_role}"
    )
