from ..shared.BaseHandler import BaseHandler
from .GetBooksQueryItem import GetBooksQueryItem
from .GetBooksQueryParams import GetBooksQueryParams
from typing import List


class QueryBookHandler(BaseHandler[GetBooksQueryParams, List[GetBooksQueryItem]]):
    def execute(self, request: GetBooksQueryParams) -> List[GetBooksQueryItem]:
        return self.unit_of_work.book_repository.get_books(request)
