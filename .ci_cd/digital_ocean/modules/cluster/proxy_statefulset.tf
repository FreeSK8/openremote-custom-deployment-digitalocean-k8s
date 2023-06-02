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
            "/bin/chmod -R 777 /proxy"
          ]
          volume_mount {
            mount_path = "/proxy"
            name = "proxy-data"
          }
        }
        container {
          image = "${container_registry}/openremote/proxy:${var.proxy_image_hash}"
          name = "haproxy"
          volume_mount {
            mount_path = "/deployment"
            name = "proxy-data"
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
