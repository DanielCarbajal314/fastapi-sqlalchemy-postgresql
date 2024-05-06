from pydantic import BaseModel
from sqlalchemy import Column, String, Integer
from .shared.IntegerIdEntity import IntegerIdEntity
from .shared.base import Base


class Book(Base, IntegerIdEntity):
    __tablename__ = "books"
    author = Column(String, index=True)
    country = Column(String)
    language = Column(String, index=True)
    link = Column(String)
    pages = Column(Integer)
    title = Column(String, index=True)
    year = Column(Integer)
