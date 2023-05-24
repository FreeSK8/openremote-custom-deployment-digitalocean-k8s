
resource "kubernetes_stateful_set" "web" {
  metadata {
    name = "web"
    namespace = "default"
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
        container {
          image = "openremote/keycloak:latest"
          name = "keycloak"
          port {
            container_port = 8080
            name = "http-keycloak"
          }
          port {
            container_port = 8081
            name = "https-keycloak"
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
            value = "stage.ride.sk8net.org"
          }
          env {
            name = "KC_HOSTNAME_ADMIN_URL"
            value = "https://stage.ride.sk8net.org/auth"
          }
          env {
            name = "KC_DB_URL_HOST"
            value = "postgresql.backend"
          }
          env {
            name = "KC_HOSTNAME_STRICT_HTTPS"
            value = "false"
          }
          env {
            name = "KC_PROXY"
            value = "edge"
          }
          env {
            name = "KC_DB_URL"
            value = "jdbc:postgresql://postgresql.backend:5432/openremote?currentSchema=public"
          }
        }
        container {
          image = "openremote/manager:latest"
          name = "manager"
          port {
            container_port = 8090
            name = "http-manager"
          }
          port {
            container_port = 8443
            name = "https"
          }
          port {
            container_port = 8883
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
            value = "stage.ride.sk8net.org"
          }
          env {
            name = "OR_SSL_PORT"
            value = "8443"
          }
          env {
            name = "OR_WEBSERVER_LISTEN_PORT"
            value = "8090"
          }
          env {
            name = "OR_MAP_TILES_PATH"
            value = "/efs/europe.mbtiles"
          }
          env {
            name = "OR_DEV_MODE"
            value = 0
          }
          env {
            name = "KEYCLOAK_AUTH_PATH"
            value = ""
          }
          env {
            name = "OR_KEYCLOAK_HOST"
            value = "localhost"
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
          "ReadWriteMany",
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
          "ReadWriteMany",
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
