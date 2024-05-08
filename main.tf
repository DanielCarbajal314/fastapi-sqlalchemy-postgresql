variable "project_id" {
  description = "The ID of the GCP project"
}

variable "db_password" {
  description = "The database password"
}

provider "google" {
  project = var.project_id
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_project_service" "container_registry" {
  project = var.project_id
  service = "containerregistry.googleapis.com"
}

resource "google_project_service" "cloud_run_admin" {
  project = var.project_id
  service = "run.googleapis.com"
}

resource "google_sql_database_instance" "main_instance" {
  name             = "main-postgresql-instance"
  database_version = "POSTGRES_13"
  region           = "us-central1"
  settings {
    tier = "db-f1-micro" 
    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
         name = "all_networks"
         value = "0.0.0.0/0"
      }
    }
  }
}

resource "google_sql_database" "main_database" {
  name     = "main-database"
  instance = google_sql_database_instance.main_instance.name
  charset  = "UTF8"
  collation = "en_US.UTF8"
}

resource "google_sql_user" "postgre_user" {
  name     = "postgresql_user"
  instance = google_sql_database_instance.main_instance.name
  password = var.db_password
}

data "google_container_registry_repository" "docker_repository" {
}

resource "google_cloud_run_service" "python_service" {
  name     = "python-run-service"
  location = "us-central1"

  template {
    spec {
      containers {
        image = format("%s/%s:latest",
          data.google_container_registry_repository.docker_repository.repository_url,
          "hosted_book_server"
        )
        ports {
          container_port = 80
        }
        env {
          name = "POSTGRES_URL"
          value = format("postgresql://%s:%s@%s/%s",
            google_sql_user.postgre_user.name,
            google_sql_user.postgre_user.password,
            google_sql_database_instance.main_instance.ip_address[0].ip_address,
            google_sql_database.main_database.name
          )
        }
      }
    }
  }
  depends_on = [ 
    google_project_service.cloud_run_admin,
    google_sql_database.main_database
  ]
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.python_service.location
  project     = google_cloud_run_service.python_service.project
  service     = google_cloud_run_service.python_service.name
  policy_data = data.google_iam_policy.noauth.policy_data
  depends_on = [ google_cloud_run_service.python_service ]
}

output "docker_repository_url" {
  value = data.google_container_registry_repository.docker_repository.repository_url
}

output "database_connection_url" {
  sensitive = true
  value = format("postgresql://%s:%s@%s/%s",
    google_sql_user.postgre_user.name,
    google_sql_user.postgre_user.password,
    google_sql_database_instance.main_instance.ip_address[0].ip_address,
    google_sql_database.main_database.name)
}

output "python_service_url" {
  value = google_cloud_run_service.python_service.status[0].url
}