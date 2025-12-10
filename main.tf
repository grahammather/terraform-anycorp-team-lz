resource "tfe_project" "project" {
  name = "${var.apm_name} project"
}

resource "tfe_workspace" "workspace" {
  for_each = toset(var.environments)

  name = "${var.apm_name} ${each.key} workspace"
}