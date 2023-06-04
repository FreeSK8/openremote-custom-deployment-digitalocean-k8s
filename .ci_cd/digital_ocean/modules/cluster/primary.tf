resource "digitalocean_kubernetes_cluster" "primary" {
  name   = var.cluster_name
  region = var.region
  # Grab the latest version slug from `doctl kubernetes options versions`
  version = "1.27.2-do.0"

  node_pool {
    name       = "${var.environment}-sk8net-web"
    size       = var.instance_type
    node_count = var.node_count
  }
}

resource "digitalocean_container_registry" "openremote" {
  name                   = element(split("/", var.container_registry), 1)
  subscription_tier_slug = "basic"
}

resource "kubernetes_namespace" "backend" {
  metadata {
    labels = {
      service_namespace = "backend"
    }

    name = "backend"
  }
}

resource "kubernetes_namespace" "frontend" {
  metadata {
    labels = {
      service_namespace = "frontend"
    }

    name = "frontend"
  }
}
