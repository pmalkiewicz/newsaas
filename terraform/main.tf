provider "google" {
  project = var.project
  region = var.region
}

resource "google_project_service" "cloud-run" {
  project = var.project
  service = "run.googleapis.com"
}

resource "google_project_service" "cloud-scheduler" {
  project = var.project
  service = "cloudscheduler.googleapis.com"
}

resource "google_project_service" "appengine" {
  project = var.project
  service = "appengine.googleapis.com"
}

# Cloud Scheduler requires App Engine app to be created in the project to be able to run, so this dummy app is needed
resource "google_app_engine_application" "dummy" {
  project     = var.project
  location_id = var.app_engine_location_id
}

resource "google_service_account" "cloud-run" {
  account_id = "${var.name}-cloud-run"
  display_name = "${var.name} Cloud Run Account"
}

resource "google_service_account" "cloud-scheduler" {
  account_id = "${var.name}-cloud-scheduler"
  display_name = "${var.name} Cloud Scheduler Account"
}

resource "google_project_iam_member" "cloud-scheduler-sa-binding" {
  project = var.project
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.cloud-scheduler.email}"
}

resource "google_cloud_run_service" "service" {
  name     = var.name
  location = var.region
  template {
    spec {
      containers {
        image = var.image
        env {
          name = "USERNAME"
          value = var.smtp_username
        }
        env {
          name = "PASSWORD"
          value = var.smtp_password
        }
        env {
          name = "SERVER"
          value = var.smtp_server
        }
        env {
          name = "SMTP_PORT"
          value = var.smtp_port
        }
      }
      container_concurrency = 1
      timeout_seconds = var.timeout
      service_account_name = google_service_account.cloud-run.email
    }
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = "1"
      }
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_scheduler_job" "job" {
  name        = var.name
  schedule    = var.schedule
  attempt_deadline = "${var.timeout}s"
  
  retry_config {
    retry_count = 1
  }

  http_target {
    http_method = "POST"
    uri         = "${google_cloud_run_service.service.status[0].url}/run?recipe=${urlencode(var.recipe)}&email=${join("&email=", [for x in var.emails : urlencode(x)])}"

    oidc_token {
      service_account_email = google_service_account.cloud-scheduler.email
    }
  }
}
