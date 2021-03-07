provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "default"
}
resource "kubernetes_namespace" "jenkins_terraform" {
  metadata {
    name = "jenkins-tf"
  }
}

resource "kubernetes_persistent_volume_claim" "claim" {
  metadata {
    name = "jenkins-claim"
    namespace = "jenkins-tf"
    labels = { 
    managedby = "terraform"
    }
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    storage_class_name = "local-path"
  }
  depends_on = [kubernetes_namespace.jenkins_terraform
  ]
}


resource "kubernetes_deployment" "jenkins-tf" {
  depends_on = [
    kubernetes_namespace.jenkins_terraform
  ]
  metadata {
    name      = "jenkins-deployment"
    namespace = "jenkins-tf"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "jenkinsapp"
      }
    }
    template {
      metadata {
        labels = {
          app = "jenkinsapp"
        }
      }
      spec {
        container {
          image = "jenkins/jenkins:latest"
          name  = "jenkins-container"
          port {
            container_port = 8080
          }
          volume_mount {
            name       = "jenkins-persistent-storage"
            mount_path = "/var/jenkins_home"
          }
        }
        volume {
          name = "jenkins-persistent-storage"
          persistent_volume_claim {
            claim_name = "jenkins-claim"
          }
        }
      }
    }
  }
}


resource "kubernetes_service" "jenkins-tf" {
  depends_on = [
    kubernetes_deployment.jenkins-tf
  ]

  metadata {
    name      = "jenkinsapp"
    namespace = "jenkins-tf"
  }
  spec {
    selector = {
      app = "jenkinsapp"
    }
    type = "NodePort"
    port {
      node_port   = 31080
      port        = 8080
      target_port = 8080
    }
  }
}
