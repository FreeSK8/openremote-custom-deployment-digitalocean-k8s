resource "kubernetes_ingress_v1" "sk8net_mqtt" {
  wait_for_load_balancer = true

  metadata {
    name = "sk8net-mqtt"
    namespace = "default"
  }
  
  spec {
    ingress_class_name = "nginx-mqtt"

    default_backend {
      service {
        name = kubernetes_service.web.metadata.0.name
        port {
          name = "mqtt"
        }
      }
    }
  }
}
