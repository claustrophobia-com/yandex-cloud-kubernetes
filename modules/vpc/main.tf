resource "yandex_vpc_network" "cluster" {
  name = var.name
}

resource "yandex_vpc_subnet" "cluster_subnets" {
  count = length(var.zones)

  name = "${var.name}-${var.zones[count.index]}"
  v4_cidr_blocks = [cidrsubnet(var.subnet, length(var.zones)+1, count.index)]
  zone = var.zones[count.index]
  network_id = yandex_vpc_network.cluster.id
}

