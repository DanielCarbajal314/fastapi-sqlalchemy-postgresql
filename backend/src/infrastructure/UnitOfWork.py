from sqlalchemy.orm import Session
from .repositories import BookRepository


class UnitOfWork:
    __session: Session
    book_repository: BookRepository

    def __init__(self, session: Session) -> None:
        self.__session = session
        self.book_repository = BookRepository(session)
