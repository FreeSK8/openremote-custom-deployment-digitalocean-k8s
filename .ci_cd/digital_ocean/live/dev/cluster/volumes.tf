resource "digitalocean_volume" "postgresql_data" {
  region                  = "nyc1"
  name                    = "postgresql-data"
  size                    = 5
  initial_filesystem_type = "ext4"
  description             = "Kubernetes storage volume for pgsql"
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
  region                  = "nyc1"
  name                    = "manager-data"
  size                    = 5
  initial_filesystem_type = "ext4"
  description             = "Kubernetes storage volume for openremote manager"
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
      "ReadWriteMany",
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
  region                  = "nyc1"
  name                    = "deployment-data"
  size                    = 5
  initial_filesystem_type = "ext4"
  description             = "Kubernetes storage volume for keycloak"
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
      "ReadWriteMany",
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
