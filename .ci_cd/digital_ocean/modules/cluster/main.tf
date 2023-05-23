resource "digitalocean_kubernetes_cluster" "primary" {
  name   = var.cluster_name
  region = "nyc1"
  # Grab the latest version slug from `doctl kubernetes options versions`
  version = "1.26.3-do.0"

  node_pool {
    name       = "shared"
    size       = "s-1vcpu-2gb"
    node_count = var.node_count
  }
}

resource "kubernetes_namespace" "backend" {
  metadata {
    labels = {
      service_namespace = "backend"
    }

    name = "backend"
  }
}

resource "digitalocean_project" "k8s" {
  name        = var.project_name
  description = var.description
  purpose     = "Web Application"
  environment = var.environment
  resources   = [digitalocean_kubernetes_cluster.primary.urn, ]
}
