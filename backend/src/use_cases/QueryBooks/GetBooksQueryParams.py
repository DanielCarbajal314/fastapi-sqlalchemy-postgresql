from typing import Optional
from ..shared.BaseHandler import BaseRequest


class GetBooksQueryParams(BaseRequest):
    size: int
    page: Optional[int] = None
    author: Optional[str] = None
    language: Optional[str] = None
    title: Optional[str] = None
