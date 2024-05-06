from typing import Any, Generator
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from ..config import configuration

engine = create_engine(configuration.database.url)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def get_db() -> Generator[Session, Any, None]:
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
