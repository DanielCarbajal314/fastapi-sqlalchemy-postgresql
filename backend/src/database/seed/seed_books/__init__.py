import json
from ...get_db import SessionLocal
from ...entities.Book import Book


def get_books():
    with open("./src/database/seed/seed_books/books.json") as json_file:
        return json.load(json_file)


def seed_books():
    print("Running Book Seeding")
    books_dict = get_books()
    print(f"{len(books_dict)} books found on the json file")
    with SessionLocal() as db:
        books = [Book(**book) for book in books_dict]
        book_on_database_count = db.query(Book).count()
        print(f"{book_on_database_count} books found registered on the database")
        if not book_on_database_count:
            db.add_all(books)
            db.commit()
            print(f"{len(books)} books inserted on the database")
        else:
            print("Skipping Book Seeding, books already exist on the database")
        db.close()
