output "cluster_issuers" {
  value = {
    for key, issuer in local.issuers:
      key => issuer.metadata.name
  }
}
