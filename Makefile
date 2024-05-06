up:
	docker compose up
build:
	docker compose build
down:
	docker compose down
down-clear:
	docker compose down -v
db-gui:
	open http://localhost:8080
shell-to-server:
	docker compose exec server bash
shell-to-server-api:
	docker compose exec server bash -c "python"
run-migrations:
	docker compose exec server bash -c "alembic upgrade head"
add-migrations:
	docker compose exec server bash -c "alembic revision --autogenerate -m /"$(name)/""
run-data-seeding:
	docker compose exec server bash -c "python -c \"from src.database import run_migrations; run_migrations();\""
format:
	docker compose exec server bash -c "black ./src"
