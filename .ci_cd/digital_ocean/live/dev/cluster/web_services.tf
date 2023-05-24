resource "kubernetes_service" "web" {
  metadata {
    labels = {
      app = "web"
    }
    name = "web"
    namespace = "default"
  }
  
  spec {
    selector = {
      app = "web"
    }
    port {
      port = 8080
      name = "http-keycloak"
    }
    port {
      port = 8090
      name = "http-manager"
    }
    port {
      port = 443
      name = "https"
    }
    port {
      port = 8883
      name = "mqtt"
    }
  }
}
