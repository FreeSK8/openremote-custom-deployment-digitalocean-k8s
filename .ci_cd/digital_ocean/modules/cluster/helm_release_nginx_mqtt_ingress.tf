/*resource "helm_release" "nginx_mqtt" {
  name       = "nginx-mqtt"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress"
  version    = "4.6.1"

  values = [
    "${file("nginx-values-mqtt-v4.6.1.yaml")}"
  ]

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/do-loadbalancer-name"
    value = var.loadbalancer_friendly_name
    type  = "string"
  }
}
*/