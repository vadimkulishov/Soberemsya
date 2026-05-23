from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, DeclarativeBase
import os

# Use SQLite for development if PostgreSQL is not available
db_path = os.path.join(os.path.dirname(__file__), "soberemsya.db")
DATABASE_URL = os.getenv("DATABASE_URL", f"sqlite:///{db_path}")

# For PostgreSQL, uncomment the line below and comment out SQLite
# DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://localhost/soberemsya")

if DATABASE_URL.startswith("sqlite"):
    engine = create_engine(
        DATABASE_URL,
        connect_args={"check_same_thread": False},
        poolclass=None,  # Disable connection pooling
        echo=False
    )
else:
    engine = create_engine(DATABASE_URL)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


class Base(DeclarativeBase):
    pass


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
