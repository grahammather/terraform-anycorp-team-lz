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