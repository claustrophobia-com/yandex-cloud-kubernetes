data "external" "basic-auth" {
  program = ["bash", "${path.module}/scripts/htpasswd.sh"]
  query = {
    username = var.username
    password = var.password
  }
}
