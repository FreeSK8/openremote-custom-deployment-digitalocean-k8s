terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "do_token" {}
variable "pvt_key" {}

variable "frontend_hostname" {}
variable "certificate_id" {}
variable "loadbalancer_friendly_name" {}

provider "digitalocean" {
  token = var.do_token
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}
