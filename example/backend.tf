# Use the TF_TOKEN_app_terraform_io to set a User Token to authenticate with HCP Terraform.

terraform {
  cloud {
    organization = "anycorp-graham-admin"

    workspaces {
      project = "Default Project"
      name    = "terraform-anycorp-team-lz"
    }
  }
}
