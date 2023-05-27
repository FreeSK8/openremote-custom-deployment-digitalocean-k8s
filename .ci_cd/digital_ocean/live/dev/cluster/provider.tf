terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.8.0"
    }
  }
 
  backend "s3" {
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    endpoint                    = "https://nyc3.digitaloceanspaces.com"
    region                      = "us-east-1" // needed
    bucket                      = "sk8net-secrets-stage" // name of your space
    key                         = "infrastructure/terraform.tfstate"
  }
}

provider "digitalocean" {
  token = var.do_token
  spaces_access_id  = var.spaces_access_id
  spaces_secret_key = var.spaces_secret_key
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}
