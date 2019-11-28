variable "name" {}
variable "subnet" {
  default = "10.0.0.0/12"
}
variable "zones" {
  default = [
    "ru-central1-a",
    "ru-central1-b",
    "ru-central1-c"]
}
