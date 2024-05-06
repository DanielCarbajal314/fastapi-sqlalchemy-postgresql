from ...infrastructure import UnitOfWork
from typing import TypeVar, Generic
from abc import abstractmethod
from pydantic import BaseModel


class BaseRequest(BaseModel):
    pass


class BaseResponse(BaseModel):
    pass


TRequest = TypeVar("TRequest", bound=BaseRequest)
TResponse = TypeVar("TResponse", bound=BaseResponse)


class BaseHandler(Generic[TRequest, TResponse]):
    unit_of_work: UnitOfWork

    def __init__(self, unit_of_work: UnitOfWork):
        self.unit_of_work = unit_of_work

    @abstractmethod
    def execute(self, request: TRequest) -> TResponse:
        pass
