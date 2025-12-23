variable "apm_name" {
  type = string
}

variable "environments" {
  type = list(string)

  validation {
    condition = alltrue([
      for v in var.environments : contains(["dev", "test", "prod"], v)
    ])

    error_message = "Valid environment values are: dev, test, prod."
  }
}

variable "vault_jwt_auth_path" {
  type = string
}

variable "tfe_variable_set_vault_id" {
  type = string
}
