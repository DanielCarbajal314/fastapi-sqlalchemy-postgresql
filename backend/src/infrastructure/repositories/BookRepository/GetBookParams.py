from dataclasses import dataclass
from ..shared.PaginatedQuery import PaginatedQuery
from typing import Optional


@dataclass
class GetBookParams(PaginatedQuery):
    author: Optional[str]
    language: Optional[str]
    title: Optional[str]
