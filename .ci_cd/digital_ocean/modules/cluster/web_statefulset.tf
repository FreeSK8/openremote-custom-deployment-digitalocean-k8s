
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
          name = "customize-openremote-deployment"
          image = "${var.container_registry}/openremote/custom-deployment:${var.custom_deployment_hash}"
          volume_mount {
            mount_path = "/deployment"
            name = "deployment-data"
          }
          volume_mount {
            mount_path = "/manager"
            name = "manager-data"
          }
          command = [
            "/bin/sh",
            "-c",
            <<-EOT
              cp -r /deployment-source/* /deployment/ && \
              /bin/chmod -R 700 /deployment && \
              /bin/chown -R 185 /deployment && \
              /bin/chmod -R 700 /manager && \
              /bin/chown -R 185 /manager
            EOT
          ]
        }
        container {
          image = "openremote/keycloak:latest"
          name = "keycloak"
          port {
            container_port = 8080
            name = "http-keycloak"
          }
          resources {
            limits = {
              cpu = "400m"
            }
            requests = {
              cpu = "51m"
            }
          }
          readiness_probe {
            http_get {
              path   = "/auth/health/ready"
              port   = 8080
            }

            initial_delay_seconds = 30
            timeout_seconds       = 30
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
            value = "postgresql.backend.svc.cluster.local"
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
            name = "PROXY_ADDRESS_FORWARDING"
            value = "true"
          }
        }
        container {
          image = "openremote/manager:latest"
          name = "manager"
          resources {
            limits = {
              cpu = "400m"
            }
            requests = {
              cpu = "51m"
            }
          }
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
            value = "postgresql.backend.svc.cluster.local"
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
            value = "web.default.svc.cluster.local"
          }
          env {
            name = "OR_KEYCLOAK_PORT"
            value = "8080"
          }
          env {
            name = "OR_MAP_TILES_PATH"
            value = "/deployment/map/mapdata.mbtiles"
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
