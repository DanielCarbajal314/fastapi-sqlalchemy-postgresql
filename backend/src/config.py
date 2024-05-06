from os import environ
from pydantic import BaseModel


class DatabaseSettings(BaseModel):
    url: str


class ConfigurationVariables(BaseModel):
    database: DatabaseSettings


configuration = ConfigurationVariables(
    database=DatabaseSettings(
        url=environ["POSTGRES_URL"],
    )
)
