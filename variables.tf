variable "yandex_token" {
  type = string
}
variable "yandex_cloud_id" {
  type = string
}
variable "yandex_folder_id" {
  type = string
}
variable "cluster_name" {
  type = string
}
variable "cluster_version" {
  type = string
  default = "1.15"
}
variable "cluster_release_channel" {
  type = string
  default = "STABLE"
}
variable "node_groups_scale" {
  default = {
    service = {
      fixed_scale = 3
    }
    nfs = {
      fixed_scale = 1
    }
    web = {
      auto_scale = {
        max = 3
        min = 3
        initial = 3
      }
    }
  }
}
variable "admin_email" {
  type = string
}
variable "cluster_domain" {
  type = string
}
variable "admins" {
  type = map(object({
    public_keys = list(string)
  }))
}
variable "output_dir" {
  type = string
  default = "output"
}
