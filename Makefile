define get_terraform_connection_string
	$(eval CONNECTION_URL := $(shell terraform output database_connection_url))
endef

define get_terraform_docker_registry_url
	$(eval DOCKER_REGISTRY_URL := $(shell terraform output docker_repository_url))
endef


up:
	@docker compose up
build:
	@docker compose build
down:
	@docker compose down
down-clear:
	@docker compose down -v
db-gui:
	@open http://localhost:8080
shell-to-server:
	@docker compose exec server bash
shell-to-server-api:
	@docker compose exec server bash -c "python"
run-migrations:
	@docker compose exec server bash -c "alembic upgrade head"
add-migrations:
	@docker compose exec server bash -c "alembic revision --autogenerate -m /"$(name)/""
run-data-seeding:
	@docker compose exec server bash -c "python -c \"from src.database import run_migrations; run_migrations();\""
format:
	@docker compose exec server bash -c "black ./src"
get-from-api:
	@docker compose exec http-client sh -c "curl -s \"http://server:8000$(path)\" | jq"
terraform-plan:
	@terraform plan -var-file="./project.tfvars"
terraform-apply:
	@terraform apply -var-file="./project.tfvars"
terraform-refresh:
	@terraform refresh -var-file="./project.tfvars"
terraform-destroy:
	@terraform destroy -var-file="./project.tfvars"
run-migration-on-infra-database:
	$(MAKE) terraform-refresh
	$(call get_terraform_connection_string)
	CONNECTION_URL=${CONNECTION_URL} docker compose -f ./docker-compose.database.deploy.yml up
build-hosted-image:
	docker build -f ./backend/Dockerfile.host ./backend -t hosted_book_server
build-hosted-image-amd64:
	docker build --platform="linux/amd64" -f ./backend/Dockerfile.host ./backend -t hosted_book_server
run-server-image-pointing-to-database:
	$(MAKE) build-hosted-image
	$(MAKE) terraform-refresh
	$(call get_terraform_connection_string)
	docker run -p 8888:80 -e POSTGRES_URL=${CONNECTION_URL} hosted_book_server 
upload-server-container-to-registry:
	gcloud auth configure-docker
	$(MAKE) build-hosted-image-amd64
	$(MAKE) terraform-refresh
	$(call get_terraform_docker_registry_url)
	docker tag hosted_book_server ${DOCKER_REGISTRY_URL}/hosted_book_server
	docker push ${DOCKER_REGISTRY_URL}/hosted_book_server
	