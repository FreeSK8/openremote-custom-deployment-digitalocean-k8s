resource "digitalocean_volume" "postgresql_data" {
  region                  = var.region
  name                    = "${var.environment}-openremote-postgresql"
  size                    = 5
}

resource "kubernetes_persistent_volume" "postgresql_data" {
  metadata {
    labels = {
      app = "pgsql"
    }
    name = "postgresql-data"
  }
  spec {
    capacity = {
      storage = "5Gi"
    }
    access_modes = [
      "ReadWriteOnce",
    ]
    storage_class_name = "do-block-storage"
    persistent_volume_source {
      csi {
        driver = "dobs.csi.digitalocean.com"
        volume_handle = digitalocean_volume.postgresql_data.id
        fs_type = "ext4"
        volume_attributes = {
          "com.digitalocean.csi/noformat" = "true"
        }
      }
    }
  }
}

resource "digitalocean_volume" "manager_data" {
  region                  = var.region
  name                    = "${var.environment}-openremote-manager"
  size                    = 5
}

resource "kubernetes_persistent_volume" "manager_data" {
  metadata {
    labels = {
      app = "web"
    }
    name = "manager-data"
  }
  spec {
    capacity = {
      storage = "5Gi"
    }
    access_modes = [
      "ReadWriteOnce",
    ]
    storage_class_name = "do-block-storage"
    persistent_volume_source {
      csi {
        driver = "dobs.csi.digitalocean.com"
        volume_handle = digitalocean_volume.manager_data.id
        fs_type = "ext4"
        volume_attributes = {
          "com.digitalocean.csi/noformat" = "true"
        }
      }
    }
  }
}

resource "digitalocean_volume" "deployment_data" {
  region                  = var.region
  name                    = "${var.environment}-openremote-deployment"
  size                    = 5
}

resource "kubernetes_persistent_volume" "deployment_data" {
  metadata {
    labels = {
      app = "web"
    }
    name = "deployment-data"
  }
  spec {
    capacity = {
      storage = "5Gi"
    }
    storage_class_name = "do-block-storage"
    access_modes = [
      "ReadWriteOnce",
    ]
    persistent_volume_source {
      csi {
        driver = "dobs.csi.digitalocean.com"
        volume_handle = digitalocean_volume.deployment_data.id
        fs_type = "ext4"
        volume_attributes = {
          "com.digitalocean.csi/noformat" = "true"
        }
      }
    }
  }
}


resource "digitalocean_volume" "proxy_data" {
  region                  = var.region
  name                    = "${var.environment}-openremote-proxy"
  size                    = 5
}

resource "kubernetes_persistent_volume" "proxy_data" {
  metadata {
    labels = {
      app = "web"
    }
    name = "proxy-data"
  }
  spec {
    capacity = {
      storage = "5Gi"
    }
    storage_class_name = "do-block-storage"
    access_modes = [
      "ReadWriteOnce",
    ]
    persistent_volume_source {
      csi {
        driver = "dobs.csi.digitalocean.com"
        volume_handle = digitalocean_volume.proxy_data.id
        fs_type = "ext4"
        volume_attributes = {
          "com.digitalocean.csi/noformat" = "true"
        }
      }
    }
  }
}
