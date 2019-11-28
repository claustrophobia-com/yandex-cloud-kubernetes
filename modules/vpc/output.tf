output "vpc_id" {
  value = yandex_vpc_network.cluster.id
}

output "location_subnets" {
  value = [
    for s in yandex_vpc_subnet.cluster_subnets: {
      id = s.id
      zone = s.zone
    }
  ]
}

