resource "kubernetes_ingress_v1" "sk8net" {
  wait_for_load_balancer = true
  metadata {
    name = "sk8net-web"
    namespace = "default"
  }
  spec {
    ingress_class_name = "nginx"
    tls {
      hosts = ["stage.ride.sk8net.org", "143.244.213.54"]
      secret_name = "dev-selfsigned"
    }
    default_backend {
      service {
        name = kubernetes_service.web.metadata.0.name
        port {
          name = "http-manager"
        }
      }
    }
    rule {
      host = "stage.ride.sk8net.org"
      
      http {
        path {
          path = "/auth"
          backend {
            service {
              name = kubernetes_service.web.metadata.0.name
              port {
                name = "http-keycloak"
              }
            }
          }
        }
      }
    }
  }
}
