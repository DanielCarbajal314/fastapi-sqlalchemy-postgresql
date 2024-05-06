FROM python:3.11 as base

WORKDIR /code

COPY ./pyproject.toml /code/pyproject.toml
COPY ./alembic.ini /code/alembic.ini

RUN pip3 install -e .
RUN pip3 install .[dev]

FROM base as migration
COPY . /code/
CMD ["sh", "-c", "alembic upgrade head"]

FROM base as seed
COPY . /code/
CMD ["sh", "-c", "python -c \"from src.database import run_migrations; run_migrations();\""]

FROM base as dev
CMD ["sh", "-c", "uvicorn src.main:app --reload --host 0.0.0.0"]