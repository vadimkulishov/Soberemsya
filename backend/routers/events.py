from fastapi import APIRouter, Depends, Query, HTTPException, UploadFile, File
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session
from sqlalchemy import or_
from typing import Optional
from database import get_db
import models
import schemas
from auth import require_organizer, require_user
import os
import uuid
from pathlib import Path

router = APIRouter(prefix="/api/events", tags=["events"])

# Image upload configuration
UPLOAD_DIR = Path(__file__).parent.parent / "uploads"
UPLOAD_DIR.mkdir(exist_ok=True)
ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png", ".gif", ".webp"}
MAX_FILE_SIZE = 5 * 1024 * 1024  # 5MB


@router.post("", response_model=schemas.EventResponse)
def create_event(
    event: schemas.EventCreateRequest,
    current_user: models.User = Depends(require_organizer),
    db: Session = Depends(get_db),
):
    """Create a new event (organizers only)"""
    new_event = models.Event(
        title=event.title,
        date=event.date,
        location=event.location,
        description=event.description,
        category=event.category or "Другое",
        image_url=event.image_url,
        organizer_id=current_user.id,
    )
    db.add(new_event)
    db.commit()
    db.refresh(new_event)
    return new_event


@router.put("/{event_id}", response_model=schemas.EventResponse)
def update_event(
    event_id: int,
    event_data: schemas.EventUpdateRequest,
    current_user: models.User = Depends(require_organizer),
    db: Session = Depends(get_db),
):
    """Update an event (organizers only, must be creator)"""
    event = db.query(models.Event).filter(models.Event.id == event_id).first()
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    
    if event.organizer_id != current_user.id and current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Вы не можете редактировать это событие")
    
    if event_data.title is not None:
        event.title = event_data.title
    if event_data.date is not None:
        event.date = event_data.date
    if event_data.location is not None:
        event.location = event_data.location
    if event_data.description is not None:
        event.description = event_data.description
    if event_data.category is not None:
        event.category = event_data.category
    if event_data.image_url is not None:
        event.image_url = event_data.image_url
    
    db.commit()
    db.refresh(event)
    return event


@router.get("/my-events", response_model=schemas.EventListResponse)
def get_my_events(
    current_user: models.User = Depends(require_organizer),
    db: Session = Depends(get_db),
):
    """Get events created by current user (organizers only)"""
    events = db.query(models.Event).filter(
        models.Event.organizer_id == current_user.id
    ).all()
    return {"events": events, "total": len(events), "page": 1, "per_page": 100}


@router.get("", response_model=schemas.EventListResponse)
def list_events(
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    page: Optional[int] = Query(None, ge=1),
    per_page: Optional[int] = Query(None, ge=1, le=100),
    city: Optional[str] = Query(None),
    db: Session = Depends(get_db),
):
    # Support both skip/limit (Swift client) and page/per_page (REST pagination)
    if page is not None or per_page is not None:
        p = page or 1
        pp = per_page or 20
        offset = (p - 1) * pp
        size = pp
    else:
        offset = skip
        size = limit
        p = (skip // limit) + 1 if limit > 0 else 1
        pp = limit

    query = db.query(models.Event)
    # Note: city filter reserved for when events.city column is added
    total = query.count()
    events = (
        query
        .order_by(models.Event.id)
        .offset(offset)
        .limit(size)
        .all()
    )
    return {"events": events, "total": total, "page": p, "per_page": pp}


@router.get("/search", response_model=schemas.EventListResponse)
def search_events(
    q: str = Query(..., min_length=1),
    page: int = Query(1, ge=1),
    per_page: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db),
):
    pattern = f"%{q}%"
    query = db.query(models.Event).filter(
        or_(
            models.Event.title.ilike(pattern),
            models.Event.description.ilike(pattern),
            models.Event.location.ilike(pattern),
            models.Event.category.ilike(pattern),
        )
    )
    total = query.count()
    events = query.offset((page - 1) * per_page).limit(per_page).all()
    return {"events": events, "total": total, "page": page, "per_page": per_page}


@router.get("/{event_id}", response_model=schemas.EventResponse)
def get_event(event_id: int, db: Session = Depends(get_db)):
    event = db.query(models.Event).filter(models.Event.id == event_id).first()
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    return event


@router.post("/{event_id}/upload-image")
async def upload_event_image(
    event_id: int,
    file: UploadFile = File(...),
    current_user: models.User = Depends(require_organizer),
    db: Session = Depends(get_db),
):
    """Upload image for an event (organizers only)"""
    event = db.query(models.Event).filter(models.Event.id == event_id).first()
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    
    if event.organizer_id != current_user.id and current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Вы не можете редактировать это событие")
    
    # Validate file
    if not file.filename:
        raise HTTPException(status_code=400, detail="Файл не выбран")
    
    file_ext = Path(file.filename).suffix.lower()
    if file_ext not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=400,
            detail=f"Недопустимый формат. Допустимые: {', '.join(ALLOWED_EXTENSIONS)}"
        )
    
    # Check file size
    contents = await file.read()
    if len(contents) > MAX_FILE_SIZE:
        raise HTTPException(status_code=400, detail="Файл слишком большой (максимум 5MB)")
    
    # Generate unique filename
    unique_filename = f"{uuid.uuid4()}{file_ext}"
    file_path = UPLOAD_DIR / unique_filename
    
    # Save file
    with open(file_path, "wb") as f:
        f.write(contents)
    
    # Update event with image URL
    image_url = f"/api/events/images/{unique_filename}"
    event.image_url = image_url
    db.commit()
    db.refresh(event)
    
    return {"success": True, "image_url": image_url}


@router.get("/images/{filename}")
async def get_event_image(filename: str):
    """Serve event image"""
    # Security check - prevent directory traversal
    if ".." in filename or "/" in filename or "\\" in filename:
        raise HTTPException(status_code=403, detail="Доступ запрещен")
    
    file_path = UPLOAD_DIR / filename
    
    if not file_path.exists():
        raise HTTPException(status_code=404, detail="Изображение не найдено")
    
    return FileResponse(
        file_path,
        media_type="image/jpeg",
        headers={"Cache-Control": "public, max-age=86400"}
    )


@router.get("/category/{category}", response_model=schemas.EventListResponse)
def get_events_by_category(
    category: str,
    page: int = Query(1, ge=1),
    per_page: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db),
):
    query = db.query(models.Event).filter(models.Event.category.ilike(category))
    total = query.count()
    events = query.offset((page - 1) * per_page).limit(per_page).all()
    return {"events": events, "total": total, "page": page, "per_page": per_page}
