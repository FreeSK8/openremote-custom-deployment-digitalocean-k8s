
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
          command = [
            "/bin/sh",
            "-c",
            <<-EOT
              /bin/chown -R 70  /data && \
              /bin/chmod -R 700 /data
            EOT
          ]
          volume_mount {
            mount_path = "/data"
            name = "postgresql-data"
          }
        }  
        container {
          image = "openremote/postgresql:latest"
          name = "postgresql"
          resources {
            requests = {
              cpu = "102m"
            }
          }
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
