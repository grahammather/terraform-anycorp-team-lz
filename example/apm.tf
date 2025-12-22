# prereqs
data "tfe_organizations" "this" {}

data "tfe_organization" "this" {
  name = data.tfe_organizations.this.names[0]

  lifecycle {
    precondition {
      condition     = length(data.tfe_organizations.this.names) == 1
      error_message = "Expected exactly one TFE organization for this token, but found ${length(data.tfe_organizations.this.names)}."
    }
  }
}

data "tfe_variable_set" "vault" {
  name = "Vault Varset"
  organization = data.tfe_organization.this.name
}

module "anycorp-team-lz" {
  source  = "./.."
  # insert required variables here

  apm_name = "apm123"
  environments = ["dev","prod"]

  # sensible defaults/static config
  vault_jwt_auth_path = "jwt"
  tfe_variable_set_vault_id = data.tfe_variable_set.vault.id
}