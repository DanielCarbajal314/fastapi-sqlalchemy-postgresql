from ..shared.BaseHandler import BaseResponse


class GetBooksQueryItem(BaseResponse):
    id: int
    author: str
    country: str
    language: str
    link: str
    title: str
    pages: int
    year: int
