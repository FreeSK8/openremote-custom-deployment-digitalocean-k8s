resource "helm_release" "nginx" {
  name       = "nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress"
  version    = "4.6.1"

  values = [
    "${file("nginx-values-v4.6.1.yaml")}"
  ]

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/do-loadbalancer-certificate-id"
    value = var.certificate_id
    type  = "string"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/do-loadbalancer-hostname"
    value = var.frontend_hostname
    type  = "string"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/do-loadbalancer-name"
    value = var.loadbalancer_friendly_name
    type  = "string"
  }

  set {
    name = "controller.publishService.enabled"
    value = "true"
    type = "string"
  }
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    host = "${digitalocean_kubernetes_cluster.primary.endpoint}"
    client_certificate     = "${base64decode(digitalocean_kubernetes_cluster.primary.kube_config.0.client_certificate)}"
    client_key             = "${base64decode(digitalocean_kubernetes_cluster.primary.kube_config.0.client_key)}"
    cluster_ca_certificate = "${base64decode(digitalocean_kubernetes_cluster.primary.kube_config.0.cluster_ca_certificate)}"
  }
}
