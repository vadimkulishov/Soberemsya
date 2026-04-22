from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from sqlalchemy import text, inspect as sa_inspect
from database import engine
import models
from routers import auth, events, registrations
import os


def run_migrations():
    """Add missing columns to existing tables without wiping data."""
    try:
        inspector = sa_inspect(engine)
        tables = inspector.get_table_names()

        if "users" in tables:
            existing = {col["name"] for col in inspector.get_columns("users")}
            with engine.connect() as conn:
                if "full_name" not in existing:
                    conn.execute(text("ALTER TABLE users ADD COLUMN full_name VARCHAR"))
                if "city" not in existing:
                    conn.execute(text("ALTER TABLE users ADD COLUMN city VARCHAR"))
                if "phone" not in existing:
                    conn.execute(text("ALTER TABLE users ADD COLUMN phone VARCHAR"))
                if "role" not in existing:
                    conn.execute(text("ALTER TABLE users ADD COLUMN role VARCHAR DEFAULT 'user'"))
                conn.commit()
        
        if "events" in tables:
            existing = {col["name"] for col in inspector.get_columns("events")}
            with engine.connect() as conn:
                if "organizer_id" not in existing:
                    conn.execute(text("ALTER TABLE events ADD COLUMN organizer_id INTEGER"))
                conn.commit()
            print("✅ DB migration complete (Mobile API)")
    except Exception as e:
        print(f"⚠️ Migration warning: {e}")


run_migrations()
models.Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Soberemsya Mobile API",
    version="1.0.0",
    description="API для мобильного приложения iOS"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Подключаем только необходимые роутеры для мобильного приложения
app.include_router(auth.router)
app.include_router(events.router)
app.include_router(registrations.router)

# Mount static files for images
if os.path.exists("static"):
    app.mount("/static", StaticFiles(directory="static"), name="static")


@app.get("/health")
async def health_check():
    return {"status": "ok", "api": "mobile"}
