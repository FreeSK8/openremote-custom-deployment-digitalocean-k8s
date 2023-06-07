resource "kubernetes_stateful_set" "proxy" {
  metadata {
    name = "proxy"
    namespace = "frontend"
    labels = {
      web_dependency = kubernetes_stateful_set.web.metadata.0.name
      loadbalancer_dependency = kubernetes_service.load_balancer.metadata.0.name
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "web"
      }
    }
    service_name = "proxy"

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
              /bin/chown -R 99  /proxy && \
              /bin/chmod -R 700 /proxy
            EOT
          ]
          volume_mount {
            mount_path = "/proxy"
            name = "proxy-data"
          }
        }
        container {
          image = "${var.container_registry}/openremote/proxy:${var.proxy_image_hash}"
          name = "haproxy"
          resources {
            limits = {
              cpu = "400m"
            }
            requests = {
              cpu = "102m"
            }
          }
          volume_mount {
            mount_path = "/deployment"
            name = "proxy-data"
          }
          volume_mount {
            mount_path = "/etc/haproxy/mqtt-certs"
            name = "cert"
            read_only = "true"
          }
          port {
            container_port = 8080
            name = "http-haproxy"
          }
          port {
            container_port = 8443
            name = "https-haproxy"
          }
          port {
            container_port = 8404
            name = "stats-haproxy"
          }
          port {
            container_port = 8883
            name = "mqtt-haproxy"
          }
          readiness_probe {
            http_get {
              path   = "/health-check"
              port   = 8080
            }

            initial_delay_seconds = 30
            timeout_seconds       = 30
          }
          env {
            name = "MANAGER_HOST"
            value = "web.default.svc.cluster.local"
          }
          env {
            name = "MANAGER_MQTT_PORT"
            value = "1883"
          }
          env {
            name = "MANAGER_WEB_PORT"
            value = "8090"
          }
          env {
            name = "KEYCLOAK_HOST"
            value = "web.default.svc.cluster.local"
          }
          env {
            name = "KEYCLOAK_PORT"
            value = "8080"
          }
          env {
            name = "LE_EMAIL"
            value = "admin@sk8net.org"
          }
          env {
            name = "DOMAINNAME"
            value = var.frontend_hostname
          }
          env {
            name = "CERT_DIR"
            value = "/deployment/certs"
          }
        }
        termination_grace_period_seconds = 10
        volume {
          name = "cert"
          secret {
            secret_name = "tls-openremote"
            items {
              key = "tls.crt"
              path = "tls.crt"
            }
            items {
              key = "tls.key"
              path = "tls.crt.key"
            }
          }
        }
      }
    }
    volume_claim_template {
      metadata {
        name = "proxy-data"
      }
      spec {
        volume_name = "proxy-data"
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
