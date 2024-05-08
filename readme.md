# fastapi-sqlalchemy-postgresql-terraform-gcp
A fastapi backend with SqlAlchemy, Alembic and Postgresql fully containerized. To run the application it be run on a single command (asuming you have docker installed):
```
make build up
```
This command will: 
- start a __postgresql database__ running on port 5432
- Once the database is acception connections it will __run a container that will execute alembic migrations__ over postgresql database
- Once the migration container exits, it will run a __data seeding container__ to populate Books Data
- start a __pgadmin__ with the running database connection already stored on http://localhost:8080/ (After seeding container exited successfully)
- start the __server container__ in develpment mode (fastapi watch mode) (After seeding container exited successfully)
- start a __http-client container__ that hast [curl](https://curl.se/) and (jq)[https://jqlang.github.io/jq/] installed, to be used to query the book endpoint

The app comes with a battery of Make commands to make Development and CI/CD leaner

#### Requirements
This application was build in an ARM Mac (Sonoma M1 Mac)
- __Docker__ (support for Docker Compose version: '3.9', I used Docker version 25.0.3)
- __Terraform__ (v1.8.2 on darwin_arm64 provider registry.terraform.io/hashicorp/google v5.28.0)
- __gcloud__ (GCP CLI - Google Cloud SDK 472.0.0)

#### Quick Test for local development
Once you ran __make build up__ command, open a terminal pointing to the same path and execute:
```sh
make get-from-api path="/books?size=3&language=Spa&author=Gab"
```
This should show:
```json
[
  {
    "language": "Spanish",
    "pages": 417,
    "author": "Gabriel García Márquez",
    "title": "One Hundred Years of Solitude",
    "country": "Colombia",
    "link": "https://en.wikipedia.org/wiki/One_Hundred_Years_of_Solitude",
    "year": 1967,
    "id": 36
  },
  {
    "language": "Spanish",
    "pages": 368,
    "author": "Gabriel García Márquez",
    "title": "Love in the Time of Cholera",
    "country": "Colombia",
    "link": "https://en.wikipedia.org/wiki/Love_in_the_Time_of_Cholera",
    "year": 1985,
    "id": 37
  }
]
```
#### Usefull commands for local development:
__up__: Starts all the containers
__build__:  Builds all the containers
__down__: Stops the all containers
__down-clear__: Stops the all containers and delete their state (clean database)
__db-gui__: Opens a Browser on PgAdmin local URL
__shell-to-server__:  Shells into the server
__shell-to-server-api__: Shells into python console in the server
__run-migrations__:  Runs the Alembic Migrations (Executed on Server Container)
__add-migrations__: Add a Migration if Models Classes were updated (Executed on Server Container)
__run-data-seeding__: Runs the Data Seeding process in the local Database
__format__:  Runs black over all python code inside ./src path
__get-from-api__: Execute a CURL over the specified PATH and format the response with jq

### Server Architecture
This is a fastapi app, with some hexagonal architecture principles. It uses SQL Alchemy for Db access, but the persistan layer is abstracted with Repositories and Unit of work patterns. Fastapi helps with dependency inyection the the database connection. Aside from that we work with some CQS principles to create classes responsable for single use cases instead of a service layer with several application actions, which tend to be a class that becomes convoluted quite quickly.

#### Infrastructure:
The infrastructure is setup in GCP with terraform, it consist in:
- Cloud SQL: A postgresql db instance with __public IP Address__ (This is not adviced but doint it for the sake of simplicity)
- Docker Registry: The repository where we will upload the server docker image
- Cloud Run: A serverless PAAS for running contianer

To setup the project you can run the next commands:
- `terraform init`
- `gcloud auth application-default login`
- create file 'project.tfvars' with content:
```t
project_id = "model-folio-422602-t8"
db_password = "lopeZ20070331Lopez"
```
- `make terraform-plan`
- `make terraform-apply`
- `make run-migration-on-infra-database`
- `upload-server-container-to-registry`

This will create the infrastructure, run the migration/seeding docker compose over the created database and upload the server docker image that will be hosted on cloud run

Also I created the command `make run-server-image-pointing-to-database` to run the hosted image version of the server app pointing to the Cloud SQL postgresql database instance.

#### Future Improvements
- Right now the app has no unit or integration test, my idea is using something like Bruno to setup some Integration test in a docker container
- Terraform implementation is a bit slacky, it requires to use modules for a cleaner implementation of IaC
- I want to move Terraform and gcloud CLI to be runned inside a container and to inject the GCP credentials

#### Disclaimer
- GCP Infrastructure has light security, in a real sceneario I would have created VPC, more specific google iam policies and network rules. In this example for simplicity of use I created a public exposed Database which should never use in real life infrastructure.