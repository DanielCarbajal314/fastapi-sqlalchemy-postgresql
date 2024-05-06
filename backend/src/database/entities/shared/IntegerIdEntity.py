from sqlalchemy import Column, Integer


class IntegerIdEntity:
    id = Column(Integer, primary_key=True, autoincrement="auto")
