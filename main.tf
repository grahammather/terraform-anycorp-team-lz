terraform {
  required_version = "~> 1.7"

  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "0.71.0"
    }
    vault = {
      source = "hashicorp/vault"
      version = "5.6.0"
    }
  }
}

# TFE landing zone
resource "tfe_project" "project" {
  name = "${var.apm_name} project"
}

resource "tfe_workspace" "workspace" {
  for_each = toset(var.environments)

  name = "${var.apm_name} ${each.key} workspace"
}

# Vault landing zone

# APM Policies

# tfc workspace run policy - TFE workspaces must be able to renew and revoke their own tokens
resource "vault_policy" "tfc_policy" {
  name = "tfc-policy"

  policy = <<EOT
# Allow tokens to query themselves
path "auth/token/lookup-self" {
  capabilities = ["read"]
}

# Allow tokens to renew themselves
path "auth/token/renew-self" {
    capabilities = ["update"]
}

# Allow tokens to revoke themselves
path "auth/token/revoke-self" {
    capabilities = ["update"]
}

EOT
}

resource "vault_policy" "secrets_reader" {
  name = "secrets-reader"

  policy = <<EOT
# Configure the actual secrets the token should have access to

# KV home directory
path "secret/${apm_name}/*" {
  capabilities = ["read"]
}

# Azure dynamic creds role
# the Azure creds themselves have more access (e.g. the ability to create infra)
# this is just the capabilities that the apm has to interact with Vault 
path "azure/creds/${apm_name}" {
  capabilities = ["read"]
}

EOT
}

# Enables the APM's TFE workspaces to access their secrets

# Creates a role for the jwt auth backend and uses bound claims
# to ensure that only the specified Terraform Cloud workspace will
# be able to authenticate to Vault using this role.
#
# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/jwt_auth_backend_role
resource "vault_jwt_auth_backend_role" "tfc_workspace_reader_role" {
  for_each = local.workspace_keys

  backend        = vault_jwt_auth_backend.tfc_jwt.path
  role_name      = "${var.apm_name}-tfc-workspace-reader-role"
  token_policies = [vault_policy.tfc_policy.name, vault_policy.secrets_reader]

  bound_audiences   = [local.tfc_vault_audience]
  bound_claims_type = "glob"
  bound_claims = {
    sub = "organization:${var.org_name}:project:${tfe_project.project.name}:workspace:${each.value.workspace_name}:run_phase:*"
  }
  user_claim = "terraform_full_workspace"
  role_type  = "jwt"
  token_ttl  = 1200
}

# assumes the Azure auth engine has been mounted elsewhere
# data "vault_auth_backend" "azure" {
#   path = "azure"
# }

# resource "vault_azure_auth_backend_role" "example" {
#   backend                         = vault_auth_backend.azure.path
#   role                            = "test-role"
#   bound_subscription_ids          = ["11111111-2222-3333-4444-555555555555"]
#   bound_resource_groups           = ["123456789012"]
#   token_ttl                       = 60
#   token_max_ttl                   = 120
#   token_policies                  = ["default", "dev", "prod"]
# }

# Secrets reader policy