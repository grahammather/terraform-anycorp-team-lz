locals {
  tfc_vault_audience = "vault.workload.identity"

  workspace_keys = {
    for k, w in tfe_workspace.workspace :
    k => {
      workspace_name = w.name
    }
  }

}