resource "digitalocean_kubernetes_cluster" "primary" {
  name   = var.cluster_name
  region = "nyc1"
  # Grab the latest version slug from `doctl kubernetes options versions`
  version = "1.26.3-do.0"

  node_pool {
    name       = "shared"
    size       = "s-2vcpu-2gb"
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

resource "kubernetes_namespace" "ingress" {
  metadata {
    labels = {
      service_namespace = "ingress"
    }

    name = "ingress"
  }
}
