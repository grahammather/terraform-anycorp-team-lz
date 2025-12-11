terraform {
  required_version = "~> 1.7"

  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "0.71.0"
    }
  }
}

resource "tfe_project" "project" {
  name = "${var.apm_name} project"
}

resource "tfe_workspace" "workspace" {
  for_each = toset(var.environments)

  name = "${var.apm_name} ${each.key} workspace"
}