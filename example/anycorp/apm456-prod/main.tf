resource "null_resource" "echo_message" {
  provisioner "local-exec" {
    command = "echo \"Prod environment infrastructure\""
  }
}
