module "anycorp-team-lz" {
  source  = ".."
  # insert required variables here

  apm_name = "apm123"
  environments = ["dev","prod"]

  # sensible defaults/static config
  vault_jwt_auth_path = local.vault_jwt_auth_path
  tfe_variable_set_vault_id = tfe_variable_set.vault.id
}