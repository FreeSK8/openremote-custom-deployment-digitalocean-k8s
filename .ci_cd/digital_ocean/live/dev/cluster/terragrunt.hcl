terraform {
  source = "../../../modules/cluster"
}
inputs = {
  pvt_key = "~/.ssh/id_rsa"
  project_name = "sk8net-k8s-dev"
  cluster_name = "shared-dev"
  description = "A project for developing our kubernetes based deployment system."
  environment = "Development"
  node_count = 2
  frontend_hostname = "stage.ride.sk8net.org"
}
