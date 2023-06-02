terraform {
  source = "../../../modules/cluster"
}
inputs = {
  region = "nyc3"
  instance_type = "s-1vcpu-2gb"
  pvt_key = "~/.ssh/id_rsa"
  cluster_name = "shared-dev"
  environment = "development"
  node_count = 2
  frontend_hostname = "stage.ride.sk8net.org"
  loadbalancer_friendly_name = "stage-fronted-proxy-sk8net"
  container_registry = "registry.digitalocean.com/sk8net"
  manager_deployment_hash = "73a6f457c"
  custom_deployment_hash = "30bb6d5"
}
include "root" {
  path = find_in_parent_folders()
}
