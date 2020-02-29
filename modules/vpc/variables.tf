variable "name" {
  type = string
}
variable "subnet" {
  type = string
  default = "10.0.0.0/12"
}
variable "zones" {
  type = list(string)
  default = [
    "ru-central1-a",
    "ru-central1-b",
    "ru-central1-c"]
}
