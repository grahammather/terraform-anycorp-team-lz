resource "null_resource" "echo_message" {
  provisioner "local-exec" {
    command = "echo \"Dev environment infrastructure\""
  }
}
