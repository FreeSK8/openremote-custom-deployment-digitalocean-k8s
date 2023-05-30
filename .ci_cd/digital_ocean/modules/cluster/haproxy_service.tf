resource "kubernetes_service" "proxy" {
  metadata {
    labels = {
      app = "web"
    }
    name = "proxy"
    namespace = "frontend"
  }
  
  spec {
    selector = {
      app = "web"
    }
    port {
      port = 8080
      name = "http-haproxy"
    }
    port {
      port = 8443
      name = "https-haproxy"
    }
    port {
      port = 8404
      name = "stats-haproxy"
    }
    port {
      port = 1883
      name = "mqtt-haproxy"
    }
  }
}
