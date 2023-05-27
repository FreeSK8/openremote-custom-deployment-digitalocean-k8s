terraform {
  source = "../../../modules/cluster"
}
inputs = {
  pvt_key = "~/.ssh/id_rsa"
  project_name = "sk8net-k8s-dev"
  cluster_name = "shared-dev"
  description = "A project for developing our kubernetes based deployment system."
  environment = "development"
  node_count = 2
  frontend_hostname = "stage.ride.sk8net.org"
  loadbalancer_friendly_name = "stage-fronted-proxy-sk8net"
  certificate_id = "915fb6b1-3371-4463-b5b0-44ea4cad5fa3"
}
