from pydantic import BaseModel, EmailStr, field_validator
from typing import Optional, List
from datetime import datetime


class EventResponse(BaseModel):
    id: int
    title: str
    date: str
    location: str
    description: str
    category: str = "Другое"
    image_url: Optional[str] = None
    created_at: datetime

    @field_validator("category", mode="before")
    @classmethod
    def default_category(cls, v):
        return v if v else "Другое"

    model_config = {"from_attributes": True}


class EventListResponse(BaseModel):
    events: List[EventResponse]
    total: int
    page: int
    per_page: int


class UserCreate(BaseModel):
    email: EmailStr
    username: str
    password: str
    full_name: Optional[str] = None
    city: Optional[str] = None
    phone: Optional[str] = None


class UserLogin(BaseModel):
    email: str
    password: str


class UserResponse(BaseModel):
    id: int
    email: str
    username: str
    full_name: Optional[str] = None
    city: Optional[str] = None
    phone: Optional[str] = None
    role: str = "user"
    created_at: datetime

    model_config = {"from_attributes": True}


class TokenResponse(BaseModel):
    access_token: str
    token_type: str
    user: UserResponse


class EventRegistrationRequest(BaseModel):
    event_id: int


class EventRegistrationResponse(BaseModel):
    id: int
    user_id: int
    event_id: int
    registered_at: datetime
    event: EventResponse

    model_config = {"from_attributes": True}


class UserTicketsResponse(BaseModel):
    id: int
    email: str
    username: str
    registrations: List[EventRegistrationResponse]

    model_config = {"from_attributes": True}


class UserQRTokenResponse(BaseModel):
    token: str
    created_at: datetime
    expires_at: datetime

    model_config = {"from_attributes": True}


# Admin management schemas
class UserListResponse(BaseModel):
    id: int
    email: str
    username: str
    full_name: Optional[str] = None
    role: str
    created_at: datetime

    model_config = {"from_attributes": True}


class ChangeUserRoleRequest(BaseModel):
    user_id: int
    new_role: str  # user, organizer, admin


class RoleChangeResponse(BaseModel):
    id: int
    username: str
    email: str
    role: str
    message: str


# Mobile app schemas
class EventCreateRequest(BaseModel):
    title: str
    date: str
    location: str
    description: str
    category: Optional[str] = None
    image_url: Optional[str] = None


class EventUpdateRequest(BaseModel):
    title: Optional[str] = None
    date: Optional[str] = None
    location: Optional[str] = None
    description: Optional[str] = None
    category: Optional[str] = None
    image_url: Optional[str] = None


class ChangePasswordRequest(BaseModel):
    old_password: str
    new_password: str


class ChangeEmailRequest(BaseModel):
    new_email: str
    password: str  # Need password to confirm


class QRScanResult(BaseModel):
    user_id: int
    email: str
    username: str
    full_name: Optional[str]
    is_registered: bool
    registered_at: Optional[datetime] = None
    # Билеты пользователя
    tickets: list["EventResponse"] = []

    model_config = {"from_attributes": True}


class EventExtendedResponse(EventResponse):
    organizer_id: Optional[int] = None

    model_config = {"from_attributes": True}
