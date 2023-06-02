variable "state_bucket" {
  description = "S3 (aka Spaces) bucket to store the terraform state in"
  type        = string
}

variable "instance_type" {
  description = "Type of host resources to spawn for the kubernetes cluster"
  type        = string
}

variable "region" {
  description = "DO region for the host resources to spawn within"
  type        = string
}

variable "node_count" {
  description = "The number of nodes to provision for the cluster"
  type        = number
}

variable "cluster_name" {
  description = "The cluster name to use"
  type        = string
}

variable "environment" {
  description = "The environment name"
  type        = string
}

variable "do_token" {
  description = "digital ocean personal access token for creating/destroying cloud resoures"
  type        = string
  sensitive   = true
}

variable "pvt_key" {
  description = "y'alls ssh private key location i.e. ~/.ssh/id_rsa"
  type        = string
}

variable "frontend_hostname" {
  description = "The web dns name of our front end website"
  type        = string
}

variable "loadbalancer_friendly_name" {
  description = "The label for the load balancer"
  type        = string
}

variable "manager_deployment_hash" {}
variable "custom_deployment_hash" {}
variable "container_registry" {}
