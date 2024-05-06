from sqlalchemy.orm import Session
from ....database import Book
from .GetBookParams import GetBookParams


class BookRepository:
    __session: Session

    def __init__(self, session: Session) -> None:
        self.__session = session

    def get_books(self, request: GetBookParams):
        query = self.__session.query(Book)
        if request.author:
            query = query.filter(Book.author.like(f"{request.author}%"))
        if request.language:
            query = query.filter(Book.language.like(f"{request.language}%"))
        if request.title:
            query = query.filter(Book.title.like(f"{request.title}%"))
        offset = ((request.page - 1) * request.size) if request.page else 0
        return query.offset(offset).limit(request.size).all()

    def create_book(self, request: Book) -> Book:
        self.__session.add(request)
        self.__session.flush()
        self.__session.refresh(request)
        return request
