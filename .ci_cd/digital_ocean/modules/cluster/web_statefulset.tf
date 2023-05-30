
resource "kubernetes_stateful_set" "web" {
  metadata {
    name = "web"
    namespace = "default"
    labels = {
      pgsql_dependency = kubernetes_stateful_set.pgsql.metadata.0.name
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "web"
      }
    }
    service_name = "web"
    template {
      metadata {
        labels = {
          app = "web"
        }
      }
      spec {
        init_container {
          name = "mounts-perms-fix"
          image = "busybox"
          command = [
            "/bin/sh",
            "-c",
            <<-EOT
              /bin/mkdir -p /deployment/manager && \
              /bin/chmod -R 777 /deployment && \
              /bin/chmod -R 777 /manager
            EOT
          ]
          volume_mount {
            mount_path = "/deployment"
            name = "deployment-data"
          }
          volume_mount {
            mount_path = "/manager"
            name = "manager-data"
          }
        }
        container {
          image = "openremote/keycloak:latest"
          name = "keycloak"
          port {
            container_port = 8080
            name = "http-keycloak"
          }
          volume_mount {
            mount_path = "/deployment"
            name = "deployment-data"
          }
          env {
            name = "KEYCLOAK_ADMIN"
            value = "admin"
          }
          env {
            name = "KEYCLOAK_ADMIN_PASSWORD"
            value = "password"
          }
          env {
            name = "KC_HOSTNAME"
            value = var.frontend_hostname
          }
          env {
            name = "KC_HOSTNAME_PATH"
            value = "auth"
          }
          env {
            name = "KC_HOSTNAME_ADMIN_URL"
            value = "https://${var.frontend_hostname}/auth"
          }
          env {
            name = "KC_DB_URL_HOST"
            value = "postgresql.backend"
          }
          env {
            name = "KC_HOSTNAME_STRICT_HTTPS"
            value = "true"
          }
          env {
            name = "KC_PROXY"
            value = "edge"
          }
          env {
            name = "KC_DB_URL"
            value = "jdbc:postgresql://postgresql.backend:5432/openremote?currentSchema=public"
          }
          env {
            name = "PROXY_ADDRESS_FORWARDING"
            value = "true"
          }
        }
        container {
          image = "registry.digitalocean.com/sk8net/openremote/manager:may25test00"
          name = "manager"
          port {
            container_port = 8090
            name = "http-manager"
          }
          port {
            container_port = 1883
            name = "mqtt"
          }
          volume_mount {
            mount_path = "/storage"
            name = "manager-data"
          }
          volume_mount {
            mount_path = "/deployment"
            name = "deployment-data"
          }
          env {
            name = "OR_DB_HOST"
            value = "postgresql.backend"
          }
          env {
            name = "OR_ADMIN_PASSWORD"
            value = "password"
          }
          env {
            name = "OR_HOSTNAME"
            value = var.frontend_hostname
          }
          env {
            name = "OR_SSL_PORT"
            value = "-1"
          }
          env {
            name = "OR_WEBSERVER_LISTEN_PORT"
            value = "8090"
          }
          env {
            name = "OR_DEV_MODE"
            value = 0
          }
          env {
            name = "KEYCLOAK_AUTH_PATH"
            value = "auth"
          }
          env {
            name = "OR_KEYCLOAK_HOST"
            value = "web.default"
          }
          env {
            name = "OR_KEYCLOAK_PORT"
            value = "8080"
          }
        }
        termination_grace_period_seconds = 10
      }
    }
    volume_claim_template {
      metadata {
        name = "deployment-data"
      }
      spec {
        access_modes = [
          "ReadWriteOnce",
        ]
        volume_name = "deployment-data"
        resources {
          requests = {
            storage = "5Gi"
          }
        }
        storage_class_name = "do-block-storage"
      }
    }
    volume_claim_template {
      metadata {
        name = "manager-data"
      }
      spec {
        volume_name = "manager-data"
        access_modes = [
          "ReadWriteOnce",
        ]
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
