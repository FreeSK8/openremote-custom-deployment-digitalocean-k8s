resource "kubernetes_service" "postgresql" {
  metadata {
    labels = {
      app = "postgresql"
    }
    name = "postgresql"
    namespace = "backend"
  }
  
  spec {
    selector = {
      app = "pgsql"
    }
    port {
      port = 5432
      name = "pgsql"
      target_port = "pgsql"
    }
  }
}
