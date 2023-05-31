resource "kubernetes_service" "load_balancer" {
  metadata {
    name = "load-balancer"
    namespace = "frontend"
    labels = {
      app = "web"
    }
    annotations = {
      "service.beta.kubernetes.io/do-loadbalancer-tls-passthrough" = "true"
      "service.beta.kubernetes.io/do-loadbalancer-name" = var.loadbalancer_friendly_name
      "service.beta.kubernetes.io/do-loadbalancer-tls-ports" = "443,8883"
    }
  }
  
  spec {
    type = "LoadBalancer"
    selector = {
      app = "web"
    }
    port {
      name = "http"
      port = 80
      target_port = "http-haproxy"
      protocol = "TCP"
    }
    port {
      name = "http-stats"
      port = 8404
      target_port = "stats-haproxy"
      protocol = "TCP"
    }
    port {
      name = "https"
      port = 443
      target_port = "https-haproxy"
      protocol = "TCP"
    }
    port {
      name = "mqtt"
      port = 8883
      target_port = "mqtt-haproxy"
      protocol = "TCP"
    }
  }
}
