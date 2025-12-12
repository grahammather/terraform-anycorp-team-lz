locals {
  tfc_vault_audience = "vault.workload.identity"

  workspace_keys = {
    for k, w in tfe_workspace.workspace :
    k => {
      workspace_name = w.name
      workspace_id = w.id
      workspace_vault_role_name = "${var.apm_name}-tfc-${w.name}-reader-role"
    }
  }

}