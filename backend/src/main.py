from fastapi import Depends, FastAPI
from sqlalchemy.orm import Session
from .database import get_db
from .infrastructure import UnitOfWork
from .use_cases import GetBooksQueryParams, QueryBookHandler

app = FastAPI()


@app.get("/healthcheck/")
def healthcheck():
    return "Health - OK"


@app.get("/books/")
def get_books(params: GetBooksQueryParams = Depends(), db: Session = Depends(get_db)):
    unit_of_work = UnitOfWork(db)
    handler = QueryBookHandler(unit_of_work)
    return handler.execute(params)
