from dataclasses import dataclass
from typing import Optional


@dataclass
class PaginatedQuery:
    size: int
    page: Optional[int]
