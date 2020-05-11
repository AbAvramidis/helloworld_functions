terraform {
  required_version = "0.12.16"
  backend "gcs" {}
}

provider "google" { version = "2.18.0" }
provider "google-beta" { version = "2.18.0" }

variable "project" { description = "Project id" }
variable "env_name" { description = "Name of the environment" }
variable "env_branch" { description = "The name of the branch of the repos for each environment" }
variable "region" { default = "europe-west2" }

variable "entry_point" { default = "main" }
variable "runtime" { default = "python37" }
variable "memory" { default = "128" }
variable "timeout" { default = "120" }
variable "func_name" { default = "hello_world" }
variable "repo_name" { description = "URL for the repo contains functions source code" }
variable "func_label" { description = "Label of the function" }
variable "repo_project" { description = "project containing the repo" }
variable "env_vars" {
  type    = map(string)
  default = {}
}

locals {
  project      = jsondecode(var.project)
  repo_project = jsondecode(var.repo_project)
}

resource "google_cloudfunctions_function" "function" {
  project               = local.project.project_id
  region                = var.region
  name                  = var.func_name
  description           = "nexus-${var.func_name}-function-${var.env_name}"
  runtime               = var.runtime
  available_memory_mb   = var.memory
  service_account_email = var.cf-sa
  source_repository {
    url = "https://source.developers.google.com/projects/${local.repo_project.project_id}/repos/${var.repo_name}/moveable-aliases/${var.env_branch}"

  }
  trigger_http = true
  timeout      = var.timeout
  entry_point  = var.entry_point
  labels = {
    my-label = var.func_label
  }

  environment_variables = var.env_vars
}
