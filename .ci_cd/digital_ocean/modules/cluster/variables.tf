variable "project_name" {
  description = "The project name to use"
  type        = string
}

variable "description" {
  description = "Description for the DigitalOcean project"
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

variable "do_token" {}
variable "pvt_key" {}

variable "frontend_hostname" {}
variable "certificate_id" {}
variable "loadbalancer_friendly_name" {}
variable "spaces_access_id" {}
variable "spaces_secret_key" {}
