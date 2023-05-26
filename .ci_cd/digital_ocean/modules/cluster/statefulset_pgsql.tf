
resource "kubernetes_stateful_set" "pgsql" {
  metadata {
    name = "pgsql"
    namespace = "backend"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "pgsql"
      }
    }
    service_name = "pgsql"
    template {
      metadata {
        labels = {
          app = "pgsql"
        }
      }
      spec {
        init_container {
          name = "pgsql-perms-fix"
          image = "busybox"
          command = ["/bin/chmod","-R","777", "/data"]
          volume_mount {
            mount_path = "/data"
            name = "postgresql-data"
          }
        }  
        container {
          image = "openremote/postgresql:latest"
          name = "postgresql"
          volume_mount {
            mount_path = "/var/lib/postgresql"
            name = "postgresql-data"
          }
          port {
            container_port = 5432
            protocol = "TCP"
            name = "pgsql"
          }
          env {
            name = "POSTGRES_USER"
            value = "postgres"
          }
          env {
            name = "POSTGRES_PASSWORD"
            value = "postgres"
          }
          env {
            name = "POSTGRES_DB"
            value = "openremote"
          }
        }
        termination_grace_period_seconds = 10
      }
    }
    volume_claim_template {
      metadata {
        name = "postgresql-data"
        namespace = "backend"
      }
      spec {
        access_modes = [
          "ReadWriteOnce",
        ]
        volume_name = "postgresql-data"
        resources {
          requests = {
            storage = "5Gi"
          }
        }
        storage_class_name = "do-block-storage"
      }
    }
  }
}
