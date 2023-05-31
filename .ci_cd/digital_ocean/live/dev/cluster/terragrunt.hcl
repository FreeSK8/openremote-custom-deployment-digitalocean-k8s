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
  state_bucket = "sk8net-terraform-states"
}
